Basic_editorgrid = Ext.extend(Basic_editorgridUI,{
  constructor: function  (config) {
    config = config || {};
    Ext.apply(this, config);
    Basic_editorgrid.superclass.constructor.call(this)
  },
  
  initComponent: function(){
    Basic_editorgrid.superclass.initComponent.call(this);
    var self = x = this;
    // use x for debugging at console
    
    self.loadExampleData.on({
      click: function() {
        var data = []
        // building data set 
        for(var i = 0; i <= 10; i++){
          data.push({
            text_column: "text_column",
            number_column: Math.random() * 1000,
            boolean_column: (Math.random() * 10 > 5 ? true : false),
            date_column: self.randomDate(new Date(2013, 1, 1), new Date()),
            currency_column: Math.random() * 10000,
          });
        }

        self.egrid.addRecords(data, true);
      }
    });
    // -----------------------------------------------------

    self.getChangedData.on({
      click: function(){
         console.log(self.egrid.getChangedRecords());
      }
    });
    // -----------------------------------------------------

    self.egrid.on({
      datachanged: function(rs) {
        console.log("all datachanged", rs);
      },
      afteredit: function(rs) {
        console.log("afteredit" , rs);
      }
    });
    
  },

  // instance method
  randomDate: function(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()) );
  }
});
