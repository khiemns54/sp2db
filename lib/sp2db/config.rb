module Sp2db
  class Config

    attr_accessor \
                  :credential,
                  :personal_credential,
                  :client_id,
                  :client_secret,
                  :spreadsheet_id,
                  :export_location,
                  :default_file_extention,
                  :import_strategy,
                  :download_before_import,
                  :default_extensions,
                  :exception_handler,
                  :non_model_tables,
                  :default_find_columns


    DEFAULT = {
      personal_credential: "credentials/google_credentials.json",
      import_strategy: :truncate_all,
      export_location: "db/spreadsheets",
      default_file_extention: :csv,
      exception_handler: OpenStruct.new({
        row_import_error: :raise,
        table_import_error: :raise,
      }),
      non_model_tables: {}.with_indifferent_access,
      download_before_import: false,
      default_extensions: :csv,
      default_find_columns: [:id],
    }

    SUPPORTED_EXTENSIONS = [:csv]

    def initialize
      set_default
    end

    def import_strategy=s
      s = s.to_sym
      ImportStrategy.valid! s
      @import_strategy = s
    end

    def export_folder
      FileUtils.mkdir_p export_location
      export_location
    end

    # File name or json string or hash
    def credential=cr
      if File.exist?(cr) && File.file?(cr)
        cr = File.read cr
      end

      @credential = case cr
        when Hash, ActiveSupport::HashWithIndifferentAccess
          cr
        when String
          JSON.parse cr
        else
          raise "Invalid data type"
      end
    end

    def default_find_columns= cols
      @default_find_columns = cols.map &:to_sym
    end

    private

    Google::Apis.logger.level

    def set_default
      DEFAULT.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end
end
