# -*- encoding : utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do

  AdminRequestController.class_eval do

    def generate_upload_url

      if params[:incoming_message_id]
        incoming_message = IncomingMessage.find(params[:incoming_message_id])
        email = incoming_message.from_email
        name = incoming_message.safe_mail_from || @info_request.public_body.name
      else
        email = @info_request.public_body.request_email
        name = @info_request.public_body.name
      end

      user = User.find_user_by_email(email)
      if not user
        user = User.new(:name => name,
                        :email => email,
                        :password => PostRedirect.generate_random_token,
                        :address => 'Generated in generate_upload_url',
                        :dob => '1/1/1900')
        user.save!
      end

      if !@info_request.public_body.is_foi_officer?(user)
        flash[:notice] = user.email + " is not an email at the domain @" + @info_request.public_body.foi_officer_domain_required + ", so won't be able to upload."
        redirect_to admin_request_url(@info_request)
        return
      end

      post_redirect = PostRedirect.new(
        :uri => upload_response_url(:url_title => @info_request.url_title),
        :user_id => user.id)
      post_redirect.save!
      url = confirm_url(:email_token => post_redirect.email_token)

      flash[:notice] = ("Send \"#{CGI.escapeHTML(name)}\" &lt;<a href=\"mailto:#{email}\">#{email}</a>&gt; this URL: <a href=\"#{url}\">#{url}</a> - it will log them in and let them upload a response to this request.").html_safe
      redirect_to admin_request_url(@info_request)
    end

  end

  RequestController.class_eval do

    def make_request_zip(info_request, file_path)
      Zip::ZipFile.open(file_path, Zip::ZipFile::CREATE) do |zipfile|
        file_info = make_request_summary_file(info_request)
        zipfile.get_output_stream(file_info[:filename]) { |f| f.puts(file_info[:data]) }
        message_index = 0
        info_request.incoming_messages.each do |message|
          next unless can?(:read, message)
          message_index += 1
          message.get_attachments_for_display.each do |attachment|
            filename = "#{message_index}_#{attachment.url_part_number}_#{attachment.display_filename}"
            body = message.apply_masks(attachment.default_body, attachment.content_type)
            next if body =~ /Your name and address: /
            zipfile.get_output_stream(filename) do |f|
              f.puts(body)
            end
          end
        end
      end
    end

    def authenticate_attachment
      # Test for hidden
      incoming_message = IncomingMessage.find(params[:incoming_message_id])
      body = incoming_message.get_body_for_html_display
      raise ActiveRecord::RecordNotFound.new("Message not found") if incoming_message.nil?
      # This line is a temporary measure to prevent display of attachments that include
      # the requester's physical address - if the body looks like it contains an address,
      # hide the attachment.
      raise ActiveRecord::RecordNotFound.new("Attachment is hidden") if body =~ /Your name and address: /

      if cannot?(:read, incoming_message.info_request)
        @info_request = incoming_message.info_request # used by view
        return render_hidden
      end
      if cannot?(:read, incoming_message)
        @incoming_message = incoming_message # used by view
        return render_hidden('request/hidden_correspondence')
      end
      # Is this a completely public request that we can cache attachments for
      # to be served up without authentication?
      if incoming_message.info_request.prominence(:decorate => true).is_public? &&
        incoming_message.is_public?
        @files_can_be_cached = true
      end
    end

  end

  # Example adding an instance variable to the frontpage controller
  UserController.class_eval do

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
        if not @user.valid?
          @signchangeaddress = @user
          render :action => 'signchangeaddress'
        else
          @user.save!
          # Now clear the circumstance
          flash[:notice] = _("You have now changed your address used on {{site_name}}",:site_name=>site_name)
          redirect_to user_url(@user)
        end
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

    # Add our extra params to the sanitized list allowed at signup
    def user_params(key = :user)
      params.require(key).permit(:name, :email, :password, :password_confirmation, :dob, :address)
    end

  end

    PublicBodyController.class_eval do

      before_filter :get_czech_alphabet, :only => [:list]

      def get_czech_alphabet
        # incorporate PublicBody.none_starting_with_letter?() to get current, unpredicted state
        @czech_alphabet = ["A","B","C","Č","D","E","F","G","H","I","J","K","L","M","N","O","P","R","Ř","S","Š","T","U","Ú","V","W","Z"]
      end
    end
end
