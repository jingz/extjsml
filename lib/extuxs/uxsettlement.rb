class ExtUxsettlement < ExtNode
  	include FormField
    def initialize(config, parent)
      # TODO
      @default_config = {}
      super 'uxsettlement', config, parent
    end
end
