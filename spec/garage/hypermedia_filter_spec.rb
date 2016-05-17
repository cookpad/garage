require "spec_helper"

describe Garage::HypermediaFilter do
  before do
    allow(Garage::NestedFieldQuery::Selector).to receive(:build) {|fields| fields }
  end

  let(:controller) do
    double(
      :field_selector= => nil,
      :params => params,
      :representation= => nil,
      :request => request,
    )
  end

  let(:params) do
    { fields: "fields" }
  end

  let(:request) do
    double(
      :format => format,
      :format= => nil,
    )
  end

  let(:format) do
    ""
  end

  describe ".before" do
    it "assigns parsed field selector to controller.field_selector" do
      expect(controller).to receive(:field_selector=).with("fields")
      described_class.before(controller)
    end

    context "with 'application/vnd.cookpad.dictionary+json' MIME format" do
      let(:format) do
        "application/vnd.cookpad.dictionary+json"
      end

      it "assigns :dictionary to controller.representation" do
        expect(controller).to receive(:representation=).with(:dictionary)
        described_class.before(controller)
      end

      it "assigns :json to controller.request.format" do
        expect(controller.request).to receive(:format=).with(:json)
        described_class.before(controller)
      end
    end

    context "with 'application/vnd.cookpad.dictionary+x-msgpack' MIME format" do
      let(:format) do
        "application/vnd.cookpad.dictionary+x-msgpack"
      end

      it "assigns :dictionary to controller.representation" do
        expect(controller).to receive(:representation=).with(:dictionary)
        described_class.before(controller)
      end

      it "assigns :msgpack to controller.request.format" do
        expect(controller.request).to receive(:format=).with(:msgpack)
        described_class.before(controller)
      end
    end

    context "with invalid fields param" do
      before do
        allow(Garage::NestedFieldQuery::Selector).to receive(:build) do
          raise Garage::NestedFieldQuery::InvalidQuery
        end
      end

      it "raises Garage::BadRequest exception" do
        expect { described_class.before(controller) }.to raise_error(Garage::BadRequest)
      end
    end
  end
end
