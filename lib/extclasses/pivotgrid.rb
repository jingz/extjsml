class	ExtPivotgrid < ExtNode
  include Magic::Store
  include Magic::Title

  @@ALIAS_CONFIG = {
    :text => :title
  }

	def initialize(config, parent)
    @default_config = {
      title: "My Grid",
      # enableHdMenu: false,
      columnLines: true,
      sm: "",
      selector: "row",
      # enableColumnmove: false,
      viewConfig: { 
        forceFit: true,
        emptyText: "No record"
        # for expanding row to show any infomation
        # enableRowBody: true
      },
      frame: true,
      width: "auto",
      loadMask: true,
      # TODO dummy store
      store: [],
      height: 200
      # columns: [
      #   { id: 'company', header: 'Company', width: 200, sortable: true, dataIndex: 'company'},
      #   { header: 'Price', dataIndex: 'price'},
      #   { header: 'Change', dataIndex: 'change'},
      #   { header: '% Change', dataIndex: 'pctChange'},
      #   {
      #     header: 'Last Updated', width: 135, dataIndex: 'lastChange',
      #     xtype: 'datecolumn', format: 'M d, Y'
      #   }
      # ]
    }
    
		super('pivotgrid',config, parent)
	end
  
  # TODO refactor 
  def to_extjs(at_deep = 0)
    # columns
    cols = []
    self.childs.each do |c|
      cols << c.to_extjs(at_deep) unless c.xtype.match(/column$/).nil?
    end
    @config.merge! :columns => cols unless cols.nil?
    
    # rowselection type : row | rows, cell | cells, checkbox | checkboxs
    unless @config[:selector].nil?
      # generate random js variable name
      require "securerandom"
      var = SecureRandom.urlsafe_base64.gsub(/\d|\W/,'')
      case @config[:selector]
      when "row"
        @config.merge! :sm => "<js>(this._#{var} = new Ext.grid.RowSelectionModel({ singleSelect: true }))</js>)"
      when "rows"
        @config.merge! :sm => "<js>(this._#{var} = new Ext.grid.RowSelectionModel({ singleSelect: false }))</js>)"
      # TODO
      # when "cell"
      #   @config.merge! :sm => "<js>(this._#{var} = new Ext.grid.CellSelectionModel())</js>)" 
      when "checkbox"
        @config.merge! :sm => "<js>(this._#{var} = new Ext.grid.CheckboxSelectionModel({ singleSelect: true, header: '' }))</js>)"
        @config[:columns].unshift("<js>this._#{var}</js>")
      when "checkboxs"
        @config.merge! :sm => "<js>(this._#{var} = new Ext.grid.CheckboxSelectionModel())</js>)"
        @config[:columns].unshift("<js>this._#{var}</js>")
      end
      @config.delete :selector 
    end

    toolbar = self.find("toolbar", {recursive: 1})
    @config.merge! :tbar => toolbar.to_extjs(at_deep + 1) if toolbar

    paging = self.find("paging")
    if paging
      unless @config[:store] =~ /<js>/
        paging.override_config :store => @config[:store]
      end
      @config.merge! :bbar => paging.to_extjs(at_deep + 1)
    end

    # grid not allow to have items
    self.childs = []
    super(at_deep)
  end
end
