# depend on extjs currenct pluginclass Ext < ExtNode

class ExtPricefield < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      :labelAlign => "right",
      :cls => "number",
      # :plugins => [{ xclass: "Ext.plugin.Price" }, { ptype: "multiple_validations"}],
      :plugins => [{ xclass: "Ext.plugin.Price" } ],
      :priceConfig => {}
    }

    if config[:decimalPrecision]
      @default_config[:priceConfig].merge!({ :decimalPrecision => config[:decimalPrecision] })
      config.delete :decimalPrecision
    end

    if config[:currencySymbol]
      @default_config[:priceConfig].merge!({ :currencySymbol => config[:currencySymbol] })
      config.delete :currencySymbol
    end

    if config[:allowNegative]
      @default_config[:priceConfig].merge!({ :allowNegative => config[:allowNegative] })
      config.delete :allowNegative
    end

    super "textfield", config, parent 
  end
end
