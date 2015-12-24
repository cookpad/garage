require "spec_helper"

describe Garage::OptionalResponseBodyResponder do
  before do
    controller.responder = responder
    controller.resource_options = resource_options
    env["REQUEST_METHOD"] = "GET"
  end

  let(:responder) do
    Class.new(ActionController::Responder) do
      include Garage::OptionalResponseBodyResponder
    end
  end

  let(:controller) do
    Class.new(ActionController::Base) do
      respond_to :json

      class << self
        attr_accessor :resource, :resource_options

        def name
          "ExamplesController"
        end
      end

      def show
        respond_with({ key1: "value1" }, respond_with_resource_options)
      end

      private

      def respond_with_resource_options
        self.class.resource_options
      end
    end
  end

  let(:resource_options) do
    { location: "/" }
  end

  let(:env) do
    {
      "HTTP_ACCEPT" => "application/json",
      "PATH_INFO" => "/",
      "REQUEST_METHOD" => "GET",
      "rack.input" => "",
    }
  end

  describe "#api_behavior" do
    it "GET request" do
      env["REQUEST_METHOD"] = "GET"
      controller.action(:show).call(env)[0].should == 200
    end

    it "POST request" do
      env["REQUEST_METHOD"] = "POST"
      controller.action(:show).call(env)[0].should == 201
    end

    it "PATCH request" do
      env["REQUEST_METHOD"] = "PATCH"
      controller.action(:show).call(env)[0].should == 204
    end

    it "PUT request" do
      env["REQUEST_METHOD"] = "PUT"
      controller.action(:show).call(env)[0].should == 204
    end

    it "DELETE request" do
      env["REQUEST_METHOD"] = "DELETE"
      controller.action(:show).call(env)[0].should == 204
    end

    context "with response body" do
      let(:resource_options) do
        super().merge({
          patch: { body: true },
          put: { body: true },
          delete: { body: true },
        })
      end

      it "PATCH request" do
        env["REQUEST_METHOD"] = "PATCH"
        controller.action(:show).call(env)[0].should == 200
      end

      it "PUT request" do
        env["REQUEST_METHOD"] = "PUT"
        controller.action(:show).call(env)[0].should == 200
      end

      it "DELETE request" do
        env["REQUEST_METHOD"] = "DELETE"
        controller.action(:show).call(env)[0].should == 200
      end
    end
  end
end
