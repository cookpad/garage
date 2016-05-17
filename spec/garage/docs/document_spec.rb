require "spec_helper"

describe Garage::Docs::Document do
  let(:document) do
    described_class.new(pathname)
  end

  let(:pathname) do
    double
  end

  let(:user) do
    double(admin?: false)
  end

  let(:admin) do
    double(admin?: true)
  end

  describe "#visible_to?" do
    context "with default settings" do
      it "returns true" do
        expect(document.visible_to?(user)).to eq(true)
        expect(document.visible_to?(admin)).to eq(true)
      end
    end

    context "with custom settings" do
      around do |example|
        origin = Garage.configuration.docs.docs_authorization_method
        Garage.configuration.docs.docs_authorization_method = ->(args) { args[:user].admin? }
        example.run
        Garage.configuration.docs.docs_authorization_method = origin
      end

      it "returns the evaluation result of docs_authorization_method" do
        expect(document.visible_to?(user)).to eq(false)
        expect(document.visible_to?(admin)).to eq(true)
      end
    end
  end
end
