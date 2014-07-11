class ExtCheckcolumn < ExtNode
  include Magic::Column
  
  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }
  
  def initialize(config, parent)
    @default_config = {
      :align => "right", 
      :sortable => true
    }
    super "checkcolumn", config, parent
  end
end
