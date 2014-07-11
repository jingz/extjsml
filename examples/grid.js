Ext.define("Grid",{
  extend: "GridUI",
  constructor: function  (config) {
    config = config || {};
    Ext.apply(this, config);
    this.custom_config = "custom config";
    // Grid.superclass.constructor.call(this)
    this.callParent(config);
  },
  
  initComponent: function(){
    this.callParent(arguments);
    var self = x = this;

    var data = [];
    for(var i = 0; i <= 10; i++){
        data.push({
          text_column: "text_column",
          string_column: "string_column",
          number_column: Math.random() * 1000,
          boolean_column: (Math.random() * 10 > 5 ? true : false),
          date_column: self.randomDate(new Date(2013, 1, 1), new Date()),
          currency_column: Math.random() * 10000,
        });
    }
    
    self.on({
        afterrender: function(){
            self._grid.store.reload();
            // self._aGrid.store.reload();
        }

    });
    
  },
    randomDate: function(start, end) {
      return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()) );
    }
});
