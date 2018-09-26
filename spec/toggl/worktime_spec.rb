# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toggl::Worktime do
  it 'has a version number' do
    expect(Toggl::Worktime::VERSION).not_to be nil
  end
end
