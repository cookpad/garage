require "spec_helper"

describe "Primitive Resource" do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /echo" do
    it "returns a Hash" do
      is_expected.to eq(200)
      expect(response.body).to be_json(message: "Hello World")
    end
  end
end
