module Sp2db
  module ImportConcern
    extend ActiveSupport::Concern

    included do
      Sp2db::ModelTable.add_models self
    end

    module ClassMethods

      def sp2db_options *args, &block
        if args.first.is_a?(Hash)
          args.first.each do |k, v|
            send "sp2db_#{k}", v
          end
        else
          meth = args.shift
          send "sp2db_#{meth}", *args, &block
        end
      end

      def sp2db_config
        @sp2db_config ||= {}.with_indifferent_access
      end

      [:find_columns, :required_columns].each do |opt|
        define_method "sp2db_#{opt}" do |*cols|
          cols = cols&.flatten
          sp2db_config[opt] = cols.map(&:to_sym) if cols.present?
          sp2db_config[opt]
        end
      end

      def sp2db_priority pr=nil
        sp2db_config[:priority] = pr if pr.present?
        sp2db_config[:priority]
      end

      def sp2db_import_strategy s=nil
        if s.present?
          s = s.to_sym
          ImportStrategy.valid! s
          sp2db_config[:import_strategy] = s
        end

        sp2db_config[:import_strategy]
      end

      def sp2db_sheet_name s=nil
        sp2db_config[:sheet_name] = s.to_sym if s.present?
        sp2db_config[:sheet_name]
      end

      def sp2db_header_row s=nil
        sp2db_config[:header_row] = s if s.present?
        sp2db_config[:header_row]
      end

      def sp2db_spreadsheet_id s=nil
        sp2db_config[:spreadsheet_id] = s if s.present?
        sp2db_config[:spreadsheet_id]
      end

      [
        :data_transform,
        :process_data,
        :before_import_row,
        :after_import_row,
        :after_import_table,
      ].each do |option|
        define_method "sp2db_#{option}" do |method=nil, &block|
          sp2db_config[option] = if method.present?
            method.is_a?(Proc) ? method : method.to_sym
          elsif block.present?
            block
          else
            sp2db_config[option]
          end
        end
      end

    end
  end
end
