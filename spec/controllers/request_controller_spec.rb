require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RequestController do

  describe 'GET get_attachment' do

    it "returns RecordNotFound if the message body contains the
        requester's details" do
        user = FactoryGirl.create(:user, :dob => '2/2/2000')
        info_request = FactoryGirl.create(:info_request, :user => user)
        incoming_message = FactoryGirl.create(:incoming_message_with_html_attachment,
                                              :info_request => info_request)

        incoming_message.foi_attachments.each do |a|
          a.body = "Your name and address: Some name"
          a.save!
        end

        expect{ get :get_attachment, :incoming_message_id => incoming_message.id,
                    :id => info_request.id,
                    :part => 2,
                    :file_name => 'interesting.html',
                    :skip_cache => 1 }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

end