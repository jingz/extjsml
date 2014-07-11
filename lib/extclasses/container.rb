class ExtContainer < ExtNode
	def initialize(config, parent)
    @default_config = {
      layout: 'auto',
      # labelWidth: 100,
      # autoHeight: true,
      autoWidth: true
    }

		super("container", config, parent)	
	end
end
