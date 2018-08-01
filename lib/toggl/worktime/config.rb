require 'yaml'

module Toggl
  module Worktime
    class Config
      attr_accessor :foo

      ATTRS = %i[
        working_interval_min
        day_begin_hour
        timezone
      ].freeze

      ATTR_DEFAULTS = {
        working_interval_min: 10,
        day_begin_hour: 6,
        timezone: 'Asia/Tokyo',
      }.freeze

      ATTRS.each do |attr|
        attr_accessor attr
      end

      def initialize(args)
        #attr_set(args) if args.key?(:foo)
        c = self.class.load_config(args[:path])
        attr_set(c)
      end

      class << self
        def load_config(path)
          YAML.safe_load(File.open(path).read).transform_keys(&:to_sym)
        end
      end

      private

      def attr_set(hash)
        ATTRS.each { |k| send((k.to_s + '=').to_sym, hash.key?(k) ? hash[k] : ATTR_DEFAULTS[k] ) }
      end
    end
  end
end
