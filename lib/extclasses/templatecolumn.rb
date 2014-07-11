class ExtTemplatecolumn < ExtNode
  include Magic::Column
  @@ALIAS_CONFIG = {
    :text => :header
  }
  def initialize(config, parent)
    @default_config = {}

    super "templatecolumn", config, parent
  end
end
