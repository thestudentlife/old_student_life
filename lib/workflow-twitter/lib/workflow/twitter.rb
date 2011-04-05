require 'twitter'
require 'yaml'

module Workflow
  module Twitter
    def self.update(message)
      c = Twitter::Client.new
      c.update message
    end
    
    def self.remaining_hits
      c = Twitter::Client.new
      c.rate_limit_status.remaining_hits
    end
    
    class Railtie < Rails::Railtie
      initializer 'workflow.twitter.load_config' do
        config_file = "#{Rails.root}/config/twitter.yml"
        
        if File.exists? config_file
          conf = YAML.load_file(config_file)
  
          Twitter.configure do |c|
            c.consumer_key = conf["consumer_key"]
            c.consumer_secret = conf["consumer_secret"]
            c.oauth_token = conf["oauth_token"]
            c.oauth_token_secret = conf["oauth_token_secret"]
          end
        end
      end
    end
  end
end