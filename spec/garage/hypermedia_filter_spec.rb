require "spec_helper"

describe Garage::HypermediaFilter do
  before do
    Garage::NestedFieldQuery::Selector.stub(:build) {|fields| fields }
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

  describe ".filter" do
    it "assigns parsed field selector to controller.field_selector" do
      controller.should_receive(:field_selector=).with("fields")
      described_class.filter(controller)
    end

    context "with 'application/vnd.cookpad.dictionary+json' MIME format" do
      let(:format) do
        "application/vnd.cookpad.dictionary+json"
      end

      it "assigns :dictionary to controller.representation" do
        controller.should_receive(:representation=).with(:dictionary)
        described_class.filter(controller)
      end

      it "assigns :json to controller.request.format" do
        controller.request.should_receive(:format=).with(:json)
        described_class.filter(controller)
      end
    end

    context "with 'application/vnd.cookpad.dictionary+x-msgpack' MIME format" do
      let(:format) do
        "application/vnd.cookpad.dictionary+x-msgpack"
      end

      it "assigns :dictionary to controller.representation" do
        controller.should_receive(:representation=).with(:dictionary)
        described_class.filter(controller)
      end

      it "assigns :msgpack to controller.request.format" do
        controller.request.should_receive(:format=).with(:msgpack)
        described_class.filter(controller)
      end
    end

    context "with invalid fields param" do
      before do
        Garage::NestedFieldQuery::Selector.stub(:build) do
          raise Garage::NestedFieldQuery::InvalidQuery
        end
      end

      it "raises Garage::BadRequest exception" do
        expect { described_class.filter(controller) }.to raise_error(Garage::BadRequest)
      end
    end
  end
end
