Sp2db.config do |conf|
  conf.credential = "path to credential file OR Json string OR Hash" # required
  conf.spreadsheet_id = "SHEET ID" # Required

  # Other regular optional config

  # export_location: Location for exported files, default:  "db/spreadsheets"
  # import_strategy: Specify import strategy, default: :truncate_all, Other: :fill_empty, :skip, :overwrite

  # exception_handler: Import behavior when exception occurs
  # Default:
  # config.exception_handler.row_import_error = :raise
  # config.exception_handler.table_import_error = :raise

  # download_before_import: Export spreadsheet to csv automaticaly when import to database, default: false

  # non_model_tables: define non model sheet for file exporting only
  # Example:
  # config.non_model_tables = {
  #   table_names: {
  #     sheet_name: "sheet_name"
  #   }
  # }

  # default_find_columns: Default find column to update, default: [:id]

end
