require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminRequestController do

  describe 'POST generate_upload_url' do

    it 'creates a user for the authority with a dummy date of birth' do
      user = FactoryGirl.create(:user, :dob => '2/2/2000')
      info_request = FactoryGirl.create(:info_request, :user => user)
      post :generate_upload_url, :id => info_request.id
      authority_user = User.where(:email => info_request.public_body.request_email).first
      expect(authority_user.dob).to eq(Date.new(1900, 1, 1 ))
    end

  end

end
