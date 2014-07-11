class ExtFieldcontainer < ExtNode
  include FormField

	def initialize(config, parent)
    @default_config = {
      layout: 'hbox',
      defaultType: 'textfield',
      labelAlign: 'right'
    }

		super("fieldcontainer", config, parent)	
	end

  def to_extjs(at_deep = 0)

    # remove all childs' label
    @childs.each do |c|
      c.remove_config :fieldLabel
    end

    super at_deep
  end
end
