require "google_drive"
require "sp2db/logging"

require "sp2db/config"
require "sp2db/client"
require "sp2db/exception_handler"
require "sp2db/import_strategy"
require "sp2db/base_table"
require "sp2db/non_model_table"
require "sp2db/model_table"
require "sp2db/spreadsheet"
require "sp2db/import_concern"
require "sp2db/version"

module Sp2db

  include Logging
  extend self

  # @!attribute [rw] config
  def config
    @config ||= Config.new
    yield @config if block_given?
    @config
  end

  # Reload all configs and sessions
  def reload!
    @client = nil
  end

  # return [Gclient]
  def client c=nil
    Client.new
  end

  # Default sheet
  def spreadsheet
    client.spreadsheet Sp2db.config.spreadsheet_id
  end

  delegate :sp_to_csv,
           :sp_to_db,
           :csv_to_db,
           to: BaseTable
end

class Railtie < Rails::Railtie
  railtie_name :sp2db

  rake_tasks do
    load "tasks/sp2db.rake"
  end
end
