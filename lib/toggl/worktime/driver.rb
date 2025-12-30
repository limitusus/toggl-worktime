# frozen_string_literal: true

module Toggl
  module Worktime
    # Toggle API driver
    class Driver
      ONE_DAY_SECONDS = 86_400

      attr_reader :toggl
      attr_reader :work_time_map
      attr_reader :days

      def initialize(config:)
        @toggl = TogglV9::API.new
        @config = config
        @zone_offset = Toggl::Worktime::Time.zone_offset(@config.timezone)
        @calendar = nil
        @days = []
        @merger_map = {}
        @work_time_map = {}
      end

      def calendar(week_begin, year, month)
        @calendar = Toggl::Worktime::Calendar.new(self, @zone_offset, week_begin, year, month)
      end

      # Multi-day time entries in a request
      def time_entries_multi(year, month, begin_day, end_day)
        beginning_day = ::Time.new(
          year, month, begin_day, @config.day_begin_hour, 0, 0, @zone_offset
        )
        ending_day = beginning_day + ONE_DAY_SECONDS * (end_day - begin_day + 1)
        start_iso = beginning_day.strftime('%FT%T%:z')
        end_iso = ending_day.strftime('%FT%T%:z')
        toggl.get_time_entries(start_date: start_iso, end_date: end_iso)
      end

      # time_entries filter with @config.ignore_conditions
      def filter_entries(entries)
        pass_l = lambda { |entry|
          @config.ignore_conditions.none? do |cond|
            cond.keys.all? do |key|
              case key
              when 'tags'
                entry['tags']&.any? { |t| cond[key].include?(t) }
              when 'project_id'
                cond[key].include?(entry['project_id'])
              end
            end
          end
        }
        entries.select { |e| pass_l.call(e) }
      end

      def me
        @toggl.me(true)
      end

      # Generator: Split time_entries for multiple days into days
      def split_by_day(entries_multi)
        current_date = nil
        beginning_day = nil
        time_entries = []
        entries_multi.sort { |a, b| a['start'] <=> b['start'] }.each do |time_entry|
          start_ts = Toggl::Worktime::Merger.parse_date(time_entry['start'], @zone_offset)
          if beginning_day.nil? || beginning_day.strftime('%F') != (start_ts - @config.day_begin_hour * 3600).strftime('%F')
            # Push current buffer
            unless beginning_day.nil?
              yield [beginning_day.day, time_entries]
            end
            time_entries = []
            beginning_day = ::Time.new(
              start_ts.year, start_ts.month, start_ts.day, @config.day_begin_hour, 0, 0, @zone_offset
            )
            ending_day = beginning_day + ONE_DAY_SECONDS
          end
          time_entries << time_entry
        end
        yield [beginning_day.day, time_entries]
      end

      def merge_multi!(year, month, begin_day, end_day)
        entries_multi = time_entries_multi(year, month, begin_day, end_day)
        time_entries_filtered_multi = filter_entries(entries_multi)
        split_by_day(time_entries_filtered_multi) do |day, time_entries|
          @days << day
          @merger_map[day] = Toggl::Worktime::Merger.new(time_entries, @config)
          @work_time_map[day] = @merger_map[day].merge
        end
      end

      def write(day)
        @work_time_map[day].each do |span|
          begin_s = time_expr(span[0])
          end_s = time_expr(span[1])
          puts "#{begin_s} - #{end_s}"
        end
      end

      def time_expr(time)
        time ? time.getlocal(@zone_offset).strftime('%F %T') : 'nil'
      end

      def total_time(day:)
        merger = @merger_map[day]
        total_seconds = merger.total_time.to_i
        hours = total_seconds / (60 * 60)
        minutes = (total_seconds - (hours * 60 * 60)) / 60
        seconds = total_seconds % 60
        format('%02d:%02d:%02d', hours, minutes, seconds)
      end
    end
  end
end
