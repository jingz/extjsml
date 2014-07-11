class ExtDatefield < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      labelAlign: "right", 
      format: "d/m/Y", 
      cls: "date"
    }
    super "datefield", config, parent 
  end
end
