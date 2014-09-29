class ExtDatefield < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      labelAlign: "right", 
      format: "d/m/Y", 
      width: 110,
      cls: "date"
    }
    super "datefield", config, parent 
  end
end
