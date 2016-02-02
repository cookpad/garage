require 'spec_helper'

RSpec.describe Garage::Strategy::AccessToken do
  describe '#expired?' do
    before { Timecop.freeze(Time.zone.parse('2015/01/01 00:00:00')) }
    subject { Garage::Strategy::AccessToken.new(attrs).expired? }
    let(:attrs) { { expired_at: expired_at, revoked_at: nil } }

    context 'when expired_at is null' do
      let(:expired_at) { nil }
      it { should be_false }
    end

    context 'when expired_at is empty string' do
      let(:expired_at) { '' }
      it { should be_false }
    end

    context 'when expired_at is invalid value' do
      let(:expired_at) { 'xxx' }
      it { should be_false }
    end

    context 'when expired_at is future' do
      let(:expired_at) { Time.zone.parse('2015/02/01 00:00:00').to_s }
      it { should be_false }
    end

    context 'when expired_at is past' do
      let(:expired_at) { Time.zone.parse('2014/12/01 00:00:00').to_s }
      it { should be_true }
    end
  end
end
