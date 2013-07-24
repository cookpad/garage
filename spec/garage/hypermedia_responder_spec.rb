require "spec_helper"

describe Garage::HypermediaResponder::DataRenderer do
  describe ".render" do
    subject do
      described_class.render(rendered, options)
    end

    let(:resource) do
      { "id" => 1 }
    end

    let(:options) do
      {}
    end

    context "with a resource" do
      let(:rendered) do
        resource
      end

      context "by default" do
        it "returns argument as JSON" do
          should == rendered.to_json
        end
      end

      context "with :dictionary option" do
        before do
          options[:dictionary] = true
        end

        it "returns argument as JSON" do
          should == rendered.to_json
        end
      end

      context "with '<' & '>'" do
        let(:resource) do
          { "name" => "<x>" }
        end

        it "replaces them with '\\u003C' & '\\u003E'" do
          should == %<{"name":"\u003Cx\u003E"}>
        end
      end
    end

    context "with resources" do
      let(:rendered) do
        [resource]
      end

      context "by default" do
        it "returns argument as JSON in Array" do
          should == rendered.to_json
        end
      end

      context "with :dictionary option" do
        before do
          options[:dictionary] = true
        end

        it "returns argument as JSON in Hash" do
          should == { resource["id"] => resource }.to_json
        end
      end

      context "with :dictionary option & non-convertible resources" do
        let(:resource) do
          { "name" => "foo" }
        end

        it "returns argument as JSON in Array" do
          should == rendered.to_json
        end
      end
    end
  end
end

describe Garage::HypermediaResponder::Representation do
  let(:representation) do
    described_class.new(controller)
  end

  let(:controller) do
    double(representation: representation_type, request: request)
  end

  let(:representation_type) do
    :dictionary
  end

  let(:request) do
    double(format: format)
  end

  let(:format) do
    "application/json"
  end

  describe "#dictionary?" do
    context "with controller.representation == :dictionary" do
      it "returns true" do
        representation.dictionary?.should == true
      end
    end

    context "with controller.representation != :dictionary" do
      let(:representation_type) do
        nil
      end

      it "returns false" do
        representation.dictionary?.should == false
      end
    end
  end

  describe "#content_type" do
    context "with controller.request.format == 'application/json'" do
      it "returns 'application/vnd.cookpad.dictionary+json'" do
        representation.content_type.should == "application/vnd.cookpad.dictionary+json"
      end
    end
  end
end
