require 'spec_helper'

RSpec.describe Garage::Representer do
  describe Garage::Representer::Definition do
    describe '#encode_value' do
      context 'with Hashie::Mash' do
        let(:responder) { double(:responder) }
        let(:selector) { double(:selector) }

        it 'treats as a Hash' do
          value = Hashie::Mash.new.tap do |v|
            v.name = 'Alice'
            v.id = 1
          end
          definition = Garage::Representer::Definition.new(:user)

          expect(definition.encode_value(value, responder, selector)).to eq(value)
        end
      end
    end
  end
end
