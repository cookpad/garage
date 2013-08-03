require "spec_helper"

describe Garage::ControllerHelper do
  let(:controller) do
    controller = Object.new
    controller.extend described_class
    controller
  end

  describe "#extract_datetime_query" do
    before do
      controller.stub(:params => params)
    end

    let(:params) do
      {}
    end

    context "without corresponding key" do
      it "returns nil" do
        controller.send(:extract_datetime_query, "created").should == nil
      end
    end

    context "with corresponding key" do
      let(:params) do
        {
          "created.lte" => 0,
          "created.gte" => 0,
          "updated.lte" => 0,
          "updated.gte" => 0,
        }
      end

      it "returns query Hash with matched operator => time" do
        controller.send(:extract_datetime_query, "created").should == {
          :lte => Time.zone.at(0),
          :gte => Time.zone.at(0),
        }
      end
    end
  end

  describe "#requested_by?" do
    before do
      controller.stub(current_resource_owner: current_resource_owner)
    end

    let(:user) do
      double(id: 1)
    end

    let(:current_resource_owner) do
      double(id: 1)
    end

    context "without current resource owner" do
      let(:current_resource_owner) do
        nil
      end

      it "returns false" do
        controller.should_not be_requested_by user
      end
    end

    context "with different users" do
      let(:current_resource_owner) do
        double(id: 2)
      end

      it "returns false" do
        controller.should_not be_requested_by user
      end
    end

    context "with different classes" do
      before do
        current_resource_owner.stub(class: Class.new)
      end

      it "returns false" do
        controller.should_not be_requested_by user
      end
    end

    context "with same user" do
      it "returns true" do
        controller.should be_requested_by user
      end
    end
  end
end
