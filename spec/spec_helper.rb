# If defined, ALAVETELI_TEST_THEME will be loaded in
# config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'ipvtheme'

require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))

RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.definition_file_paths << File.expand_path(File.join(File.dirname(__FILE__), 'factories'))
    FactoryGirl.reload
  end
end
