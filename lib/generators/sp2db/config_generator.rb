module Sp2db
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc 'takenoko_config.rb'

      def copy_config_file
        template 'sp2db.rb', 'config/initializers/sp2db.rb'
      end
    end
  end
end
