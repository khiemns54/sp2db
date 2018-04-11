module Sp2db
  class ModelTable < BaseTable

    attr_accessor :model,
                  :import_strategy

    def initialize opts={}
      if opts[:name].blank? && opts[:model].present?
        opts[:name] = opts[:model].table_name.to_sym
      end

      super opts

      if self.model.blank?
        if opts[:name].present? && model = self.class.model_find_by(name: opts[:name]) \
           || opts[:sheet_name].present? && model = self.class.model_find_by(sheet_name: opts[:sheet_name])
          self.model = model
        end
      end

      raise "Model cannot be nil" unless self.model.present?
    end

    def active_record?
      true
    end

    def model=m
      raise "Invalid arguments" unless m && m < ActiveRecord::Base
      self.class.add_models m
      @model = m
    end

    def config
      model.try(:sp2db_config) || super
    end

    # Table name
    def name
      @name ||= model.table_name.to_sym
    end

    def import_strategy
      return @import_strategy if @import_strategy.present?
      strategy_name = config[:import_strategy] ||
                        Sp2db.config.import_strategy
      @import_strategy = ImportStrategy.strategy_by_name(strategy_name)
    end

    def to_db data, strategy: nil
      strategy = strategy.present? ? ImportStrategy.strategy_by_name : import_strategy
      strategy = strategy.new self, data
      res = strategy.import
    end

    def sp_to_db opts={}
      data = self.sp_data
      if Sp2db.config.download_before_import
        write_csv to_csv(data)
      end
      to_db data, opts
    end

    def csv_to_db opts={}
      to_db csv_data, opts
    end


    def before_import_row *args, &block
      call_model_sp2db_method __method__, *args, &block
    end

    def after_import_row *args, &block
      call_model_sp2db_method __method__, *args, &block
    end

    def after_import_table *args, &block
      call_model_sp2db_method __method__, *args, &block
    end

    # Tranform data to standard csv format
    def data_transform *args, &block
      if (data = call_model_sp2db_method __method__, *args, &block).present?
        data
      else
        super *args, &block
      end
    end

    def call_process_data *args, &block
      data = if (method = config[:process_data]).is_a?(Symbol)
        call_model_sp2db_method :process_data, *args, &block
      else
        super *args, &block
      end
      data
    end

    private

    def call_model_sp2db_method method_name, *args, &block
      if (method = config[method_name.to_sym]).present?
        if method.is_a?(Proc)
          method.call(*args, &block)
        else
          model.send method, *args, &block
        end
      end
    end

    class << self

      def all_models
        @all_models ||= {}.with_indifferent_access
      end

      def model_find_by name: nil, sheet_name: nil
        if name.present?
          all_models[name]
        elsif sheet_name.present?
          all_models.values.find do |model|
            model.try(:sp2db_sheet_name) == sheet_name
          end
        else
          raise "Invalid arguments"
        end
      end

      def add_models *models
        models.each do |m|
          m = Object.const_get(m) if m.is_a?(String) || m.is_a?(Symbol)
          raise "Invalid model" unless m.is_a?(Class) && m < ActiveRecord::Base
          self.all_models[m.table_name] ||= m
        end
      end

      def all_tables
        all_models.map do |name, model|
          self.new name: name, model: model
        end
      end

      def sp_to_db *table_names
        to_db table_by_names(*table_names), :sp
      end

      def csv_to_db *table_names
        to_db table_by_names(*table_names), :csv
      end

      def to_db tables, source=:sp
        res = []
        ActiveRecord::Base.transaction(requires_new: true) do
          tables.each do |tb|
            begin
              res << tb.send("#{source}_to_db")
            rescue ActiveRecord::ActiveRecordError => e
              next if ExceptionHandler.table_import_error(e)
            end
          end
        end

        res
      end
    end
  end
end
