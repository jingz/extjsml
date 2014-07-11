class ExtCheckboxgroup < ExtNode
  include FormField
  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }
  
  def initialize(config, parent)
    @default_config = {
      labelAlign: "right"
    }

    super "checkboxgroup", config, parent 
  end
end
