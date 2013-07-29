require "spec_helper"

describe Garage::HypermediaResponder do
  before do
    controller.responder = responder
    controller.resource = resource
  end

  let(:responder) do
    Class.new(ActionController::Responder) do
      include Garage::HypermediaResponder
    end
  end

  let(:controller) do
    Class.new(ActionController::Base) do
      respond_to :json

      class << self
        attr_accessor :resource

        def name
          "ExamplesController"
        end
      end

      attr_accessor :field_selector, :representation

      def show
        respond_with self.class.resource
      end
    end
  end

  let(:resource_class) do
    Class.new do
      attr_accessor :params, :default_url_options, :partial, :selector

      def self.params
        [:key1]
      end

      def cacheable?
        false
      end

      def represent!
      end

      def to_hash(options = {})
        { name: "example" }
      end
    end
  end

  let(:resource) do
    resource_class.new
  end

  let(:hash) do
    { name: "example" }
  end

  let(:env) do
    {
      "HTTP_ACCEPT" => "application/json",
      "PATH_INFO" => "/",
      "REQUEST_METHOD" => "GET",
      "rack.input" => "",
    }
  end

  describe "#display" do
    it "calls resource.represent! method" do
      resource.should_receive(:represent!)
      controller.action(:show).call(env)
    end

    context "with resource which changes depending on controller.params" do
      before do
        env["QUERY_STRING"] = "key1=value1&key2=value2"
      end

      let(:resource_class) do
        Class.new(super()) do
          def to_hash(options = {})
            params
          end
        end
      end

      it "allows resource to refer to specified params" do
        controller.action(:show).call(env)[2].body.should == { key1: "value1" }.to_json
      end
    end

    context "with non-mappable resource" do
      it "renders a given resource as a Hash" do
        controller.action(:show).call(env)[2].body.should == { name: "example" }.to_json
      end
    end

    context "with mappable resource" do
      let(:resource) do
        [super()]
      end

      it "renders a given resource as an Array of Hashes" do
        controller.action(:show).call(env)[2].body.should == [{ name: "example" }].to_json
      end
    end
  end
end

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
