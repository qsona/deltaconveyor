require 'logger'

module Deltaconveyor
  class Option
    DEFAULT_LOGGER = Logger.new(STDOUT)

    attr_accessor :row_class, :key, :logger

    def initialize(row_class: nil, key: nil, logger: nil)
      self.row_class = row_class
      self.logger = logger || DEFAULT_LOGGER
      self.key = key || :id
    end
  end
end
