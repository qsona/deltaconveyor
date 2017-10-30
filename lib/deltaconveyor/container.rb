module Deltaconveyor
  class Container
    attr_accessor :originals

    def initialize(originals: nil)
      self.originals = originals
    end
  end
end
