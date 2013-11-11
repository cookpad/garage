require 'spec_helper'

describe '/webhook/events', type: :request do
  let(:secret) { 'foobar' }
  let(:server_secret) { 'foobar' }

  let(:channel) { 'com.example.HelloWorld' }
  let(:content_type) { 'application/json' }

  let(:signature) {
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), secret, request_body)
  }
  let(:request_body) {
    { channel: channel, messages: [ {id: 1}, {id: 2} ] }.to_json
  }

  before do
    Garage::Webhook.configuration.application_secret = server_secret
  end

  def run
    post '/events', request_body, { 'CONTENT_TYPE' => content_type, 'Ping-Signature' => signature }
  end

  subject {
    run
    status
  }

  context 'without secret set' do
    let(:server_secret) { nil }
    it 'returns 400' do
      should == 400
    end
  end

  context 'without signature' do
    let(:signature) { '' }
    it 'returns 400' do
      should == 400
    end
  end

  context 'with non-matching channel' do
    let(:channel) { 'com.example.FooBar' }
    it 'returns 200' do
      should == 200
    end

    it 'processes no events' do
      HelloWorldEvent.should_not_receive(:new)
      run
    end
  end

  context 'with regular event' do
    it 'returns 200' do
      should == 200
    end

    it 'processes events one by one' do
      proxy = double()
      HelloWorldEvent.stub(:new) { proxy }
      proxy.should_receive(:process).twice
      run
    end
  end

  context 'with batch processing event' do
    it 'returns 200' do
      should == 200
    end

    it 'processes events by batch' do
      HelloWorldEvent.should_receive(:batch_process).once.with(an_instance_of(Array))
      run
    end
  end
end
