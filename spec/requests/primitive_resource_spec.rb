require "spec_helper"

describe "Primitive Resource" do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /echo" do
    it "returns a Hash" do
      should == 200
      response.body.should be_json(message: "Hello World")
    end
  end
end
