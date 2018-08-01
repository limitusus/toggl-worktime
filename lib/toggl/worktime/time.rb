# frozen_string_literal: true

module Toggl
  module Worktime
    # Timezone
    module Time
      # Seconds
      def self.zone_offset(timezone)
        tz = ENV['TZ']
        ENV['TZ'] = timezone
        offset = ::Time.now.utc_offset
        ENV['TZ'] = tz
        offset
      end
    end
  end
end
