# frozen_string_literal: true

require 'togglv8'
require 'json'
require 'toggl/worktime/version'

module Toggl
  module Worktime
    include 'toggl/worktime/merger'
    include 'toggl/worktime/timezone'
  end
end
