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

# if not already created, make a CensorRule that hides personal information
regexp = '([^=]*)={8,}.*\n(?:.*?#.*?: ?.*\n){3,}.*={8,}'
rule = CensorRule.find_by_text(regexp)
if rule.nil?
    Rails.logger.info("Creating new censor rule: /#{regexp}/")
    CensorRule.create!(:text => regexp,
                       :allow_global => true,
                       :replacement => '\1[redacted]',
                       :regexp => true,
                       :last_edit_editor => 'system',
                       :last_edit_comment => 'Added automatically by ipvtheme')
end

