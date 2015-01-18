class ExtNumbercolumn < ExtNode
  include Magic::Column
  
  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }
  
  def initialize(config, parent)

    @default_config = {
      :align => "right", 
      :sortable => true,
      :format => "0,000"
    }

    super "numbercolumn", config, parent
  end

  def to_extjs(at_deep = 0)
    gridparent = self.find_parent("grid")
    if gridparent and gridparent.config[:__editorgrid]
      if @config[:editor].nil?
        @config.merge! :editor => { :xtype => "numberfield" }
      else
        @config[:editor].merge! :xtype => "numberfield", :format => @config[:format] || "0,000.00"
      end
    end
    super at_deep 
  end
end
