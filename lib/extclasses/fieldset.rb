class ExtFieldset < ExtNode
  include Magic::Title

  @@ALIAS_CONFIG ={
    :text => :title
  }

  def initialize(config, parent)
    @default_config = {
      layout: 'anchor',
      animCollapse: true,
      labelAlign: "right",
      # collapsed: true,
      # checkboxToggle: true,
      autoHeight: true
      # columnWidth: 0.5
    }
    super("fieldset", config, parent) 
  end

  def to_extjs(at_deep = 0)
    col_label_width = []
    x = self.find_field_elements.map do |c|
      [c.config[:fieldLabel], c.parent.config[:col_index], c.parent.config[:labelWidth] ]
    end
    self.find_field_elements.each do |c|
      i = c.parent.config[:col_index] || 0
      next unless i
      unless col_label_width[i] 
        col_label_width[i] = []
      end
      col_label_width[i] << c.parent.config[:labelWidth]
    end
    max_label_width = []
    col_label_width.each_with_index do |c, i|
      max_label_width[i] = c.compact.max
    end

    # update max label within every fields container
    self.find_field_elements.each do |c|
      i = c.parent.config[:col_index] || 0
      c.parent.config[:labelWidth] = max_label_width[i]
    end

    if @config[:labelWidth]
      @config.merge!({ :defaults => { :labelWidth => @config[:labelWidth] } } )
      # if set a button at the last child
      if @childs.last.xtype == "button" and not @childs.last.config[:style].nil?
        btn_style = @childs.last.config[:style]
        new_btn_style = btn_style.dup if btn_style
        new_btn_style ||= "{}"
        fix_style = "margin-left: #{@config[:labelWidth]+5}px; margin-bottom: 0.5em; }"
        new_btn_style.gsub!("}", fix_style)
        @childs.last.config[:style] = new_btn_style
      end
      @config.delete :labelWidth
    end

    super(at_deep)
  end
end
