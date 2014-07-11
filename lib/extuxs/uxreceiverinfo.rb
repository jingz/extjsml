class ExtUxreceiverinfo < ExtNode
  include FormField

  def initialize(config, parent)
    @default_config = {}
    super 'uxreceiverinfo', config, parent 
  end
end
