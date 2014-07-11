class ExtCombo < ExtNode
  include FormField
  include Magic::Store
  include Magic::EmptyText

  # TODO
  @@XTYPE = "combo"

  @@ALIAS_CONFIG = {
    :text => :fieldLabel,
    :display => :displayField,
    :value => :valueField,
    :min => :minChars,
    :default => :value
  }

  # TODO
  @@DEFAULT_CONFIG = {
  
  }

  def initialize(config, parent)
    # TODO dummy store
    @default_config = {
      listConfig: {},
      labelAlign: "right",
      store: [],
      minChars: 2,
      valueField: "key",
      displayField: "pair",
      cls: "combo",
      lazyInit: false,
      mode: "local",
      # editable: false,
      triggerAction: "all",
      loadingText: "Loading ..."
    }

    # listConfig flatten
    [ :listWidth, :listMinWidth, 
      :listMaxWidth, :listResizable, 
      :listShadow, :listMaxHeight, 
      :listCls, :listEmpty, 
      :listLoadingText ].each do |k|

        if config[k]
          list_config_key = k.to_s.gsub(/list/, '')
          list_config_key = list_config_key[0].downcase + list_config_key[1..-1]
          @default_config[:listConfig][list_config_key] = config[k]
          config.delete k
        end
      end

    super "combo", config, parent 
  end
end
