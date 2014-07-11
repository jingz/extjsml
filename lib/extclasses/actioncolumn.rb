class ExtActioncolumn < ExtNode
  include Magic::Column
  @@ALIAS_CONFIG = {
    :text => :header
  }
  def initialize(config, parent)
    @default_config = {}

    super "actioncolumn", config, parent
  end
end