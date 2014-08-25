class ExtRunningcolumn < ExtNode

  @@ALIAS_CONFIG = {
    :text => :header
  }

  def initialize(config, parent)
    @default_config = {
      :width => 50,
      :header => '#',
      :sortable => false
    }

    super "rownumberer", config, parent
  end

  # def to_extjs(at_deep)
  #   "<js>new Ext.grid.RowNumberer()</js>" 
  # end
end
