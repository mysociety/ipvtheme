# Install hook code here

plugin_path = File.expand_path(File.join(File.dirname(__FILE__), "public"))
main_app_path = File.join(RAILS_ROOT, 'public', 'ipvtheme')

# If the symlink to be created exists, warn the user and do nothing
if File.exists?(main_app_path)
	puts "WARNING: #{main_app_path} already exists, the symbolic link won't be created"
else # Create symlink
	begin
		print "Creating symbolic link from #{main_app_path} to #{plugin_path}... "
		File.symlink(plugin_path, main_app_path)
		puts "done"
	rescue NotImplementedError
		puts "failed: symbolic links not supported"
	end
end

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
require 'commands/runner'

regexp = '([^=]*)={8,}.*\n(?:.*?#.*?: ?.*\n){3,}.*={8,}'
rule = CensorRule.find_by_text(regexp)
if rule.nil?
    Rails.logger.info("Creating new censor rule: /#{regexp}/")
    CensorRule.create(:text => regexp,
                      :replacement => '\1[redacted]',
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Added automatically by ipvtheme')
end

