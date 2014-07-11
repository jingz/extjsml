class ExtTabpanel < ExtNode
  @@ALIAS_CONFIG = {
    :text => :title
  }
  
  def initialize(config, parent)
    @default_config = {
       height: 200,
       activeTab: 0,
       autoHeight: true,
       layoutOnTabChange: true,
       deferredRender: true,
       animScroll: true
    }
    super "tabpanel", config, parent 
  end
end
