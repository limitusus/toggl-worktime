# frozen_string_literal: true

module Toggl
  module Worktime
    # Worktime Calendar
    class Calendar
      WEEK = %i[Sun Mon Tue Wed Thu Fri Sat].freeze

      class UnknownWeekdayError < StandardError; end

      def initialize(driver, zone_offset, week_begin, year, month)
        @driver = driver
        @zone_offset = zone_offset
        @year = year
        @month = month
        today = ::Time.new
        @days_in_month = Date.new(year, month, -1).day
        @last_fetch_day = @days_in_month
        @last_fetch_day = today.day if today.year == year && today.month == month && today.day < @days_in_month
        @data = nil
        @week_begin_day = week_begin.to_sym
        raise UnknownWeekdayError if WEEK.index(@week_begin_day).nil?
      end

      def week
        begin_index = WEEK.index(@week_begin_day)
        WEEK.rotate(begin_index)
      end

      def write
        fetch if @data.nil?
        rotation = week.index(:Sun)
        table = TTY::Table.new header: week
        week_data = []
        @day_data.each do |datum|
          wday = datum.day.wday
          # wday may be rotated
          wday_index = (wday + rotation) % 7
          week_data[wday_index] = datum.format
          if wday_index == 6
            table << week_data
            week_data = []
          end
        end
        # last week data may exist
        unless week_data.length.zero?
          # Padding
          (7 - week_data.length).times do
            week_data << nil
          end
          table << week_data
        end
        multi_renderer = TTY::Table::Renderer::Unicode.new(table, multiline: true)
        multi_renderer.border.separator = :each_row
        puts multi_renderer.render
      end

      def fetch
        @day_data = []
        (1..@days_in_month).each do |day|
          dateobj = Date.new(@year, @month, day)
          day_datum = nil
          if day <= @last_fetch_day
            @driver.merge!(@year, @month, day)
            time = @driver.total_time
            begin_at = @driver.work_time.first[0]&.getlocal(@zone_offset)&.strftime('%T')
            end_at = @driver.work_time.last[1]&.getlocal(@zone_offset)&.strftime('%T')
            day_datum = Toggl::Worktime::Day.new(dateobj, time, begin_at, end_at)
          else
            day_datum = Toggl::Worktime::Day.new(dateobj, 0, '', '')
          end
          @day_data << day_datum
        end
      end
    end

    # One-day datum
    class Day
      attr_reader :day

      def initialize(day, time, begin_at, end_at)
        @day = day
        @time = time
        @begin = begin_at
        @end = end_at
      end

      def format
        "Day: #{day.day}\n#{@begin}-#{@end}\n#{@time}"
      end
    end
  end
end
