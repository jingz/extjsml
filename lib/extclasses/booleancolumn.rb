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

    if parent.xtype ==  "editorgrid"
      super "checkcolumn", config, parent
    else
      super "booleancolumn", config, parent
    end
  end

  def to_extjs(at_deep = 0)
    if parent.xtype ==  "editorgrid"
      self.xtype = "checkcolumn" 
    else
      self.xtype = "booleancolumn" 
    end
    # if self.child_of? "editorgrid"
    #   @config.merge! :editor => { :xtype => "checkbox", :boxLabel => "Check" }
    # end
    super at_deep 
  end
end
