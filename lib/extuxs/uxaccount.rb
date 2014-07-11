class ExtUxaccount < ExtNode
  	include FormField
    def initialize(config, parent)
      # TODO
      @default_config = {}
      super 'uxaccount', config, parent
    end
end
