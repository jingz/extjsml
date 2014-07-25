class String

  EXT_CLASS_MAP = {
    box:              'Ext.BoxComponent',
    button:           'Ext.Button',
    buttongroup:      'Ext.ButtonGroup',
    colorpalette:     'Ext.ColorPalette',
    component:        'Ext.Component',
    container:        'Ext.Container',
    cycle:            'Ext.CycleButton',
    dataview:         'Ext.DataView',
    datepicker:       'Ext.DatePicker',
    editor:           'Ext.Editor',
    editorgrid:       'Ext.grid.EditorGridPanel',
    flash:            'Ext.FlashComponent',
    grid:             'Ext.grid.GridPanel',
    listview:         'Ext.ListView',
    multislider:      'Ext.slider.MultiSlider',
    panel:            'Ext.Panel',
    progress:         'Ext.ProgressBar',
    propertygrid:     'Ext.grid.PropertyGrid',
    slider:           'Ext.slider.SingleSlider',
    spacer:           'Ext.Spacer',
    splitbutton:      'Ext.SplitButton',
    tabpanel:         'Ext.TabPanel',
    treepanel:        'Ext.tree.TreePanel',
    viewport:         'Ext.Viewport',
    window:           'Ext.Window',

    # Toolbar component
    paging:           'Ext.PagingToolbar',
    pagingtoolbar:    'Ext.PagingToolbar', # 4.2
    toolbar:          'Ext.Toolbar',
    tbbutton:         'Ext.Toolbar.Button',
    tbfill:           'Ext.Toolbar.Fill',
    tbitem:           'Ext.Toolbar.Item',
    tbseparator:      'Ext.Toolbar.Separator',
    tbspacer:         'Ext.Toolbar.Spacer',
    tbsplit:          'Ext.Toolbar.SplitButton',
    tbtext:           'Ext.Toolbar.TextItem',

    # Menu components
    menu:             'Ext.menu.Menu',
    colormenu:        'Ext.menu.ColorMenu',
    datemenu:         'Ext.menu.DateMenu',
    menubaseitem:     'Ext.menu.BaseItem',
    menucheckitem:    'Ext.menu.CheckItem',
    menuitem:         'Ext.menu.Item',
    menuseparator:    'Ext.menu.Separator',
    menutextitem:     'Ext.menu.TextItem',

    # Form components
    form:             'Ext.form.FormPanel',
    checkbox:         'Ext.form.Checkbox',
    checkboxgroup:    'Ext.form.CheckboxGroup',
    combo:            'Ext.form.ComboBox',
    compositefield:   'Ext.form.CompositeField',
    datefield:        'Ext.form.DateField',
    displayfield:     'Ext.form.DisplayField',
    field:            'Ext.form.Field',
    fieldset:         'Ext.form.FieldSet',
    hidden:           'Ext.form.Hidden',
    htmleditor:       'Ext.form.HtmlEditor',
    label:            'Ext.form.Label',
    numberfield:      'Ext.form.NumberField',
    radio:            'Ext.form.Radio',
    radiogroup:       'Ext.form.RadioGroup',
    textarea:         'Ext.form.TextArea',
    textfield:        'Ext.form.TextField',
    timefield:        'Ext.form.TimeField',
    trigger:          'Ext.form.TriggerField',
    # additional
    # :currency => $ 1,222.00
    currency: 'Ext.form.Currency',
    pricefield: 'Ext.form.PriceField',
    # :numeric  => 1,222.00
    numeric: 'Ext.form.Numeric',
    # ux filefield
    filefield: 'Ext.ux.form.FieldUploadField',

    # Chart components
    chart:            'Ext.chart.Chart',
    barchart:         'Ext.chart.BarChart',
    cartesianchart:   'Ext.chart.CartesianChart',
    columnchart:      'Ext.chart.ColumnChart',
    linechart:        'Ext.chart.LineChart',
    piechart:         'Ext.chart.PieChart',

    # Store xtypes
    arraystore:       'Ext.data.ArrayStore',
    directstore:      'Ext.data.DirectStore',
    groupingstore:    'Ext.data.GroupingStore',
    jsonstore:        'Ext.data.JsonStore',
    simplestore:      'Ext.data.SimpleStore',
    store:            'Ext.data.Store',
    xmlstore:         'Ext.data.XmlStore',

    # Grid Columns
    gridcolumn:       'Ext.grid.Column',
    booleancolumn:    'Ext.grid.BooleanColumn',
    numbercolumn:     'Ext.grid.NumberColumn',
    datecolumn:       'Ext.grid.DateColumn',
    templatecolumn:   'Ext.grid.TemplateColumn',
    # additional
    # gcurrency
    currencycolumn: 'Ext.grid.CurrencyColumn'

  } 

  def self.get_all_xtypes
    EXT_CLASS_MAP.keys 
  end

  def to_extclassname
    EXT_CLASS_MAP[self.to_sym]
  end

	def capitalize
	  self[0].upcase + self[1..-1]
	end

  # some-store -> someStore
  def to_storeid(delimeter = '-')
    sid = self.split(delimeter)
    temp = sid[1..-1]
    fword = sid[0]
    temp.each do |el|
      fword += (el[0].upcase + el[1..-1])
    end
    
    fword
  end

end

class ExtUtil
  # TODO move to file
  ALIAS_TABLE = {
    :tab => :tabpanel,
    :div => :container,
    # column alias
    :gtext => :gridcolumn,
    :gboolean => :booleancolumn,
    :gnumber => :numbercolumn,
    :gdate => :datecolumn,
    :gtemplate => :templatecolumn,
    :gaction => :actioncolumn,
    :gcurrency => :currencycolumn,
    :gcheck => :checkcolumn
  }

  CONTAINER_XTYPE = [
    "div",
    "container",
    "panel",
    "tabpanel",
    "form",
    "fieldset",
    "fieldcontainer"
  ]

  DATA_COLUNMS = [
    "gridcolumn",
    "numbercolumn",
    "booleancolumn",
    "datecolumn",
    "currencycolumn",
    "numericcolumn"
  ]

  FIELD_XTYPE = [  
      "fieldcontainer",
      "fileuploadfield",         
      "checkbox",         
      "checkboxgroup",    
      "combo",            
      "compositefield",
      "datefield",
      "displayfield",     
      "field",            
      "fieldset",         
      "hidden",           
      "htmleditor",       
      "label",            
      "numberfield",      
      "radio",            
      "radiogroup",       
      "textarea",         
      "textfield",        
      "timefield",        
      "trigger",

      "uxaccount",
      "uxsettlement",
      "uxchq",
      "uxbroker"
  ];

  def self.xtype_alias(xtype)
    ALIAS_TABLE[xtype.to_sym] || xtype
  end

  def self.field_xtype
    FIELD_XTYPE 
  end

  def self.data_xtype
    DATA_COLUNMS
  end

  def self.container_xtype
    CONTAINER_XTYPE    
  end

  def self.FontWidthRatio
    9 
  end
  
  def self.all_xtype
    return String.get_all_xtypes
  end

  require "securerandom"
  def self.random_id
    "_" + SecureRandom.urlsafe_base64.gsub(/\d|\W/,'')
  end


end

# test
if __FILE__ == $0
  p "jsonstore".to_extclassname
  p "x-test-xxx".to_storeid
end
