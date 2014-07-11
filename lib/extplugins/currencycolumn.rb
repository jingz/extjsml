class ExtCurrencycolumn < ExtNode
  include Magic::Column
  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }
  def initialize(config, parent)
    @default_config = {
      :format => "0,000.00",
      :align => "right",
      :editor => {
        :xtype => "textfield",
        :plugins => [{:ptype => "currency"}] 
      }  
    }
    super "numbercolumn", config, parent
  end
end
