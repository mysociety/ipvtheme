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

  describe 'GET signchangedob' do

    render_views


    it "redirects an anonymous request to the signin page" do
      get :signchangedob
      expect(response).to redirect_to(signin_path(:token => PostRedirect.last.token))
    end

    it "displays the dob template" do
      user = FactoryGirl.create(:user, :dob => '2/2/2000')
      session[:user_id] = user.id
      get :signchangedob
      expect(response).to render_template('signchangedob')
    end

    context 'when supplied with the  "submitted_signchangedob_do" param' do

        it "sets the user's dob" do
          user = FactoryGirl.create(:user, :dob => '2/2/2000')
          session[:user_id] = user.id
          get :signchangedob, {:submitted_signchangedob_do => 1,
                               :signchangedob =>
                                 {:dob => '1/1/1900' }}
          expect(User.where(:id => user.id).first.dob).to eq(Date.new(1900, 1, 1))
        end

      context 'when the dob param is valid' do

          it 'shows a notice' do
            user = FactoryGirl.create(:user, :dob => '2/2/2000')
            session[:user_id] = user.id
            get :signchangedob, {:submitted_signchangedob_do => 1,
                                 :signchangedob =>
                                   {:dob => '1/1/1900' }}
            message = 'You have now changed your dob used on Alaveteli'
            expect(flash[:notice]).to eq(message)
          end

          it "redirects to the user's page" do
            user = FactoryGirl.create(:user, :dob => '2/2/2000')
            session[:user_id] = user.id
            get :signchangedob, {:submitted_signchangedob_do => 1,
                                 :signchangedob =>
                                   {:dob => '1/1/1900' }}
            expected_url = show_user_path(:url_name => user.url_name)
            expect(response).to redirect_to(expected_url)
          end

        end

        context 'when the dob param is not valid' do


          it "displays the dob template" do
            user = FactoryGirl.create(:user, :dob => '2/2/2000')
            session[:user_id] = user.id
            get :signchangedob, {:submitted_signchangedob_do => 1,
                                 :signchangedob =>
                                   {:dob => 'notadate' }}
            expect(response).to render_template('signchangedob')
          end

        end

    end

  end

end