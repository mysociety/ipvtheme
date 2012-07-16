THEME_DIR = File.expand_path("../..", __FILE__)
ALAVETELI_DIR = File.expand_path("../../../", THEME_DIR)
THEME_NAME = File.split(THEME_DIR)[1]

class ActionController::Base
    # The following prepends the path of the current theme's views to
    # the "filter_path" that Rails searches when deciding which
    # template to use for a view.  It does so by creating a method
    # uniquely named for this theme.
    path_function_name = "set_view_paths_for_#{THEME_NAME}"
    before_filter path_function_name.to_sym
    send :define_method, path_function_name do
        self.prepend_view_path File.join(File.dirname(__FILE__), "views")
    end
end

# In order to have the theme lib/ folder ahead of the main app one,
# inspired in Ruby Guides explanation: http://guides.rubyonrails.org/plugins.html
%w{ . }.each do |dir|
  path = File.join(File.dirname(__FILE__), dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

# Monkey patch app code
for patch in ['controller_patches.rb', 
              'model_patches.rb', 
              'patch_mailer_paths.rb', 
              'gettext_setup.rb']
    require File.expand_path "../#{patch}", __FILE__
end

$alaveteli_route_extensions << 'custom-routes.rb'

# migration-type stuff

# if not already created, make a CensorRule that hides personal information
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

# DOB and address for users
def column_exists?(table, column)
    # XXX ActiveRecord 3 includes "column_exists?" method on `connection`
    return ActiveRecord::Base.connection.columns(table.to_sym).collect{|c| c.name.to_sym}.include? column
end

if !column_exists?(:users, :dob) || !column_exists?(:users, :address)
    require 'db/migrate/ipvtheme_add_address_and_dob_to_user'
    IpvthemeAddAddressAndDobToUser.up
end

