class ExtViewport < ExtNode
  def initialize(config, parent)
    @default_config = {
      autoScroll: true
    }
    super 'viewport', config, parent
  end
end
