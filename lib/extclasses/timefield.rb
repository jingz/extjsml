class	ExtTimefield < ExtNode
  include FormField  

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

	def initialize(config, parent)
    @default_config = {
      labelAlign: "right",
      cls: 'time'
    }
		super('timefield',config, parent)
	end
end

