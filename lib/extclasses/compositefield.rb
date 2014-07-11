# deprecate
class ExtCompositefield < ExtNode
  include FormField
  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }
  def initialize(config, parent)
    @default_config = { }
    super "compositefield", config, parent
  end
end
