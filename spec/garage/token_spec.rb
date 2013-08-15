require 'spec_helper'

describe Garage::TokenScope do
  describe '.optional_scopes' do
    subject { Garage::TokenScope.optional_scopes.map(&:to_sym) }

    it 'should not include hidden scopes' do
      should_not include(:sudo)
    end

    it 'should not include public scope' do
      should_not include(:public)
    end

    it 'should include optional scope' do
      should include(:write_post)
    end
  end

end
