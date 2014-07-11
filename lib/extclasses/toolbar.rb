class ExtToolbar < ExtNode
  def initialize(config, parent)
    @default_config = {}
    # TODO auto add separator btw buttons
    super("toolbar", config, parent) 
  end
end
