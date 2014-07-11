// Util
// depend form2js js2form
var Util = { form: {} };
Util.form.loadObject = function  (f, obj, options) {
	options = options || {};
	Ext.applyIf(options, {
		modify: false
	});

	if(typeof f == "string"){
		var rootNode = document.getElementById(f);
	}
	else{
		f = f.getForm && f.getForm();
		var rootNode = document.getElementById(f.id);
	} 

    // js2form
	if(!js2form){ throw new Error("must include js2form lib") }
		js2form(rootNode, obj, ".", function(name, value) {
            console.log(name, value);
			if(f.findField){
		        var field = f.findField(name);
			} else{
            	// incase from is stirng
            	var qry = "*[name='"+name+"']";
            	var el = Ext.query(qry, rootNode)[0];
            	// not work in case custom field like
            	// currency and numeric field
            	if(el) var field = Ext.getCmp(el.id);
		    }

	        if(field){
	           if(field.getXType() === "datefield" && !Ext.isEmpty(value)){
	               // got 1970-01-01
                   // incase from array store
                   var v = _.isDate(value) ? value : new Date(value);
	               field.setValue(v);
	               if(!options.modify) field.originalValue = field.getValue();
	           }
	           else{
	               // fill data to remote combo
	               if(field.getXType() == "combo" && field.mode == "remote"){
	      				if(field.store){
	      					if(value) field.setRemoteValue(value, field.queryParam || field.valueField, function  () {
	    		                if(!options.modify) field.originalValue = field.getValue();
	      					});
	      				}
	               }
	               else{
		               field.setValue(value);
		               if(!options.modify) field.originalValue = field.getValue();
	               }
	           }
	        }
		});

    // fix radio filler
    var rads = $.unique($('#'+f.id+' input[type=radio]').map(function(i, o){ return o.name; }));
    $.each(rads, function(i, name){
        $.grep(
            $('#'+f.id+' input[name='+name+']'),
            function(o){ return o.value == obj[name]; }
        )[0].checked = true;
    });
}
//
// markInvalid : show tooltip and hilight on each invalid field
// accept result error obj from server; { success: .. , message: .. , error: [..]}
// cb = callback that called if there is any error cant mark in the given dom scope
// and send it as callback parameter with remaining errors message string
Util.form.markInvalid = function (result, dom_scope, cb) {
    // show error notification
    // show error message tooltip and hilight
    var out_of_form_err = []
    for(var name in result.error){
        if(Ext.isArray(result.error[name]))
            var err = result.error[name].join(" and ")
        else
            var err = result.error[name]

        $("*[name='" + name + "']", dom_scope).addClass("x-form-invalid");
        var el = Ext.query("*[name='" + name + "']", dom_scope);
        if(el.length > 0){
          // find ext running id
          el = el[0];
          if(el.type.toLowerCase() == "hidden"){
          	// try to find nextSlibling
          	if(el.nextSibling.tagName.toLowerCase() == "input"){
          		el = el.nextSibling;
          	}
          }

          var id = el.id;
          // get component class
          var com = Ext.getCmp(id);
          if(com) com.markInvalid(err);
        } 
        else{
          out_of_form_err.push(name + " " + err)
        }
    }
    // send errors that cant mark in the form 
    if(typeof cb == "function" && out_of_form_err.length > 0) cb("<b>Additional Errors</b><br/>"+out_of_form_err.join("<br/>"))
}

