require 'spec_helper'

RSpec.describe Garage::Strategy::AccessToken do
  let(:attrs) { { expired_at: expired_at, token: token, revoked_at: nil } }
  let(:token) { 'xxx' }
  let(:expired_at) { nil }

  describe '#accessible?' do
    subject { Garage::Strategy::AccessToken.new(attrs).accessible? }

    context 'when valid case' do
      it { is_expected.to be_truthy }
    end

    context 'when token is null' do
      let(:token) { nil }
      it { is_expected.to be_truthy }
    end
  end

  describe '#expired?' do
    before { Timecop.freeze(Time.zone.parse('2015/01/01 00:00:00')) }
    subject { Garage::Strategy::AccessToken.new(attrs).expired? }

    context 'when expired_at is null' do
      let(:expired_at) { nil }
      it { is_expected.to be_falsey }
    end

    context 'when expired_at is empty string' do
      let(:expired_at) { '' }
      it { is_expected.to be_falsey }
    end

    context 'when expired_at is invalid value' do
      let(:expired_at) { 'xxx' }
      it { is_expected.to be_falsey }
    end

    context 'when expired_at is future' do
      let(:expired_at) { Time.zone.parse('2015/02/01 00:00:00').to_s }
      it { is_expected.to be_falsey }
    end

    context 'when expired_at is past' do
      let(:expired_at) { Time.zone.parse('2014/12/01 00:00:00').to_s }
      it { is_expected.to be_truthy }
    end
  end
end
