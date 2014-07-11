class ExtDatecolumn < ExtNode
  include Magic::Column
  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }
  def initialize(config, parent)
    @default_config = {
      format: "d/m/Y" 
    }

    super "datecolumn", config, parent
  end

  def to_extjs(at_deep = 0)
    if self.child_of? "editorgrid"
      @config.merge! :editor => { :xtype => "datefield", format: "d/m/Y" }
    end
    super at_deep 
  end
end