// serialize all inputs in the form to json object
// @form : Ext FormPanel object , or String HTML id
// return [nested] json
Util.form.serializeJson = function (form, options) {
    options = options || {};
    Ext.applyIf(options, { skipEmpty: true })
    var isAnythingUpdate = false;
    if(form2js){
    	// form can be id string
    	if(typeof form == "string"){
    		var nodeId = form;
    	} else{
			var f = form.getForm();
			var nodeId = f.id
    	}
        // form2js(rootNode, delimiter, skipEmpty, nodeCallback, useIdIfEmptyName)
        var params = form2js(nodeId, '.', options.skipEmpty, function (node) {
            if(node.getAttribute && node.name && !(/(^ext)|\-/.test(node.name))){
            	if(f && f.findField)
	                var field = f.findField(node.name);
	            else{
	            	// incase from is stirng
	            	var qry = "*[name='"+node.name+"']";
	            	var el = Ext.query(qry)[0];
	            	if(el) var field = Ext.getCmp(el.id);
	            }
                // check dirty if setting
                if(options.onlyDirty){
                    //var field = Ext.getCmp(node.id);
                    if(field){
                        var o = field.originalValue;
                        var n = field.getValue();
                        //if(!field.isDirty()){
                        // not use isDirty() method for sure in radio
                        var notDirty = (o == n);
                        if(Ext.isDate(o) && Ext.isDate(n)){ notDirty = notDirty | (o.toDateString() == n.toDateString())}
                        if(notDirty){
                            // set value to null to skip
                            // TODO except id # hidden inputs that store record key 
                            if(/id$/i.test(node.name) && node.type == "hidden"){
                            	return {name: node.name, value: parseInt(node.value) || null }
                            }

                            return { name: node.name, value: null};
                        } else{
		                	isAnythingUpdate = true;
                        }
                    } else{
                        // in case not found component of this input
                        // ex the field that use plugins that 
                        // store value in the hidden field instead

                        return { name: node.name, value: null};
                    }
                }

                if(field){

	                if(node.className.indexOf('combo') != -1 ){
	                    return {name: node.name, value: field.getValue()}
	                }

	                if(node.className.indexOf('time') != -1 ){
	                    return {name: node.name, value: field.getValue()}
	                }

	                if(node.className.indexOf('checkbox') != -1 ){
	                    return {name: node.name, value: field.getValue()}
	                }

	                if(field.getXType() == "hidden"){
	                    return { name: node.name, value: field.getValue()}
	                }
                }

                // convert to integer if has class name number in the field
                if(node.className.indexOf('number') != -1 ){
                    var v = parseFloat(node.value);
                    if(Ext.isNumber(v)){
                        return {name: node.name, value: v}
                    }
                }
                
                // date convert to y m d ( ruby like )
                if(node.className.indexOf('date') != -1 ){
                    var v = node.value; 
                    if(v){
                        var dmY = v.split('/');
                        var d = dmY[2] + '-' + dmY[1] + '-' + dmY[0];
                        return {name: node.name, value: d}
                    }
                }

                // TODO checkbox in legend
                // act as HTML nature
                // radio
            }

            return false;
        }, false);

		if(options.onlyDirty && !isAnythingUpdate) return {};
        if(!options.skipEmpty){
            // filter null out of params
            var tmp = {};
            Ext.apply(tmp, params);
            for(var k in tmp){
                if(!tmp[k] && tmp[k] == null){
                    delete params[k];
                }
                // nested field support just 2 recursive
                if(tmp[k] instanceof Object){
                	for(var j in tmp[k]){
		                if(!tmp[k][j] && tmp[k][j] == null){
		                    delete params[k][j];
		                }
                	}
                }
            }
        }

        // remove ext name
        var tmp = {};
        Ext.apply(tmp, params);
        for(var name in tmp){
            // ext component
            if(/^ext/i.test(name)){
            	delete params[name];
            }
        }

        return params || {};
    }
    throw new Error("must include form2js lib");
}
// -----------------------------------------------------------------
// ExtJS Patches

// -----------------------------------------------------------------
// fix date convert function
Ext.data.Types['DATE'] = {
    convert: function(v){
        var df = this.dateFormat;
        if(!v){
            return null;
        }
        if(Ext.isDate(v)){
            return v;
        }
        if(df){
            if(df == 'timestamp'){
                return new Date(v*1000);
            }
            if(df == 'time'){
                return new Date(parseInt(v, 10));
            }
            return Date.parseDate(v, df);
        }
        var parsed = Date.parse(v);
        return Ext.isNumber(parsed) ? new Date(parsed) : null;
    },
    sortType: Ext.data.SortTypes.asDate,
    type: 'date'
}

