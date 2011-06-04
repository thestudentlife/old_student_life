source 'http://rubygems.org'

gem 'rack', '~> 1.2.2' # Security fix
gem 'rails', '3.0.5'

gem 'devise', :git => 'git://github.com/plataformatec/devise.git', :tag => 'v1.3.4'
gem 'sl_data', :path => 'lib/sl_data'
gem 'sl_markup', :path => 'lib/sl_markup'
gem 'sl_webdav', :path => 'lib/sl_webdav'
gem 'sl_workflow_data', :path => 'lib/sl_workflow_data'
gem 'workflow-conductor', :require => 'workflow/conductor', :path => 'lib/workflow-conductor'
gem 'workflow-forms', :require => 'workflow/forms', :path => 'lib/workflow-forms'
gem 'workflow-twitter', :require => 'workflow/twitter', :path => 'lib/workflow-twitter'

gem 'sunspot_rails', '~> 1.2.1'

group :development do
	gem 'sqlite3-ruby', :require => 'sqlite3'
end
group :production do
	gem 'mysql2'
end

# workflow
gem 'paperclip', '~> 2.3'
gem 'unicorn'
gem "htmldiff", :git => "git://github.com/mikemaltese/htmldiff.git"
gem "high_voltage"
gem "responders"
gem "inherited_resources", '~> 1.2.1'
gem 'yaml_db'
gem 'memcache-client'
