module Sp2db
  class Spreadsheet

    attr_accessor :sheet

    def initialize sheet
      self.sheet = sheet
    end

    def worksheets
      sheet.worksheets.index_by(&:title).with_indifferent_access
    end

    def worksheet_by_name ws_name
      sheet.worksheet_by_title ws_name
    end

  end
end
