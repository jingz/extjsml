class ExtRadiogroup < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      :labelAlign => "right" 
    }
    super "radiogroup", config, parent 
  end
end
