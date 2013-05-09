require "spec_helper"

describe Garage::ControllerHelper do
  let(:controller) do
    controller = Object.new
    controller.extend described_class
    controller.stub(:params => params)
    controller
  end

  describe "#extract_datetime_query" do
    context "without corresponding key" do
      let(:params) do
        {}
      end

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
      before do
      end

      it "returns query Hash with matched operator => time" do
        controller.send(:extract_datetime_query, "created").should == {
          :lte => Time.zone.at(0),
          :gte => Time.zone.at(0),
        }
      end
    end
  end
end
