require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublicBodyController do

  describe 'GET list' do

    it 'should assign the czech alphabet for the template' do
      get :list
      expect(assigns[:czech_alphabet]).to_not be_nil
    end

  end

end