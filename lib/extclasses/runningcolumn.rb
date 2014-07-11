class ExtRunningcolumn < ExtNode
  def initialize(config, parent)
    super "runningcolumn", config, parent
  end

  def to_extjs(at_deep)
    "<js>new Ext.grid.RowNumberer()</js>" 
  end
end
