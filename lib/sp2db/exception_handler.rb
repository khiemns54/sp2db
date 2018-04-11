module Sp2db
  module ExceptionHandler
    extend self

    def row_import_error e
      handle __method__, e
    end

    def table_import_error e
      handle __method__, e
    end

    def handle action, e
      case action = Sp2db.config.exception_handler[action]
      when :skip
        true
      when :raise
        raise e
      when Proc
        action.call(e)
      else
        raise e
      end
    end
  end
end
