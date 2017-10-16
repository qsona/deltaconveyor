module Deltaconveyor
  class Container
    attr_accessor :config, :originals

    def initialize
      self.config = Deltaconveyor::Config.new
    end
  end
end
