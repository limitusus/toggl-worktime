# frozen_string_literal: true

module Toggl
  module Worktime
    # Toggle API driver
    class Driver
      ONE_DAY_SECONDS = 86_400

      attr_reader :toggl
      attr_reader :work_time

      def initialize(config:)
        @toggl = TogglV8::API.new
        @config = config
        @merger = nil
        @work_time = nil
        @zone_offset = Toggl::Worktime::Time.zone_offset(@config.timezone)
        @calendar = nil
      end

      def calendar(week_begin, year, month)
        @calendar = Toggl::Worktime::Calendar.new(self, @zone_offset, week_begin, year, month)
      end

      def time_entries(year, month, day)
        beginning_day = ::Time.new(
          year, month, day, @config.day_begin_hour, 0, 0, @zone_offset
        )
        ending_day = beginning_day + ONE_DAY_SECONDS
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
              end
            end
          end
        }
        entries.select { |e| pass_l.call(e) }
      end

      def me
        @toggl.me(true)
      end

      def merge!(year, month, day)
        time_entries = time_entries(year, month, day)
        time_entries = filter_entries(time_entries)
        @merger = Toggl::Worktime::Merger.new(time_entries, @config)
        @work_time = @merger.merge
      end

      def write
        @work_time.each do |span|
          begin_s = time_expr(span[0])
          end_s = time_expr(span[1])
          puts "#{begin_s} - #{end_s}"
        end
      end

      def time_expr(time)
        time ? time.getlocal(@zone_offset).strftime('%F %T') : 'nil'
      end

      def total_time
        total_seconds = @merger.total_time.to_i
        hours = total_seconds / (60 * 60)
        minutes = (total_seconds - (hours * 60 * 60)) / 60
        seconds = total_seconds % 60
        format('%02d:%02d:%02d', hours, minutes, seconds)
      end
    end
  end
end
