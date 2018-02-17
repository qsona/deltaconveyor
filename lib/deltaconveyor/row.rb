module Deltaconveyor
  class Row
    attr_accessor :container

    def self.from_json(row_json, container)
      raise 'You must implement .from_json method in class extends Row.'
    end

    def update!(original)
      raise 'You must implement #update! method in class extends Row.'
    end

    def save!
      raise 'You must implement #save! method in class extends Row.'
    end

    def valid?
      raise 'You must implement #valid? method in class extends Row.'
    end
  end
end
