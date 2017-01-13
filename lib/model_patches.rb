# -*- encoding : utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  User.class_eval do
    validates :address, :presence => {
      :message => _('You must enter an address.')
    }

    validates :address, :length => {
      :maximum => 255,
      :message => _('255 characters is the maximum allowed address length.')
    }

    validate :validate_dob

    def self.internal_admin_user
      user = User.find_by_email(AlaveteliConfiguration::contact_email)
      if user.nil?
        password = PostRedirect.generate_random_token
        user = User.new(
          :name => 'Internal admin user',
          :email => AlaveteliConfiguration.contact_email,
          :password => password,
          :password_confirmation => password,
          :address => 'Generated in User.internal_admin_user',
          :dob => '1/1/1900'
        )
        user.save!
      end

      user
    end

    private

    def validate_dob
      if !dob.is_a? Date
        errors.add(:dob, _("DOB is not a valid date")) if ((DateTime.parse(dob) rescue ArgumentError) == ArgumentError)
      end
    end
  end
end
