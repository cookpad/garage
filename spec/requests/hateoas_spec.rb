require "spec_helper"

describe "HATEOAS" do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:id) do
    user.id
  end

  describe "GET /users/:id" do
    context "with valid condition" do
      it "returns _links fields" do
        should == 200
        response.body.should be_json_including(
          _links: {
            self: {
              href: path,
            }
          },
        )
      end
    end

    context "with following" do
      it "returns chained links" do
        should == 200

        get JSON.parse(response.body)["_links"]["self"]["href"], params, env
        response.status.should == 200

        get JSON.parse(response.body)["_links"]["self"]["href"], params, env
        response.status.should == 200

        get JSON.parse(response.body)["_links"]["posts"]["href"], params, env
        response.status.should == 200
      end
    end
  end
end
