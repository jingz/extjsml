class ExtHtmleditor < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      :labelAlign => "right" 
    }

    super "htmleditor", config, parent
  end
end
