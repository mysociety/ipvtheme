# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
require 'dispatcher'
Dispatcher.to_prepare do
    User.class_eval do
        validate :validate_dob
        def validate_dob
            if !dob.is_a? Date
                errors.add(:dob, _("DOB is not a valid date")) if ((DateTime.parse(dob) rescue ArgumentError) == ArgumentError)
            end
        end
    end        
end
