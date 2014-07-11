class ExtCheckbox < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :boxLabel,
    :ltext => :fieldLabel,
    :rtext => :boxLabel,
    :default => :checked
  }

  def initialize(config, parent)
    @default_config = {
      :fieldLabel => "<b></b>",
      :labelAlign => "right",
      :boxLabelAlign => "after",
      :hideLabel => false,
      :cls => "checkbox"
    }

    super "checkboxfield", config, parent 
  end

  def to_extjs(at_dept = 0)
    if self.find_parent("checkboxgroup")
      @config.merge! :hideLabel => true
    end 

    super at_dept
  end
end
