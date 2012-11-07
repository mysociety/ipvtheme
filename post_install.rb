# This file is executed by the rails-post-deploy script in Alaveteli

# migration-type stuff
# DOB and address for users
def column_exists?(table, column)
    # XXX ActiveRecord 3 includes "column_exists?" method on `connection`
    return ActiveRecord::Base.connection.columns(table.to_sym).collect{|c| c.name.to_sym}.include? column
end

if !column_exists?(:users, :dob) || !column_exists?(:users, :address)
    require File.expand_path '../db/migrate/ipvtheme_add_address_and_dob_to_user', __FILE__
    IpvthemeAddAddressAndDobToUser.up
end

# Create any necessary global Censor rules
require File.expand_path(File.dirname(__FILE__) + '/lib/censor_rules')


