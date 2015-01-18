class ExtEditorgrid < ExtNode
  include Magic::Store
  include Magic::Title

  @@ALIAS_CONFIG = {
    :text => :title
  }

	def initialize(config, parent)
    @default_config = {
      __editorgrid: true,
      title: 'My Grid',
      frame: true,
      width: "auto",
      plugins: [{ xclass: 'Ext.grid.plugin.CellEditing'}],
      height: 200,
      clicksToEdit: 2,
      # enableHdMenu: false,
      enableColumnMove: false,
      columnLines: true,
      # TODO dummy store
      store: [],
      # style: "{ height: 100%; }",
      viewConfig: {
        forceFit: true 
      },
      columns: [
        {
          xtype: 'gridcolumn',
          dataIndex: 'string',
          header: 'String',
          sortable: true,
          width: 100,
          editor: {
            xtype: 'textfield'
          }
        },
        {
          xtype: 'numbercolumn',
          align: 'right',
          dataIndex: 'number',
          header: 'Number',
          sortable: true,
          width: 100,
          editor: {
            xtype: 'numberfield'
          }
        },
        {
          xtype: 'datecolumn',
          dataIndex: 'date',
          header: 'Date',
          sortable: true,
          width: 100,
          editor: {
            xtype: 'datefield'
          }
        },
        {
          xtype: 'booleancolumn',
          dataIndex: 'bool',
          header: 'Boolean',
          sortable: true,
          width: 100,
          editor: {
          xtype: 'checkbox',
            boxLabel: 'BoxLabel'
          }
        }
      ]
    }

		super("grid", config, parent)	
	end

  def to_extjs(at_deep = 0)
    # grid use child to another purpose, paging and toolbar columns
    
    # columns
    cols = []
    self.childs.each do |c|
      cols << c.to_extjs(at_deep) unless c.xtype.match(/column$/).nil?
    end
    @config.merge! :columns => cols unless cols.nil?
    
    toolbar = self.find("toolbar")
    @config.merge! :tbar => toolbar.to_extjs(at_deep + 1) if toolbar

    # paging = self.find("paging")
    # if paging
    #   paging.override_config :store => @config[:store]
    #   @config.merge! :bbar => paging.to_extjs(at_deep + 1)
    # end

    # set paging
    rand_store_id = ExtUtil.random_id
    paging = self.find("pagingtoolbar")
    if paging

      if paging.config[:store].nil?
        paging.override_config :store => ("<js>this.#{rand_store_id}</js>" || @config[:store])
      end

      if @config[:store]
        paging.override_config :store => @config[:store]
      else
        paging.override_config :store => rand_store_id
      end

      @config.merge! :bbar => paging.to_extjs(at_deep + 1)
    end

    # grid not allow to have items
    self.childs = []
    super(at_deep)
  end
end
