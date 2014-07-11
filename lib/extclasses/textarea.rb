class ExtTextarea < ExtNode
  include FormField
  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }
  def initialize(config, parent)
    @default_config = {
      :labelAlign => "right"
    }
    super "textarea", config, parent
  end
end
