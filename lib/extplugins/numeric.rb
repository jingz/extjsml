# depend on extjs currency plugin 

class ExtNumeric < ExtNode
  include FormField

  @@ALIAS_CONFIG = {
    :text => :fieldLabel
  }

  def initialize(config, parent)
    @default_config = {
      :width => 150,
      :cls => "number",
      :plugins => [{ ptype: "currency" }], # depend the plugins
      :currencyConfig => {
        :currencySymbol => "" 
      }
    }

    # maually merge nested config
    unless config[:currencyConfig].nil?
      @default_config[:currencyConfig].merge! config[:currencyConfig] 
      config.delete :currencyConfig
    end

    unless config[:decimalPrecision].nil?
      @default_config[:currencyConfig].merge!({ :decimalPrecision => config[:decimalPrecision]})
    end

    super "textfield", config, parent 
  end
end