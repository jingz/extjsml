Basic_grid = Ext.extend(Basic_gridUI,{
  constructor: function  (config) {
    config = config || {};
    Ext.apply(this, config);
    Basic_grid.superclass.constructor.call(this)
  },
  
  initComponent: function(){
    // Basic_grid.superclass.initComponent.call(this);
    this.callParent(arguments);
    var self = x = this;
    console.log("grid", this);
    // use x for debugging at console

    // self.loadExampleData.on({
    //   click: function() {
    //     var data = []
    //     // building data set 
    //     for(var i = 0; i <= 10; i++){
    //       data.push({
    //         text_column: "text_column",
    //         number_column: Math.random() * 1000,
    //         boolean_column: (Math.random() * 10 > 5 ? true : false),
    //         date_column: self.randomDate(new Date(2013, 1, 1), new Date()),
    //         currency_column: Math.random() * 10000,
    //       });
    //     }

    //     self.grid.addRecords(data);
    //   }

    // });

    // self.grid.on({
    //   rowclick: function(grd, index, ev) {
    //     var r = this.getSelectedRow();
    //     self.frmInfo.fillData(r.data);
    //   }
    // });

  },

  randomDate: function(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()) );
  }
});
