module Sp2db
  class NonModelTable < BaseTable

    def config
      @config ||= Sp2db.config.non_model_tables[self.name] || super
    end

    class << self
      def all_tables
        Sp2db.config.non_model_tables.map do |name, config|
          self.new name: name
        end
      end
    end

  end
end
