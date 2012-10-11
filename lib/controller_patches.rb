# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
require 'dispatcher'
Dispatcher.to_prepare do
    # Example adding an instance variable to the frontpage controller
    UserController.class_eval do

        # Create new account form.  Completely override core form
        def signup
            work_out_post_redirect
            @request_from_foreign_country = country_from_ip != Configuration::iso_country_code
            # Make the user and try to save it
            @user_signup = User.new(params[:user_signup])
            error = false
            if @request_from_foreign_country && !verify_recaptcha
                flash.now[:error] = _("There was an error with the words you entered, please try again.")
                error = true
            end
            if error || !@user_signup.valid?
                # Show the form
                render :action => 'sign'
            else
                user_alreadyexists = User.find_user_by_email(params[:user_signup][:email])
                if user_alreadyexists
                    already_registered_mail user_alreadyexists
                    return
                else
                    # New unconfirmed user
                    @user_signup.email_confirmed = false
                    @user_signup.save!
                    send_confirmation_mail @user_signup
                    return
                end
            end
        end

        def signchangeaddress
            if not authenticated?(
                    :web => _("To change your address used on {{site_name}}",:site_name=>site_name),
                    :email => _("Then you can change your address used on {{site_name}}",:site_name=>site_name),
                    :email_subject => _("Change your address used on {{site_name}}",:site_name=>site_name)
                   )
                # "authenticated?" has done the redirect to signin page for us
                return
            end

            if !params[:submitted_signchangeaddress_do]
                render :action => 'signchangeaddress'
                return
            else
                logger.debug @user.address = params[:signchangeaddress][:new_address]
                @user.save!

                # Now clear the circumstance
                flash[:notice] = _("You have now changed your address used on {{site_name}}",:site_name=>site_name)
                redirect_to user_url(@user)
            end
        end

        def signchangedob
            if not authenticated?(
                    :web => _("To change your dob used on {{site_name}}",:site_name=>site_name),
                    :email => _("Then you can change your dob used on {{site_name}}",:site_name=>site_name),
                    :email_subject => _("Change your dob used on {{site_name}}",:site_name=>site_name)
                   )
                # "authenticated?" has done the redirect to signin page for us
                return
            end

            if !params[:submitted_signchangedob_do]
                render :action => 'signchangedob'
                return
            else
                @user.dob = params[:signchangedob][:dob]
                if not @user.valid?
                    @signchangedob = @user
                    render :action => 'signchangedob'
                else
                    @user.save!
                    # Now clear the circumstance
                    flash[:notice] = _("You have now changed your dob used on {{site_name}}",:site_name=>site_name)
                    redirect_to user_url(@user)
                end
            end
        end
    end
end
