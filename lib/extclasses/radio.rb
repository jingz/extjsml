class ExtRadio < ExtNode
  include FormField
  include Magic::InputValue

  @@ALIAS_CONFIG = {
    :text => :boxLabel
  }

  def initialize(config, parent)
    @default_config = {
      :labelWidth => 100,
      :hideLabel => true
    }
    
    super "radiofield", config, parent 
  end

  def to_extjs(at_deep = 0)
    if parent.xtype == "radiogroup" 
      name = parent.config[:name]
      config[:name] = name
    end
    super at_deep
  end
end
