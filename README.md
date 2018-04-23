# Sp2db

Google Spreadsheet import tool for Rails app.

## Installation

```ruby
gem 'sp2db'
```

## Basic usage

### Initialized

```bash
bundle exec rails sp2db:config
```

### In model
```ruby
class ExampleModel < ApplicationRecord

  include Sp2db::ImportConcern

end
```

### Import task

For single table or multiple tables
```bash
# Import spreadsheet to database directy
bundle exec rake sp2db:sp_to_db[table1,table2]

# Export spreadsheet to csv then import to database. Suite for data version control
bundle exec rake sp2db:sp_to_csv[table1,table2]
bundle exec rake sp2db:csv_to_db[table1,table2]
```

For all tables
```bash
bundle exec rake sp2db:sp_to_db
# Or
bundle exec rake sp2db:sp_to_csv
bundle exec rake sp2db:csv_to_db
```

## Advanced usage

### Model config

Use sp2db_options or sp2db_`option_name` to add more config to model table

Example
```
class ExampleModel < ApplicationRecord
  include Sp2db::ImportConcern

  sp2db_options spreadsheet_id: "ANOTHER SHEET ID",
                import_strategy: :overwrite
                ...
end
```

Other options:
* find_columns: Columns to find existed record, default: [:id]
* required_columns: Columns which values must be present to be a valid row, Example: [:name, title]
* priority: table priority for import, default: 0
* import_strategy: Import strategy
* sheet_name: work sheet name
* spreadsheet_id: Spreadsheet id, use to overwrite default spreadsheet id
* data_transform: method name or lambda to tranform spreadsheet raw data to standart input
  Example:
  ```ruby
  sp2db_options data_transform: :tranform_raw_data_to_standard_method
  # Or use lambda
  sp2db_options data_transform: ->(raw-data, opts) {
    # Logic for data tranformation
  }
  # Or other form
  sp2db_options_data_transform do |raw_data, opts|
    # Logic for data tranformation
  end
  ```
* process_data: Use to remove invalid data or change column value before import, value: Symbol or lambda
* before_import_row: Run before each row import, value: Symbol or lambda
* after_import_row: Run after each row import, value: Symbol or lambda
* after_import_table: Run after table import, value: Symbol or lambda

### Import process and usage of hooks

* Spreadsheet raw data: [[cellA1, cellA2,...],[cellB1, cellB2],...]

⬇

* Data tranform: This step is used to tranform raw data to standard input with the first row is header and following data rows. (Use case: tranform vertical spreadsheet to horizontal spreadsheet)

⬇

* Raw data filter(private): remove columns starting with # and blank rows, check required rows(starting with "!") to remove

⬇

* Data process: Remove invalid rows, cols, change row values before importing, Output from this step will be input for file exporting

⬇

* Before row import: Run before each row importing, use case: change row data, add file for upload, ..

⬇

* After row import: Run after each row importing, use case: notification or file upload

⬇

* After table import: Run after each table importing, use case: notification or error handling

### Import strategy

Import strategy to process import, there are 4 strategies supprted by default

* truncate_all: Truncate table before importing, default
* overwrite: Overwrite when existed record found
* skip: Skip and not update when existed record found
* fill_empty: Only fill blank columns of found record

To add custom strategy
```ruby
Sp2db::ImportStrategy.add :custom_stragy do
  # Then overwrite method from Sp2db::ImportStrategy::Base to define behavior
  # Example for truncate all
  def before_import
    model.all.delete_all # Delete all record before importing
  end
end
```

### Error handling while import

Data will be rollbacked when ActiveRecord::ActiveRecordError be thrown, to change this behavior change exception_handler config, there 3 options for this
* raise: raise exception when occurs, defaut
* skip: skip exception
* A lambda for customize behavior
  Example

  ```ruby
  Sp2db.config do |conf|
    ...
    config.exception_handler.row_import_error = -> (exception){
      # Handle exeption, return true to continue or false to skip
    }

  end
  ```

### For non model table

Sometimes we need to export spreadsheet to file without active record model or the model is not exist
```ruby
Sp2db.config do |conf|
  conf.non_model_tables = {
    "table_names" => {
      sheet_id: "ANOTHER SHEET ID"
      ...
    }
  }
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiemns54/sp2db. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sp2db project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/khiemns54/sp2db/blob/master/CODE_OF_CONDUCT.md).
