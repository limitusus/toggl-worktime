# frozen_string_literal: true

module Toggl
  module Worktime
    # Toggle API driver
    class Driver
      attr_reader :toggl
      attr_reader :work_time

      def initialize(config:)
        @toggl = TogglV8::API.new
        @config = config
        @merger = nil
        @work_time = nil
      end

      def time_entries(year, month, day)
        offset = Toggl::Worktime::Time.zone_offset(@config.timezone)
        beginning_day = DateTime.new(year, month, day, @config.day_begin_hour, 0, 0, offset)
        ending_day = beginning_day + 1
        toggl.get_time_entries(start_date: beginning_day.iso8601, end_date: ending_day.iso8601)
      end

      # time_entries filter with @config.ignore_conditions
      def filter_entries(entries)
        pass_l = -> (entry) {
          !@config.ignore_conditions.any? { |cond|
            cond.keys.all? { |key|
              case key
              when 'tags'
                entry['tags']&.any? { |t| cond[key].include?(t) }
              end
            }
          }
        }
        entries.select{ |e| pass_l.call(e) }
      end

      def me
        @toggl.me(true)
      end

      def merge!(year, month, day)
        time_entries = time_entries(year, month, day)
        @merger = Toggl::Worktime::Merger.new(filter_entries(time_entries), @config)
        @work_time = @merger.merge
      end

      def write
        @work_time.each do |span|
          begin_s = time_expr(span[0])
          end_s = time_expr(span[1])
          puts "#{begin_s} - #{end_s}"
        end
      end

      def time_expr(t)
        t ? t.strftime('%F %T') : 'nil'
      end

      def total_time
        time = @merger.total_time
        total_seconds = (time * 86400).to_i
        hours = total_seconds / (60 * 60)
        minutes = (total_seconds - (hours * 60 * 60)) / 60
        seconds = total_seconds % 60
        format("%02d:%02d:%02d", hours, minutes, seconds)
      end
    end
  end
end
