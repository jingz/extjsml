class ExtGridcolumn < ExtNode
  include Magic::Column

  @@ALIAS_CONFIG = {
    :text => :header,
    :name => :dataIndex
  }

  def initialize(config, parent)
    @default_config = { }

    super "gridcolumn", config, parent
  end

  def to_extjs(at_deep = 0)
    if self.child_of? "editorgrid" and @config[:editor].nil?
      @config.merge! :editor => { :xtype => "textfield" }
    end
    super at_deep 
  end
end
