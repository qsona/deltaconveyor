module Deltaconveyor
  class Row
    def self.from_json(row_json, container)
      raise 'You must implement .from_json method in class extends Row.'
    end

    def self.update!(original, row, container)
      raise 'You must implement .update! method in class extends Row.'
    end

    def save!(container)
      raise 'You must implement #save! method in class extends Row.'
    end

    def key
      raise 'You must implement #key method in class extends Row.'
    end

    def valid?
      raise 'You must implement #valid? method in class extends Row.'
    end
  end
end
