require "spec_helper"

describe "Location response header from #create endpoint", type: :request do
  include RestApiSpecHelper
  include AuthenticatedContext

  before do
    params[:title] = "dummy"
  end

  let(:method) do
    'post'
  end

  let(:scopes) do
    "write_post"
  end

  context 'when URL pattern for #show exists' do
    let(:path) do
      '/posts'
    end

    it 'returns Location header for #show endpoint' do
      subject
      expect(response.status).to eq(201)
      expect(response.headers['Location']).to eq(url_for(controller: 'posts', action: 'show', id: Post.last.id))
    end
  end

  context 'when URL pattern for #show does not exist' do
    let(:path) do
      '/location_test_posts'
    end

    it 'returns Location header for #show endpoint' do
      subject
      expect(response.status).to eq(201)
      expect(response.headers['Location']).to be_nil
    end
  end
end
