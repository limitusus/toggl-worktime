# frozen_string_literal: true

module Toggl
  module Worktime
    # Timezone
    module Time
      # rational
      def self.zone_offset(timezone)
        tz = ENV['TZ']
        ENV['TZ'] = timezone
        offset = DateTime.now.offset
        ENV['TZ'] = tz
        offset
      end
    end
  end
end
