class	ExtTextfield < ExtNode
  include FormField  

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

	def initialize(config, parent)
    @default_config = {
      :labelAlign => "right"
    }

		super('textfield',config, parent)
	end
end
