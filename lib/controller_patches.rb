# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do


    AdminRequestController.class_eval do

        def generate_upload_url
            info_request = InfoRequest.find(params[:id])

            if params[:incoming_message_id]
                incoming_message = IncomingMessage.find(params[:incoming_message_id])
                email = incoming_message.from_email
                name = incoming_message.safe_mail_from || info_request.public_body.name
            else
                email = info_request.public_body.request_email
                name = info_request.public_body.name
            end

            user = User.find_user_by_email(email)
            if not user
                user = User.new(:name => name,
                                :email => email,
                                :password => PostRedirect.generate_random_token,
                                :dob => '1/1/1900')
                user.save!
            end

            if !info_request.public_body.is_foi_officer?(user)
                flash[:notice] = user.email + " is not an email at the domain @" + info_request.public_body.foi_officer_domain_required + ", so won't be able to upload."
                redirect_to request_admin_url(info_request)
                return
            end

            # Bejeeps, look, sometimes a URL is something that belongs in a controller, jesus.
            # XXX hammer this square peg into the round MVC hole - should be calling main_url(upload_response_url())
            post_redirect = PostRedirect.new(
                :uri => main_url(upload_response_url(:url_title => info_request.url_title, :only_path => true)),
                :user_id => user.id)
            post_redirect.save!
            url = main_url(confirm_url(:email_token => post_redirect.email_token, :only_path => true))

            flash[:notice] = ('Send "' + name + '" &lt;<a href="mailto:' + email + '">' + email + '</a>&gt; this URL: <a href="' + url + '">' + url + "</a> - it will log them in and let them upload a response to this request.").html_safe
            redirect_to request_admin_url(info_request)
        end

    end

    RequestController.class_eval do

        def authenticate_attachment
            # Test for hidden
            incoming_message = IncomingMessage.find(params[:incoming_message_id])
            body = incoming_message.get_body_for_html_display
            raise ActiveRecord::RecordNotFound.new("Message not found") if incoming_message.nil?
            # This line is a temporary measure to prevent display of attachments that include
            # the requester's physical address - if the body looks like it contains an address,
            # hide the attachment.
            raise ActiveRecord::RecordNotFound.new("Attachment is hidden") if body =~ /Your name and address: /
            if !incoming_message.info_request.user_can_view?(authenticated_user)
                @info_request = incoming_message.info_request # used by view
                render :template => 'request/hidden', :status => 410 # gone
            end
            # Is this a completely public request that we can cache attachments for
            # to be served up without authentication?
            if incoming_message.info_request.all_can_view?
                @files_can_be_cached = true
            end
        end

    end

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
