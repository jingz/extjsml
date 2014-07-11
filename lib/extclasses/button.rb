class ExtButton < ExtNode
  include Magic::Text
  include Magic::IconClass
  def initialize(config, parent)
    @default_config = {
      text: "Ext Button",
    }
    super("button", config, parent) 
  end
end

