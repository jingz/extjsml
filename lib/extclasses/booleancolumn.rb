class ExtBooleancolumn < ExtNode
  include Magic::Column
  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }
  
  def initialize(config, parent)
    @default_config = {
      trueText: "yes",
      falseText: "no",
      align: "center",
      width: 45
    }

    gridparent = self.find_parent("grid")

    if gridparent and gridparent.config[:__editorgrid]
      super "checkcolumn", config, parent
    else
      super "booleancolumn", config, parent
    end
  end

  def to_extjs(at_deep = 0)
    gridparent = self.find_parent("grid")
    if gridparent and gridparent.config[:__editorgrid]
      self.xtype = "checkcolumn" 
    else
      self.xtype = "booleancolumn" 
    end
    super at_deep 
  end
end
