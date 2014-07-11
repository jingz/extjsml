// Extend GridPanel
Ext.override(Ext.grid.GridPanel, {
    constructor: function(config) {
        config = config || {};
        Ext.apply(this, config)
        this.addEvents({
            datachanged: true 
        });

        // support empty store
        if (Ext.isArray(config.store)){
            if (Ext.isArray(config.store[0])) {
                config.store = new Ext.data.SimpleStore({
                    fields: ['value','text'],
                    data : config.store
                });
                config.valueField = 'value';
                config.displayField = 'text';
            } else {
                var store=[];
                for (var i=0,len=config.store.length;i<len;i++)
                store[i]=[config.store[i]];
                config.store = new Ext.data.SimpleStore({
                    fields: ['text'],
                    data : store
                });
                config.valueField = 'text';
                config.displayField = 'text';
            }
            config.mode = 'local';
        }

        this.callParent([config]);
    },

    initComponent: function(config){
        this.callParent(arguments);
        var self = this;

        // set up page size if paging is set
        // var paging = this.child('pagingtoolbar');
        // if(paging && paging.dock == "bottom" && this.store){
        //   // setup store paging 
        //   this.paginator = paging;
        //   this.store.defaultParams = { start: 0, limit: paging.pageSize };
        //   paging.store = this.store;
        //   this.paginator.on({
        //     change: function  () {
        //       self.fireEvent("datachanged");
        //     }
        //   });
        // }

        this.on({
          datachanged: function  () {
                console.log(arguments);
            },
            // it should clear cached records everytime before render
            // incase record appear at the same store but difference page
          beforerender: function  () {
            this.store.removeAll();
            // zebra
            this.view.getRowClass = this.getRowClass;
          },

          afterrender: function  () {
            // set column hilight
            // _.each(this.colModel.lookup, function(c) {
            //   if(c.hilight){
            //     if(typeof c.hilight != "string"){
            //       // default yellow
            //       c.hilight = "#ff8";
            //     }
            //     self.hilightColumn(c.dataIndex, c.hilight);
            //   }
            // });

          }

        });

        this.getView().on({
          refresh: function  () {
            if(self.colStyle){
              for(var dataIndex in self.colStyle){
                self.styleColumn(dataIndex, self.colStyle[dataIndex]);
              }
            }
          }
        });
    }
});

// Ext.grid.GridPanel = false;
// Ext.ClassManager.setAlias("widget.gridpanel", Ext.grid.GridPanel);
