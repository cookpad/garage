require 'spec_helper'

describe '/docs/resources/post' do
  let(:application) { create :application }
  let(:alice)     { create(:user )}
  let!(:the_post) { create(:post, user: alice, title: "Foo") }

  before do
    uid = application.uid
    Garage.configuration.docs.console_app_uid = uid
  end

  it 'has link to the post in examples' do
    get '/docs/resources/post'
    body.should match /location=%2Fposts%2F#{the_post.id}/
  end
end
