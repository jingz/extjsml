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

    if find_parent("form", "fieldset")
      @config.delete :labelWidth
    end

    # remove all childs' label
    splitted_childs = []
    @childs.each_with_index do |c, i|
      if i % 2 == 1
        splitted_childs << ExtSplitter.new({}, nil)
      end
      splitted_childs << c
      c.remove_config :fieldLabel
    end
    @childs = splitted_childs

    super at_deep
  end
end
