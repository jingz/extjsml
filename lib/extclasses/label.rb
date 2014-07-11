class ExtLabel < ExtNode
  include Magic::Text
  def initialize(config, parent)
    @default_config = {
       
    }
    super("label", config, parent)
    
  end
end