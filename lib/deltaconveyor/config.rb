module Deltaconveyor
  class Config
    DEFAULT_ORIGINAL_KEY_PROC = ->(original) { original.id }
    DEFAULT_INFO_LOGGER_PROC = ->(*args) { puts *args }
    DEFAULT_ERROR_LOGGER_PROC = ->(*args) { STDERR.puts *args }

    attr_accessor :row_class, :original_key_proc, :info_logger_proc, :error_logger_proc

    def original_key(original)
      (original_key_proc || DEFAULT_ORIGINAL_KEY_PROC).call(original)
    end

    def info_logger(*args)
      (info_logger_proc || DEFAULT_INFO_LOGGER_PROC).call(*args)
    end

    def error_logger(*args)
      (error_logger_proc || DEFAULT_ERROR_LOGGER_PROC).call(*args)
    end
  end
end