// urlEncode
// fix sending array via url
Ext.urlEncode = function(o, pre){
    var empty,
        buf = [],
        e = encodeURIComponent;

    Ext.iterate(o, function(key, item){
        empty = Ext.isEmpty(item);
        Ext.each(empty ? key : item, function(val){
          if( item instanceof Array ){
            buf.push('&', e(key+"[]"), '=', (!Ext.isEmpty(val) && (val != key || !empty)) ? (Ext.isDate(val) ? Ext.encode(val).replace(/"/g, '') : e(val)) : '');
          } else{
            buf.push('&', e(key), '=', (!Ext.isEmpty(val) && (val != key || !empty)) ? (Ext.isDate(val) ? Ext.encode(val).replace(/"/g, '') : e(val)) : '');
          }
        });
    });
    if(!pre){
        buf.shift();
        pre = '';
    }
    return pre + buf.join('');
}

// -------------------------------------------------------------
// Store
// generic api CRUD
Ext.data.Store.prototype.override({
    // find :id
    delete: function  (id, fn) {
        var self = this;
        $.ajax({
            url: this.url + "/" + id,
            type: "delete",
            success: function(res) {
            if(res.success) {
                // Ext.Notify.success("Delete Successful!");
                fn && fn.apply(self, [res.record]);
            } else{
                Ext.Notify.error(res);
              }
            }
        });
    },

  update: function  (id, fn, obj, opt) {
    var self = this;
    if(obj instanceof Ext.form.FormPanel){
      var config = Ext.apply({
        url: this.url + "/" + id,
        type: "put",
        success: function  (res) {
          // Ext.Notify.success("Update Successful!");
          fn && fn.apply(self, [res.record]);
        }
      }, opt);
      obj.submit(config);
    }
  },

  create: function(frm, fn, opt) {
    var self = this;
    var opt = opt || {};
    if(frm instanceof Ext.form.FormPanel){
      var config = Ext.apply({
        url: this.url,
        type: "post",
        success: function  (res) {
          if(!opt.notify){
            // Ext.Notify.success("Create Successful!");
          }
          fn && fn.apply(self, [res.record]);
        }
      }, opt);
      frm.submit(config);
    }
  },

  dup: function  () {
    // Wed113923
    var randId = (new Date()).format("DHis");
    return new this.constructor({storeId: randId});
  }
});

// depend underscorejs
Ext.apply(Ext.data.Store.prototype,{
  untilLoaded: function(fn, wait) {
    this.load()   
  },

  all: function() {
    return _.map(this.data.map,function(o, k) {
      return o.data; 
    });
  },

  reset: function  () {
    // silient remove; not fire event clear
    this.removeAll(); 
  }
});

// ----------------------------------------------------------
// Field
Ext.form.Field.override({
  _con: Ext.form.Field.prototype.constructor,
  constructor: function  (config) {
    config = config = {};
    
    // validate option
    if(config.plugins){
      config.plugins.push({ptype: "multiple_validations"});
    } else{
      config.plugins = [{ptype: "multiple_validations"}];
    }

    // add new events
    this.addEvents({
      changed: true
    });
    this._con(config)
  },
  _setValue: Ext.form.Field.prototype.setValue,
  setValue: function (v) {
    var o = this.getValue();
    this._setValue(v);
    var n = this.getValue();
    if(o !== n) this.fireEvent("changed", n, o);
  }
})

// ----------------------------------------------------------------
// BasicForm
/*
Ext.form.BasicForm.getObjectValues
Features
    * focus on submitValue = true only
    * return form values with type
    * traverse all elements in form without tab activate or fieldset expand needed
modify from sencha forum
http://www.sencha.com/forum/showthread.php?42559-form-getValues()-not-return-float-type-value-of-NumericField&p=202219&viewfull=1#post202219
*/
Ext.form.BasicForm.override({
    getObjectValues: function(cfg) {
        var o = {};
        this.items.each(function(item) {
            if (item.isFormField && item.submitValue && !item.disabled) {
                if(item.xtype == 'radio'){
                    if(item.checked){
                        o[item.name] = item.inputValue;
                    }
                    else if(o[item.name] == undefined){
                        o[item.name] = '';
                    }
                }
                else if(item.xtype == 'combo'){
                    // support manual input
                    if(item.store.data.length){
                        var v;
                        item.store.each(function(r){
                            if(r.data[this.displayField] == this.getRawValue()){
                                v = r.data[this.valueField];
                                return;
                            }
                        }, item);
                        item.setValue(v);
                    }
                    // return
                    o[item.name || item.hiddenName] = item.getValue();
                }
                else {
                    o[item.name || item.hiddenName || item.id] = item.getValue();
                }
            }        
        });
        // config
        if(cfg){
            // notnull
            if(cfg.notnull){
                for(i in o){
                    if(o[i] == ''){
                        delete o[i];
                    }
                }
            }
        }
        return o;
    }
});


// ---------------------------------------------------------------
// FormPanel
Ext.override(Ext.form.FormPanel, {
    // config:
    // prefix_param or root_param: 
    // url: 
    // type: ajax verb usually put or post
    // success: callback
    // failure: callback
    // reset: reset after sending ajax success ?
    oldSubmit: Ext.form.FormPanel.prototype.submit,
    submit: function(config) {
        var self = this;
        var f = this.getForm();
        var serializeOption = Ext.apply({ onlyDirty: true, includeGrid: true }, config.serializeOption);
        // TODO option to inlcude grid records as params

        if(config.type && config.type === "put"){
          Ext.apply(serializeOption, { skipEmpty: false });
          var data = self.serializeObject(serializeOption); 
          if($.isEmptyObject(data)){
              Ext.Notify.msg({text: "Nothing changed!", type:"warning"});
              return false; 
          }
        } else{
            if(!config.serializeOption){
              Ext.apply(serializeOption, {onlyDirty: false} );
            }
            var data = self.serializeObject(serializeOption);
        }
          
        if(config.prefix_param || config.root_param){
            var o = {};
            o[config.prefix_param || config.root_param] = data;
            data = o;
        }

        // cache callback
        var suc = config.success;
        var fail = config.failure;
        var reset = config.reset;
        // function returned params
        var serialized = config.serialized;

        // serialized params
        // modify params before sending
        if(typeof serialized == "function"){
          data = serialized.apply(null, [data]); 
          // do nothing if the function return false
          if(data == false) return false;
        }

        var loadding; // notification element

        var defaults = {
            url: f.url,
            type: "post",
            reset: true, // reset form 
            contentType: "application/json",
            // clientValidation: true,
            dataType: "json",
            data: Ext.encode(data),
            // defer to use global setup
            // beforeSend: function() {
            //   loadding = Ext.Notify.msg({text:"Sending ...", type: "inform"});
            // },
            error: function() {
              // Ext.Notify.close(loadding)
              Ext.Notify.error("Ajax communication failed");
            },
            success: function (res){
                // return if not login
                if(res && res.response_code == "99"){
                  Ext.Notify.warning("Please Login");
                  return false;
                }

                // Ext.Notify.close(loadding);

                if(res.success){
                    //Ext.Notify.msg({text: "Action Complete", type: "success"});
                    if(reset){
                        f.reset();
                        grds = self.findByType("editorgrid");
                        Ext.each(grds,function(g, index){
                            g.reset(); 
                        });
                    }

                    // success but have warning message
                    if(res.warning_message){
                      Ext.Notify.warning(res.warning_message);
                    }

                    // TODO do more stuff if config.sucess given
                    if(suc) suc(res); 
                } else{
                    var msg = [];
                    Ext.iterate(res.error,function(k,v){
                        err = {};
                        err['error_field'] = k;
                        err['error_msg'] = v
                        msg.push(err)
                    });

                    // var err_temp = new Ext.XTemplate(App.Template.form_error);
                    // var err_disp = err_temp.apply(msg);
                    // if(msg.length > 0)
                    //   var err_disp = "There are some invalid fields.<br/> Please see the highlights<hr/>"
                    // else
                    var err_disp = "";
                    
                    Util.form.markInvalid(res, self.body.dom, function  (remain_errors_msg) {
                        err_disp += remain_errors_msg;
                    });

                    if(err_disp != "")
                      Ext.Notify.error(err_disp);
                    else
                      Ext.Notify.error("There are some invalid fields<br/>Please see the highlights");
                    
                    if(fail) fail(res);
                }
            }
        }

        if(config.success) delete config.success
        if(config.failure) delete config.failure

        config = Ext.applyIf(config, defaults);
        // TODO use Ext Ajax 
        $.ajax(config)
    },

    isValid: function  () {
      if(this.getForm().isValid()){
        return true; 
      } else{
        Ext.Notify.error("The Form is invalid please see the hilights");
        return false;
      }
    }
});

Ext.override(Ext.form.FormPanel, {
    /*
     * options
     * :onlyDirty 
     * :includeGrid
     */
    serializeObject: function(options){
       options = options || {};
       Ext.applyIf(options, { onlyDirty: true });
       var o = Util.form.serializeJson(this, options); 
       if(options.includeGrid){
          // find editorgrid 
          var editorgrids = this.findByType("editorgrid", true);
          var grids = this.findByType("grid", true);
          grids = grids.concat(editorgrids);
          Ext.each(grids, function(g, index) {
             // auto convert id to key
             var name = g.id.replace(/\-/g,"_");
             if(/^ext/i.test(name)) return false;
             var recs = g.serializeObject(options);
             if(recs.length > 0){
                if(Ext.isArray(o[name]))
                  o[name] = o[name].concat(recs);
                else 
                  o[name] = recs;
             }
          });
       }
       return o;
    },

    fillData: function (data, options) {
      options = options || {};
      Ext.applyIf(options, {
        modify: false
      });
      Util.form.loadObject(this, data, options)

      // fill data in grid if has an id
      // collect grids in this form
      var gs = this.findByType("grid", true);
      var egs = this.findByType("editorgrid");
      var grids = gs.concat(egs);
      _.each(grids, function(g) {
        if(g.id){
          var attr = g.id.replace(/\-/ig, "_"); // association_attributes
          var prefix = attr.split("_")[0];      // association
          var d = data[attr] || data[prefix];
          if(d) g.addRecords(d, true);
        }
      });
      return this;
    },

    reset: function  () {
      this.getForm().reset(); 
    },

    readOnly: function  () {
      this._eachField(function  (el, i) {
        el.setReadOnly(true);
      }); 
      return this;
    },

    // disable all child elements
    disable: function  () {
      this._eachField(function  (el, i) {
        el.disable();
      }); 
      return this;
    },

    enable: function  () {
      this._eachField(function  (el, i) {
        el.setReadOnly(false);
        el.enable();
      }); 
      return this;
    },

    findField: function(id){
      this.getForm().findField(id); 
    },

    _eachField: function(fn) {
      _.each(this.getForm().items.items, fn);
    }
});

// ------------------------------------------------------------
// DateField
Ext.override(Ext.form.DateField, {
    getSqlValue: function(){
        var v = this.getValue();
        return v == '' ? '' : v.format('Y-m-d');
    }
});

Ext.override(Ext.form.DateField,{
    // to serve key input style like 22032012 => 22/03/2012
    altFormats: Ext.form.DateField.altFormats + '|dmY'
});

// --------------------------------------------------------------
// ComboBox
Ext.override(Ext.form.ComboBox, {
    getRecord: function() {
        return this.findRecord(this.valueField, this.getValue()) || false; 
    },
    setFilter: function(opt) {
        opt = opt || {}; 
        var s = this.getStore();
        if(s){
            s.baseParams = opt;
            s.load();
        }
    },
    resetFilter: function  () {
        var s = this.getStore();
        if(s){
            s.baseParams = {};
            s.load();
        }
    }
});

// ------------------------------------------------------------
// Button
Ext.override(Ext.Button, {
    _onClick: Ext.Button.prototype.onClick,
    onClick: function() {
        // override to add before click action
        // to prevent creating duplicated records on multi-clicks
        var self = this;
        var text = this.getText();
        Ext.Button.prototype._onClick.apply(this, arguments);
        if(text && /save|create|new|update|delete|upload|login|add|submit|confirm/ig.test(text)){
            if(self) self.disable();
            setTimeout(function  () {
                if(self) self.enable();
            }, 1000);
        }
    }
});

// ---------------------------------------------------------------
// Extend GridPanel
Ext.ux.GridPanel = Ext.extend(Ext.grid.GridPanel,{
    getRowClass: function(r, index) {
      if((index % 2) == 1){
        return "grd-odd-row";
      } 
    },

    constructor: function  (config) {
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

        Ext.ux.GridPanel.superclass.constructor.call(this)
    },

    initComponent: function(config){
        Ext.ux.GridPanel.superclass.initComponent.call(this, config);
        var self = this;
        // set up page size if paging is set
        var paging = this.getBottomToolbar() || this.getFooterToolbar(); 
        if(paging && this.store){
          // setup store paging 
          this.paginator = paging;
          this.store.defaultParams = { start: 0, limit: paging.pageSize };
          this.paginator.on({
            change: function  () {
              self.fireEvent("datachanged");
            }
          });
        }

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
            _.each(this.colModel.lookup, function(c) {
              if(c.hilight){
                if(typeof c.hilight != "string"){
                  // default yellow
                  c.hilight = "#ff8";
                }
                self.hilightColumn(c.dataIndex, c.hilight);
              }
            });

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

Ext.reg("grid", Ext.ux.GridPanel);

// add shortcut function for grid
Ext.applyIf(Ext.grid.GridPanel.prototype, {
   // alias for getting the selected row
   getCurrentRecord:  function () {
        return this.getSelectionModel().getSelected();
   },

   getSelectedRow:  function () {
        return this.getSelectionModel().getSelected();
   },

   // get column object by dataIndex property
   getColumnByDataIndex: function(dataIndex) {
      var i = this.colModel.findColumnIndex(dataIndex);
      return this.colModel.getColumnAt(i);
   },

   // alias for getting modified records from its store
   // return array of records
   getChangedRecords: function  () {
      return this.store.getModifiedRecords();
   },

   // remove selected row
   // option default {force: false}
   removeSelectedRow: function(option) {
      option = option || {};
      Ext.applyIf({force: false}, option);
      var rec = this.getSelectionModel().getSelected();
      // corresponds with rails params attributes for
      // association destroy
      if(!option.force){
        this.addModifiedRecord(rec, { _destroy: true} )
      } else{
        this.getStore().pruneModifiedRecords = true;
      }
      // update display
      this.getStore().remove(rec);

      // fireEvent
      this.fireEvent("datachanged", rec);
      return this;
   },

   // remove selected rows
   // option default {force: false}
   removeSelectedRows: function(option) {
      rows = this.getSelectedRows();
      for(var i = 0; i < rows.length; i++){
          this.removeSelectedRow(option);
      }
   },

   addModifiedRecord: function(rec, extra) {
      extra = extra || {};
      Ext.apply(rec.data, extra);
      this.store.modified.push(rec);
      return rec;
   },

   // remove all rows
   reset: function  () {
      this.getStore().pruneModifiedRecords = true;
      this.getStore().removeAll();
      this.fireEvent("datachanged");
   },

   // shorcut to load data from server
   fetch: function(params, options) {
      var self = this;
      options = options || {}
      params = params || {};
      var st = this.getStore();
      st.baseParams = Ext.applyIf(params, st.defaultParams || {});
      this.changePage(1);
      if(typeof options == "function"){
        st.load({
          callback: function(data) {
            if(!data.success){
              Ext.Notify.error(data.message);
            }
            self.fireEvent("datachanged", data);
            options.apply(self)
          }
        });
      } else{
        st.load({
          callback: function(data, option, success) {
            if(!success){
              var msg = this.reader.jsonData.message || "Invalid";
              Ext.Notify.error(msg);
            }
            self.fireEvent("datachanged", data);
          }
        });
      }
      return this;
   },

   changePage: function(page) {
     if(this.paginator && this.paginator.getPageData().activePage != 1){
        this.paginator.changePage(page);
     }
     return this;
   },

   // remove record at index
   removeAt: function(index) {
      this.fireEvent("datachanged");
      return this.store.removeAt(index);
   },

   // get record at the given index
   getRecordAt: function(index) {
      return this.store.getAt(index);
   },

   // prepend or append new record on fly
   addNewRecord: function (data, option) {
      option = option || {};
      Ext.applyIf( option, { append: false, effect: true });
      var st = this.getStore();
      var DataObj = st.recordType;
      var newRow = new DataObj(data)
      if(option.append == true){
        st.insert(st.getCount(), newRow)
        this.getSelectionModel().selectRow(st.getCount() - 1);
      } else{
        st.insert(0, newRow);
        this.getSelectionModel().selectRow(0);
      }

      if(option.effect) this.doEffectOnSelectedRow();

      this.fireEvent("datachanged", newRow);
      return newRow;
   },

   // data is object with no root
    updateSelectedRow: function(data) {
      var r = this.getSelectedRow();
      Ext.apply(r.data, data);
      Ext.apply(r.json, data);
      // make a change
      this.doEffectOnSelectedRow();
      r.commit();
      // but still be modified record
      this.addModifiedRecord(r);
      this.fireEvent("datachanged", r);
      return r;
    },

    doEffectOnSelectedRow: function() {
       var el = this.getSelectedRowEl();
       el && el.fadeOut().fadeIn();
       return this; 
    },

    // add records by passing object
    addRecords: function(data, thenCommit) {
      thenCommit = thenCommit || false;
      var st = this.store;
      recs = _.map(data, function(o) {
        return new st.recordType(o)
      });
      st.add(recs);
      if(thenCommit) this.getStore().commitChanges();

      this.fireEvent("datachanged", recs);
      return this;
    },

    // get selected index of cached store
    getSelectedIndex: function() {
        return this.store.indexOf(this.getSelectedRow());
    },

    // get selected row in Ext.Element
    getSelectedRowEl: function(){
        return Ext.fly(this.view.getRow(this.getSelectedIndex()));
    },

    // return array of object that corespond with its column
    serializeObject: function(options) {
        options = options || {};
        Ext.applyIf(options, { onlyDirty: true })
        var self = this;
        var res = [];
        var items = this.getStore().getModifiedRecords();

        Ext.each(items, function(item, i){
            res.push(item.data)
        });
        return res;
    },

    // get all records
    // ** return array of json; not Object Class RecordType as usual
    getAllRecords: function() {
        return this.store.all();  
    },

    // get all selected record incase multi selections
    getSelectedRecords: function  () {
        var r = this.getSelectionModel();
        if(r instanceof Ext.grid.CellSelectionModel ){
            var rec = r.getSelectedCell();
        } else{
            var rec = r.getSelections();
        }
        return rec;
    },

    // getSelectedRecords nickname
    getSelectedRows: function(){
        return this.getSelectedRecords();
    },

    // get field values of selected records, return as array of field values
    getSelectedFields: function(config){
        var rs = this.getSelectedRecords();
        if(config.column){
            rs = _.map(rs, function(r){ return r['data'][config.column]; });
        }
        if(config.unique){
            rs = _.unique(rs);
        }
        return rs;
    },

    // native find rows
    findRowsBy: function(filterFn){
        var all_rows = this.store.getRange();
        return _.filter(all_rows, filterFn);
    },

    // find rows by field values
    findRowsByField: function(field, values){
        values = [].concat(values);
        return this.findRowsBy(function(r){
            return _.include(values, r['data'][field]);
        });
    },

    hilightColumn: function(dataIndex, color) {
      // memo style
      this.colStyle = this.colStyle || {};
      this.colStyle[dataIndex] = { backgroundColor: color };
      this.styleColumn(dataIndex, this.colStyle[dataIndex]);
    },

    styleColumn: function  (dataIndex, css) {
      var col = _.find(this.view.cm.lookup, function(r) {
        return r.dataIndex == dataIndex;
      });

      if(col){
        var i = col.id;
        var cls = ".x-grid3-col-" + i;
        $(cls, this.el.dom).css(css);
      }
    }
});

// ----------------------------------------------------------------
// Extend EditorGridPanel
Ext.ux.EditorGridPanel = Ext.extend(Ext.grid.EditorGridPanel,{
    constructor: function  (config) {
      config = config || {};
      Ext.apply(this, config)
      this.addEvents({
        datachanged: true 
      });
      Ext.ux.EditorGridPanel.superclass.constructor.call(this)
    },
    initComponent: function(config){
        Ext.ux.EditorGridPanel.superclass.initComponent.call(this, config);
        var self = this;
        // set up page size if paging is set
        var paging = this.getBottomToolbar() || this.getFooterToolbar(); 
        if(paging && this.store){
          // setup store paging 
          this.paginator = paging;
          this.store.defaultParams = { start: 0, limit: paging.pageSize };
        }

        this.on({
          // it should clear cached records everytime before render
          // incase record appear at the same store but difference page
          beforerender: function  () {
            this.store.removeAll();
          },

          afterrender: function  () {
            // set column hilight
            _.each(this.colModel.lookup, function(c) {
              if(c.hilight){
                if(typeof c.hilight != "string"){
                  // default yellow
                  c.hilight = "#ff8";
                }
                self.hilightColumn(c.dataIndex, c.hilight);
              }
            });
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

Ext.override(Ext.grid.EditorGridPanel,{

    // alias for getting record from its store
    getCurrentRecord: function() {
      return this.getSelectionModel().selection && this.getSelectionModel().selection.record
    },

    // alias
    getSelectedRow: function() {
      return this.getCurrentRecord();
    },

    // prepend new record 
    // @data : object of record
    addNewRecord: function (data) {
       var DataObj = this.getStore().recordType;
       var newRow = new DataObj(data)
       this.stopEditing();
       this.getStore().insert(0, newRow);
       this.startEditing(0,0)
       // sync size
    },

    serialize: function() {
        return Ext.encode(this.toJson);
    },

    // set editor for grid
    setEditorFor: function(dataIndex, extFormField) {
        var col = this.getColumnByDataIndex(dataIndex);
        col.setEditor(extFormField)
    },
    
   // remove selected row
   removeSelectedRow: function() {
      // remove mod record
      this.getStore().pruneModifiedRecords = true;
      this.getStore().remove(this.getSelectedRow());
   },

   removeSelectedRecord: this.removeSelectedRow

});

Ext.reg("editorgrid", Ext.ux.EditorGridPanel);

// cache-able loader for lazy load
Ext.loadedScripts = [];
Ext.load = function() {
    var args = [];
    var scriptList = arguments[0];
    var toLoadScripts = [];
    Ext.each(scriptList, function (script, index, all) {
        // the script have never been loaded before
        if($.inArray(script ,Ext.loadedScripts) == -1){
            Ext.loadedScripts.push(script);
            toLoadScripts.push(script);
        }
    });
    args[0] = toLoadScripts;
    args[1] = arguments[1] || function(){}; // do nothing
    args[2] = arguments[2] || window; // global scope
    args[3] = arguments[3] || true; // preserved include order
    if(toLoadScripts.length > 0) Ext.Loader.load.apply(Ext.Loader, args);
    else arguments[1](); 
}


Ext.override(Ext.grid.GroupingView,{
    // mod to allow customization at each group header
    _startGroup: function(g, text) {
        var t = [];
        t.push('<div id="'+g.groupId+'" class="x-grid-group '+g.cls+'">');
        t.push('<div id="'+g.groupId+'-hd" class="x-grid-group-hd" style="'+g.style+'"><div class="x-grid-group-title">'+ text +'</div></div>');
        t.push('<div id="'+g.groupId+'-bd" class="x-grid-group-body">');
        return t.join("");
    },

    doGroupStart : function(buf, g, cs, ds, colCount){
        if(typeof this.groupTextTpl == "function"){
            buf[buf.length] = this._startGroup(g, this.groupTextTpl(g));
        } else{
            buf[buf.length] = this.startGroup.apply(g);
        }
    }

});

// ---------------------------------------------------------------
// GridView
Ext.override(Ext.grid.GridView, {
    getTotalWidth : function() {
        return (this.cm.getTotalWidth() + 20) + 'px';
    }
});

// --------------------------------------------------------------
// Ext.confirm : alias for Ext.Msg.confirm
Ext.confirm = function (msg, yesDo, noDo) {
    Ext.Msg.confirm("Comfirm ?", msg, function (ans) {
        if(ans == "yes"){
            if(typeof yesDo == "function") {
                yesDo();
            }
            else throw new Error("need to supply callback function");
        }
        else{
            if(typeof noDo == "function"){
                noDo();
            } 
        }
    });
}
// ---------------------------------------------------------------------------
// source : http://www.sencha.com/forum/showthread.php?14246-Combo-s-with-inline-data&p=136997I
// combo with inline data
// usage
// store: [ [k, v], [k, v] ...]
// or store: [a, b, c, ..]
Ext.ux.ComboBox = Ext.extend(Ext.form.ComboBox, {
    constructor: function(config){
        config = config || {};
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
        Ext.apply(this, config);
        this.loadingText = "loading ...";
        Ext.ux.ComboBox.superclass.constructor.call(this, config);
    },

    initComponent: function(){
        // console.log('store loading...', this.store)
        Ext.ux.ComboBox.superclass.initComponent.call(this)
        var self = this;
        if(!this.initialConfig.lazyInit && 
            this.initialConfig.mode == "local"){
            var s = self.getStore();
            if(s && s.storeId && s.url && !s.cache && !s.autoLoad) {

                s.load({
                    callback:function(rec) {
                        self.setValue(self.getValue());
                        //console.log("lazyinit", self.getValue(), rec)
                        self.originalValue = self.getValue();
                    }
                });
                s.cache = true;
            } else if(s.cache){
                // incase use the same store with local mode
                // console.log("cached load", s.storeId, self.name, self.getValue() )
                self.setValue(self.getValue());
                self.originalValue = self.getValue();
                self.fireEvent("select", self) 
            }
        }
    },

    setRemoteValue: function(v, key, cb, extraParams) {
        if(!v){
            console.log("is blank ---------", v, this.getName())
            return false;
        }
        var self = this;
        extraParams = extraParams || {};
        if(!key){
            key = this.queryParam;
        }
        if(this.mode == "remote" && !this.autoLoad){
            var s = this.getStore();
            // build params
            var params = {};
            params[key] = v;
            var val = v;
            s.load({
                params: Ext.apply(params, extraParams),
                beforeload: function(){
                   self.setRawValue("");
                },
                callback:function(rec) {
                   var rec = rec[0];
                   if(rec){
                       self.setValue(rec.data[self.valueField]);
                       // self.setRawValue(rec.data[self.displayField]);
                       cb && cb.apply(null, [rec]);
                   }
                }
            });
        }
    },

    // set options manually
    setOptions: function  (arrObj, config) {
        if(arrObj instanceof Array){
            var self = this;
            this.valueField = config.value || "id";
            this.displayField = config.text;
            var d = arrObj[0];
            var f = _.keys(d);
            f = _.map(f, function(r) {
                return { name: r };
            });

            if(config.filter && typeof config.filter == "function"){
               arrObj = _.filter(arrObj, config.filter);
            }

            var ss = new Ext.data.JsonStore({
                // get all keys to build store
                fields: f,
                data: arrObj
            });

            this.store = ss;
            this.itemSelector = "x-combo-list-item";

            var tpl = [];
            tpl.push('<tpl for=".">');
                tpl.push('<div class="x-combo-list-item">');
                tpl.push("{"+config.text+"}");
                tpl.push('</div>');
            tpl.push('</tpl>');

            this.tpl = tpl.join("");

            this.view.tpl = new Ext.XTemplate(tpl.join(""));
            this.view.bindStore(ss)
            this.view.refresh();
        }
    }
});

Ext.reg('combo',Ext.ux.ComboBox);
