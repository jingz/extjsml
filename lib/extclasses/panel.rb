class ExtPanel < ExtNode
  include Magic::Title

  @@ALIAS_CONFIG = {
    :text => :title
  }
  
	def initialize(options, parent)
    @default_config = {
      :padding => 5,
      # :height => 200,
      :title => 'Title By Default',
      :autoHeight => true
    }
		super("panel", options, parent)	
	end

  def to_extjs(at_deep = 0)
    if find("toolbar", { :recursive => 1})
      @config.merge! :tbar => find("toolbar").to_extjs(at_deep + 1)
      self.remove_childs "toolbar"
    end
    if find("paging", { :recursive => 1})
      @config.merge! :bbar => find("paging").to_extjs(at_deep + 1)
      self.remove_childs "paging"
    end
    super at_deep
  end
end
