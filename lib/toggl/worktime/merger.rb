# frozen_string_literal: true

module Toggl
  module Worktime
    # Time-entries merger
    class Merger
      attr_reader :total_time

      ONE_DAY_MINUTES = 24 * 60

      def initialize(time_entries, timezone, max_working_interval)
        @time_entries = time_entries
        @timezone = timezone
        @max_working_interval = max_working_interval
        @current_start = nil
        @current_stop = nil
        @continuing = true
        @last_stop = nil
        @total_time = 0
      end

      def merge
        work_time = []
        time_entries_each do |start, stop|
          if continuing(start)
            @current_stop = stop
            next
          end
          work_time << [@current_start, @current_stop]
          @current_start = start
          @current_stop = stop
        end
        work_time << [@current_start, @last_stop]
        work_time
      end

      def time_entries_each
        zone_offset = Toggl::Worktime::Time.zone_offset(@timezone)
        @time_entries.each do |te|
          start = parse_date(te['start'], zone_offset)
          stop = parse_date(te['stop'], zone_offset)
          @last_stop = stop
          @current_start = start if @current_start.nil?
          @current_stop = stop if @current_stop.nil?
          @total_time += stop - start
          yield [start, stop]
        end
      end

      def parse_date(date, zone_offset)
        return nil if date.nil?
        DateTime.parse(date).new_offset(zone_offset)
      end

      def continuing(start)
        interval = (start - @current_stop) * ONE_DAY_MINUTES
        @continuing = interval < @max_working_interval
      end
    end
  end
end
