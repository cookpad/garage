require 'spec_helper'

describe Platform2 do
  describe 'HTTP request' do
    context 'without any token' do
      it 'returns 401' do
        get '/echo'
        status.should == 401
      end
    end
  end
end
