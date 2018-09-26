# frozen_string_literal: true

require 'time'

module Toggl
  module Worktime
    # Time-entries merger
    class Merger
      attr_reader :total_time

      ONE_MINUTE_SECONDS = 60

      def initialize(time_entries, config)
        @time_entries = time_entries
        @config = config
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
          @total_time += @current_stop - @current_start
          @current_start = start
          @current_stop = stop
        end
        work_time << [@current_start, @last_stop]
        @total_time += @current_stop - @current_start
        work_time
      end

      def time_entries_each
        zone_offset = Toggl::Worktime::Time.zone_offset(@config.timezone)
        @time_entries.each do |te|
          start = parse_date(te['start'], zone_offset)
          stop = parse_date(te['stop'], zone_offset)
          @last_stop = stop
          @current_start = start if @current_start.nil?
          @current_stop = stop if @current_stop.nil?
          if start.nil? || stop.nil?
            warn 'start or stop time is nil: total time may be incomplete'
          end
          yield [start, stop]
        end
      end

      def parse_date(date, zone_offset)
        return nil if date.nil?

        ::Time.parse(date).getlocal(zone_offset)
      end

      def continuing(start)
        return true if @current_stop.nil?

        interval = (start - @current_stop) / ONE_MINUTE_SECONDS
        @continuing = interval < @config.working_interval_min
      end
    end
  end
end
