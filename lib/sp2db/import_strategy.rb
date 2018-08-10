module Sp2db
  module ImportStrategy

    extend self

    # Add strategy
    def add label, strategy=nil, &block
      strategy ||= Class.new(Base)
      strategy.class_eval(&block) if block_given?
      strategies[label.to_sym] = strategy
    end

    # @!strategies [ro] strategies
    def strategies
      @strategies ||= {}.with_indifferent_access
    end

    def strategy_by_name name
      strategies[name.to_s] || raise("Invalid import strategy: #{name}")
    end

    def labels
      strategies.keys.map(&:to_sym)
    end

    def valid! s
      raise "Unsuported strategies" unless labels.include?(s.to_sym)
      true
    end

    class Base

      include Logging

      attr_accessor :table, :rows, :result

      delegate :model,
               :find_columns,
                to: :table

      def initialize table, rows
        self.table = table
        self.rows = rows
      end

      def result
        @result ||= {
          records: [],
          errors: [],
        }.with_indifferent_access
      end

      def errors
        result[:errors]
      end

      def records
        result[:records]
      end

      def before_import
        logger.debug "Run before import table: #{self.table.name}"
      end

      def find_db_row row
        if find_columns.present?
          cond = {}
          find_columns.each do |col|
            cond[col] = row[col]
          end
          model.find_by cond
        else
          nil # nil to skip
        end
      end

      def set_record_value record, row
        row.each do |k, v|
          record.send("#{k}=", v) if record.respond_to?("#{k}=")
        end
        record
      end

      def import_row row
        record = find_db_row(row) || model.new(row)
        record = set_record_value record, row
        return unless record.present?
        record.save! if record.new_record? || record.changed?
        record
      end

      def after_import
        logger.debug "Run after import table: #{self.table.name}"
      end

      def import
        logger.debug "Start import table: #{self.table.name}"
        ActiveRecord::Base.transaction(requires_new: true) do
          before_import
          rows.each do |row|
            row = row.clone
            begin
              table.before_import_row row
              record = import_row row
              records << record
              table.after_import_row record
            rescue ActiveRecord::ActiveRecordError => e
              logger.error e.try(:message)
              errors << {
                message: e.try(:message),
                exception: e,
                row: row,
                table: table.name,
              }
              next unless ExceptionHandler.row_import_error e
            end
          end
          after_import
          table.after_import_table result
          logger.debug "Import finished: #{self.table.name}"
          return result
        end

      end

    end
  end

  ImportStrategy.add :truncate_all do
    def before_import
      logger.info "Truncte all data: #{self.table.name}"
      model.all.delete_all
    end

    def find_db_row row
      nil
    end
  end

  ImportStrategy.add :overwrite do
  end

  ImportStrategy.add :fill_empty do
    def set_record_value record, row
      row.each do |k, v|
        record.send("#{k}=", v) if record.send(k).blank?
      end
      record
    end
  end

  ImportStrategy.add :skip do
    def set_record_value record, row
      record
    end
  end
end
