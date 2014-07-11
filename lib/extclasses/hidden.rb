class ExtHidden < ExtNode
  include FormField
  def initialize(config, parent)
    @default_config = {}
    super "hidden", config, parent
  end
end
