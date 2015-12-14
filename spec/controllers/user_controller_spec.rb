require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserController do

  describe 'GET signchangeaddress' do

    render_views

    it "redirects an anonymous request to the signin page" do
      get :signchangeaddress
      expect(response).to redirect_to(signin_path(:token => PostRedirect.last.token))
    end

    it "displays the address template" do
      user = FactoryGirl.create(:user, :dob => '2/2/2000')
      session[:user_id] = user.id
      get :signchangeaddress
      expect(response).to render_template('signchangeaddress')
    end

    context 'when supplied with the  "submitted_signchangeaddress_do" param' do

        it "sets the user's address" do
          user = FactoryGirl.create(:user, :dob => '2/2/2000')
          session[:user_id] = user.id
          get :signchangeaddress, {:submitted_signchangeaddress_do => 1,
                                   :signchangeaddress =>
                                      {:new_address => 'some address' }}
          expect(User.where(:id => user.id).first.address).to eq("some address")
        end

        it 'shows a notice' do
          user = FactoryGirl.create(:user, :dob => '2/2/2000')
          session[:user_id] = user.id
          get :signchangeaddress, {:submitted_signchangeaddress_do => 1,
                                   :signchangeaddress =>
                                      {:new_address => 'some address' }}
          message = 'You have now changed your address used on Alaveteli'
          expect(flash[:notice]).to eq(message)
        end

        it "redirects to the user's page" do
          user = FactoryGirl.create(:user, :dob => '2/2/2000')
          session[:user_id] = user.id
          get :signchangeaddress, {:submitted_signchangeaddress_do => 1,
                                   :signchangeaddress =>
                                      {:new_address => 'some address' }}
          expected_url = show_user_path(:url_name => user.url_name)
          expect(response).to redirect_to(expected_url)
        end

    end

  end

end