# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Toggl::Worktime::Merger do
  let(:merger) { Toggl::Worktime::Merger.new([], default_config) }
  let(:default_config) { Toggl::Worktime::Config.new({}) }

  before do
    # Config
    allow(Toggl::Worktime::Config).to receive(:load_config).and_return({})
  end

  it 'can initialize' do
    expect(merger).to be_a(Toggl::Worktime::Merger)
  end

  describe '#parse_date' do
    # Time format from Toggl API
    let(:input_time) { '2006-01-02T15:04:05+00:00' }
    # JST offset
    let(:zone_offset) { 9 * 60 * 60 }

    it 'converts correctly to the desired timezone' do
      dt = Toggl::Worktime::Merger.parse_date(input_time, zone_offset)
      expect(dt.year).to eq 2006
      expect(dt.month).to eq 1
      expect(dt.day).to eq 3
      expect(dt.hour).to eq 0
      expect(dt.min).to eq 4
      expect(dt.sec).to eq 5
    end
  end

  let(:uid) { 12_345_678 }
  let(:wid) { 20_000_000 }
  let(:pid) { 10_000_000 }

  shared_context 'continuing input' do
    let(:input) do
      [
        {
          'id' => 954_175_782,
          'guid' => '1a6505605b6b66d68fcfe70a39ac5d08',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T01:39:38+00:00',
          'stop' => '2018-08-22T03:29:21+00:00',
          'duration' => 6583,
          'description' => 'DESC 01',
          'duronly' => false,
          'at' => '2018-08-22T03:29:22+00:00',
          'uid' => uid
        },
        # Short interval; should be concatenated
        {
          'id' => 954_210_586,
          'guid' => 'cf89f9238c5930988ba22b0687dbdf2b',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T03:31:00+00:00',
          'stop' => '2018-08-22T03:51:40+00:00',
          'duration' => 1339,
          'description' => 'DESC 02',
          'duronly' => false,
          'at' => '2018-08-22T03:51:42+00:00',
          'uid' => uid
        },
        {
          'id' => 954_216_790,
          'guid' => 'afd8b15852f5734061694c333843de4c',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T03:51:40+00:00',
          'stop' => '2018-08-22T04:59:26+00:00',
          'duration' => 4066,
          'description' => 'DESC 03',
          'duronly' => false,
          'at' => '2018-08-22T04:59:28+00:00',
          'uid' => uid
        }
      ]
    end
    let(:output) do
      [
        [
          Time.new(2018, 8, 22, 10, 39, 38, '+09:00'),
          Time.new(2018, 8, 22, 13, 59, 26, '+09:00')
        ]
      ]
    end
    let(:total_time) { 11_988 }
  end

  shared_context 'separating input' do
    let(:input) do
      [
        {
          'id' => 954_175_782,
          'guid' => '1a6505605b6b66d68fcfe70a39ac5d08',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T01:39:38+00:00',
          'stop' => '2018-08-22T03:29:21+00:00',
          'duration' => 6583,
          'description' => 'DESC 01',
          'duronly' => false,
          'at' => '2018-08-22T03:29:22+00:00',
          'uid' => uid
        },
        # Long interval; should be separated
        {
          'id' => 954_210_586,
          'guid' => 'cf89f9238c5930988ba22b0687dbdf2b',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T03:50:00+00:00',
          'stop' => '2018-08-22T03:51:40+00:00',
          'duration' => 1339,
          'description' => 'DESC 02',
          'duronly' => false,
          'at' => '2018-08-22T03:51:42+00:00',
          'uid' => uid
        },
        {
          'id' => 954_216_790,
          'guid' => 'afd8b15852f5734061694c333843de4c',
          'wid' => wid,
          'pid' => pid,
          'billable' => false,
          'start' => '2018-08-22T03:53:40+00:00',
          'stop' => '2018-08-22T04:59:26+00:00',
          'duration' => 4066,
          'description' => 'DESC 03',
          'duronly' => false,
          'at' => '2018-08-22T04:59:28+00:00',
          'uid' => uid
        }
      ]
    end
    let(:output) do
      [
        [
          Time.new(2018, 8, 22, 10, 39, 38, '+09:00'),
          Time.new(2018, 8, 22, 12, 29, 21, '+09:00')
        ],
        [
          Time.new(2018, 8, 22, 12, 50, 0, '+09:00'),
          Time.new(2018, 8, 22, 13, 59, 26, '+09:00')
        ]
      ]
    end
    let(:total_time) { 10_749 }
  end

  describe '#merge' do
    let(:merger) { Toggl::Worktime::Merger.new(input, default_config) }

    describe 'merge result' do
      context 'detects continuation' do
        include_context 'continuing input'
        subject { merger.merge }
        it { is_expected.to eq output }
      end

      context 'detects separation' do
        include_context 'separating input'
        subject { merger.merge }
        it { is_expected.to eq output }
      end
    end

    describe 'total time' do
      context 'detects continuation' do
        include_context 'continuing input'
        subject do
          merger.merge
          merger.total_time
        end
        it { is_expected.to eq total_time }
      end

      context 'detects separation' do
        include_context 'separating input'
        subject do
          merger.merge
          merger.total_time
        end
        it { is_expected.to eq total_time }
      end
    end
  end
end
