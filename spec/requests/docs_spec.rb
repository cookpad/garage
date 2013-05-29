require 'spec_helper'

describe '/docs/resources' do
  let(:application) { create :application }

  before do
    uid = application.uid
    Garage.configuration.docs.console_app_uid = uid
  end

  context 'without any headers' do
    it 'should serve the overview page in default' do
      get '/docs/resources'
      body.should match /This is overview/
    end
  end

  context 'with lang= parameter' do
    it 'should serve the overview page in Japanese' do
      get '/docs/resources?lang=ja'
      body.should match /Japanese page/
    end
  end

  context 'with Accept-Language: ja header' do
    before do
      header 'Accept-Language', 'ja'
    end

    it 'should serve the overview page in Japanese' do
      get '/docs/resources'
      body.should match /Japanese page/
    end

    context 'with lang=en override' do
      it 'should serve the overview page in English' do
        get '/docs/resources?lang=en'
        body.should match /This is overview/
      end
    end
  end

  context 'with unsupported Accept-Language language' do
    before do
      header 'Accept-Language', 'zh'
    end

    it 'should serve the overview page in default language' do
      get '/docs/resources'
      body.should match /This is overview/
    end
  end
end
