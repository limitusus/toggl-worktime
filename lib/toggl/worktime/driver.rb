# frozen_string_literal: true

module Toggl
  module Worktime
    # Toggle API driver
    class Driver
      attr_reader :toggl

      def initialize
        @toggl = TogglV8::API.new
        @merger = nil
        @work_time = nil
      end

      def time_entries(month, day, hour, timezone)
        now = DateTime.now
        offset = Toggl::Worktime::Time.zone_offset(timezone)
        beginning_day = DateTime.new(now.year, month, day, hour, 0, 0, offset)
        ending_day = beginning_day + 1
        toggl.get_time_entries(start_date: beginning_day.iso8601, end_date: ending_day.iso8601)
      end

      def me
        @toggl.me(true)
      end

      def merge!(month, day, hour, timezone)
        time_entries = time_entries(month, day, hour, timezone)
        @merger = Toggl::Worktime::Merger.new(time_entries)
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
        total_seconds = time.numerator
        hours = total_seconds / (60 * 60)
        minutes = (total_seconds - (hours * 60 * 60)) / 60
        seconds = total_seconds % 60
        format("%02d:%02d:%02d", hours, minutes, seconds)
      end
    end
  end
end
