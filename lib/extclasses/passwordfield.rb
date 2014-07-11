class	ExtPasswordfield < ExtNode
  include FormField  

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

	def initialize(config, parent)
    @default_config = {
      :width => 150,
      :autoCreate => {
        :tag => "input",
        :type => "password",
        :autocomplete => "off"
      }
    }
    if config[:autoCreate]
      @default_config.merge! config[:autoCreate]
      config.delete :autoCreate
    end
    if config[:emptyText]
      @default_config[:autoCreate][:placeholder] = config[:emptyText]
      config.delete :emptyText 
    end
		super('textfield', config, parent)
	end
end
