require 'spec_helper'

describe Garage::TokenScope do
  describe '.optional_scopes' do
    subject { Garage::TokenScope.optional_scopes.map(&:to_s) }

    it 'should not include hidden scopes' do
      is_expected.not_to include('sudo')
    end

    it 'should not include public scope' do
      is_expected.not_to include('public')
    end

    it 'should include optional scope' do
      is_expected.to include('write_post')
    end
  end

end
