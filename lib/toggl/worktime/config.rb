# frozen_string_literal: true

require 'yaml'

module Toggl
  module Worktime
    # Config for Toggl::Worktime
    class Config
      attr_accessor :foo

      ATTRS = %i[
        working_interval_min
        day_begin_hour
        timezone
        ignore_conditions
      ].freeze

      ATTR_DEFAULTS = {
        working_interval_min: 10,
        day_begin_hour: 6,
        timezone: 'Asia/Tokyo',
        ignore_conditions: []
      }.freeze

      ATTRS.each do |attr|
        attr_accessor attr
      end

      def initialize(args)
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
        ATTRS.each do |k|
          send((k.to_s + '=').to_sym, hash.key?(k) ? hash[k] : ATTR_DEFAULTS[k])
        end
      end
    end
  end
end
