class	ExtPasswordfield < ExtNode
  include FormField  

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

	def initialize(config, parent)
    @default_config = {
      :width => 150,
      :inputType => 'password'
    }

		super('textfield', config, parent)
	end
end
