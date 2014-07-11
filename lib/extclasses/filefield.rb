# depend ux
class	ExtFilefield < ExtNode
  include FormField  

  @@ALIAS_CONFIG = {
    :text => :buttonText
  }

	def initialize(config, parent)
    @default_config = {
      width: 355,
      labelAlign: "right",
      buttonText: "Browse"
    }
		super('fileuploadfield',config, parent)
	end
end

