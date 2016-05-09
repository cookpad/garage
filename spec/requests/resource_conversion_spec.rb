require 'spec_helper'

RSpec.describe 'Resource conversion' do
  include AuthenticatedContext
  let(:header) { { Accept: 'application/json' } }

  describe 'RestfulActions' do
    it 'uses `XxxResource` class as a default resource class' do
      FactoryGirl.create(:campaign)

      get '/campaigns', {}, header
      expect(response.status).to eq(200)
      expect(response.body).to be_json_including(
        [
          { 'id' => Integer },
        ]
      )
    end

    it 'uses `Xxx` class as a fallback' do
      FactoryGirl.create(:post)

      get '/posts', {}, header
      expect(response.status).to eq(200)
      expect(response.body).to be_json_including(
        [
          { 'id' => Integer, 'title' => String },
        ]
      )
    end
  end
end
