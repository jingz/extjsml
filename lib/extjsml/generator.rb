require 'yaml'
require "json"
# require "awesome_print"
# require "jsmin"
BASE_DIR = File.dirname(__FILE__) 

# $: << File.dirname(__FILE__) 
require_relative "./parser"
require_relative "./ext_util"
require_relative "./basenode"


Dir.open("#{BASE_DIR}/../extmodules").each do |f|
  next unless f.match /rb$/ 
  require "extmodules/#{f}"
end

Dir.open("#{BASE_DIR}/../extclasses").grep(/rb$/).each do |f|
  require "extclasses/#{f}"
end

Dir.open("#{BASE_DIR}/../extplugins").grep(/rb$/).each do |f|
  require "extplugins/#{f}"
end

Dir.open("#{BASE_DIR}/../extuxs").grep(/rb$/).each do |f|
  require "extuxs/#{f}"
end

# recusive building node tree
def build_node(*args, &block)
  element = args[0]
  parent = args[1]
  params = args[2] || {}

  if parent.nil?
    k = element.keys.first
    v = element[k]
    xtype, options = ExtParser.parse(k)		
    options = yield(xtype, options) if block_given?
    xtype = ExtUtil.xtype_alias(xtype);
    node = eval("Ext#{xtype.capitalize}").new(options, parent)
    node.add_child build_node(v, node, &block)
    return node
  end

  if element.is_a? Hash
    begin
      wrapper_hash = ExtContainer.new({ layout: "fit", autoHeight: true, 
                                        style: "{height: 100%; margin: 0em 0em;}", 
                                        defaults: { margins: "0 0"}}, parent)
      element.each do |k,v|
        xtype, options = ExtParser.parse(k)		
        options = yield(xtype, options) if block_given?
        xtype = ExtUtil.xtype_alias(xtype);
        node = eval("Ext#{xtype.capitalize}").new(options, parent)
        node.add_child(build_node(v, node, &block))
        node.childs.each do |c|
          if c.xtype == "container" and 
            c.config[:layout] == "hbox" and 
            node.xtype == "container" and
            if c.child_of? "fieldset", "form"
              c.config.delete :labelWidth
              c.childs.each do |_c|
                # _c.config.delete :labelWidth
                _c.config.delete :defaults
                _c.config.delete :style
                _c.config.merge!({:margins => "0 0", :col_index => 0})
                _c.childs.each do |_f|
                  if ExtUtil.field_xtype.include? _f.xtype
                    # _f.config.delete :labelWidth 
                    # break;
                  end
                end
                break;
              end
          end
          end
        end
        wrapper_hash.add_child node
      end 

      # skip wrapper
      if wrapper_hash.child_of?("viewport","container","grid","toolbar", "tabpanel", "form", "window", "editorgrid", "radiogroup", "checkboxgroup", "fieldset")
        # unwrap
        wrapper_hash = wrapper_hash.childs
      end
      wrapper_hash
    rescue Exception => e
      puts e.message, __FILE__, __LINE__, "in Hash" 
      raise e
    end
  elsif element.is_a? Array
    begin

      if element[0].is_a? Array
        new_element = element

        # default config
        inherit_config = {
          margins: "0 2.5"
        }

        # temp config of parent
        _config = {}
        if ExtUtil.container_xtype.include?(parent.xtype)
          # _config.merge!({ :padding => parent.config[:padding] }) if parent.config[:padding]
          _config.merge!({ :margins => parent.config[:margins] }) if parent.config[:margins]
        end
        inherit_config.merge! _config
        wrapper = ExtContainer.new({ layout: "hbox", 
                                     layoutConfig: { pack: "start", align: 'stretchmax'}, 
                                     defaults: inherit_config }, 
                                     parent)
        new_element.each_with_index do |el, col|
          wrapper.add_child(build_node(el, wrapper, { :col_index => col } , &block))
        end

        wrapper
      else
        node = ExtContainer.new({ layout: "anchor", 
                                  style: "{ height: 100%; margin: 0em 0em; }", 
                                  defaults: { margins: "0 0"}}, parent)
        element.each_with_index	do |el, col|
          node.config.merge! params
          node.add_child(build_node(el, node, &block))
        end

        # check first child is the field component
        if node.childs.count > 0
          if ExtUtil.field_xtype.include?(node.childs.first.xtype) and 
            "toolbar" != parent.xtype
            # inherit fieldLableWidth 
            _config = { :layout => "anchor" }
            _config = { :layout => "hbox" } if parent.xtype == 'fieldcontainer'
            pnode = node.find_parent("form","fieldset");
            # calculated proper labelWidth
            lw = []
            mlb = 0 # max label width
            offset = 15 # offset label width TODO ??
            is_contain_fieldset = false
            node.childs.each  do |c|
              next if c.xtype == "hidden"
              is_contain_fieldset = true if c.xtype == "fieldset"
              if ["radiogroup","checkboxgroup"].include? c.xtype
                lb = [] 
                c.childs.each do |r|
                  _lb = r.config[:boxLabel].size * ExtUtil.FontWidthRatio + offset unless r.config[:boxLabel].nil?
                  lb << _lb
                  r.override_config :width => _lb + offset 
                end
                if lb.max > 0 and not c.config[:width]
                  lb_width = lb.inject(&:+)
                  # c.override_config :width => (lb.max * lb.count) if lb.max > 0 
                  c.override_config :width => lb_width
                end
              end
              lw << c.config[:fieldLabel].size * ExtUtil.FontWidthRatio + offset unless c.config[:fieldLabel].nil?
            end

            if parent.config[:fieldLabel]
              lw << parent.config[:fieldLabel].size * ExtUtil.FontWidthRatio + offset
            end

            _config.merge! :labelWidth => lw.max || 10 if pnode and pnode.config[:labelWidth].nil?

            node.override_config _config
            node.config.merge! :defaults => { :labelWidth => lw.max }

            # fix for chrome 21.x
            # container should have layout auto for fieldset
            if is_contain_fieldset
              node.override_config :layout => "auto"
            end

            if parent and parent.xtype == "container" and parent.config[:layout] == "hbox"
              parent.config.merge! :labelWidth => lw.max 
            end
            # end

            # update config if setting fileuploadfield
            if node.childs.any? {|n| n.xtype == "fileuploadfield"}
              f = node.find_parent("form")
              unless f.nil?
                f.config.merge! :frame => true, :fileUpload => true 
              else
                puts "warning: fileupload may need to be rendered under a form"
              end
            end

          end
        end

        # unwrap
        if node.child_of?("grid","toolbar", "editorgrid", "radiogroup", "checkboxgroup") or ["fieldset", "tabpanel","form", "window", "toolbar", "compositefield", "fieldcontainer"].include? parent.xtype
          unless _config.nil? and parent
            parent.config.merge! _config
            #puts "#{parent.xtype}, #{_config}"
          end
          node = node.childs
        end

        node
      end
    rescue Exception => e
      puts e.message, e.backtrace, __FILE__, __LINE__, "in Array of"
      raise e
    end

  elsif element.is_a? String
    # leaf node
    xtype, options = ExtParser.parse(element)		
    options = yield(xtype, options) if block_given?
    xtype = ExtUtil.xtype_alias(xtype);
    node = eval("Ext#{xtype.capitalize}").new(options, parent)
  end
end

def compile_jext(yaml_str, js_class, options={})
  original_source = yaml_str.read
  preload_state = /^:?preload.*/.match original_source
  preload_source = false
  if preload_state
    preload_state = YAML.load(preload_state.to_s)
    preload = preload_state[:preload].split(/\s+/)
    if preload.is_a? Array
      preload_source = []
      preload.each do |path|
        path.gsub!(/^\.\//, '')
        extend_path = "#{options[:filedir]}/#{path}"
        preload_source << "#{path}:\n"
        another_script = File.open(extend_path, 'rb') do |f|
          while not f.eof
            l = f.readline
            preload_source << "  #{l}"
          end
        end
      end
    end
  end

  load_source = preload_source ? preload_source.join('') + original_source : original_source
  # puts load_source
  ast = YAML.load(load_source)
  # ap ast
  # require "awesome_print"
  # separate layout and config
  layout = ast[:layout]
  raise "require layout" if layout.nil?

  config = ast[:config] || ast['config'] || {}
  engine = ast[:engine] || ast['engine'] || {}

  js_class = engine[:class] || js_class.capitalize

  config.each do |k,v|
    if v.has_key? :as
      # TODO nested as 
      # lookup shared config
      begin
        sharedconfig = YAML.load(File.open("#{BASE_DIR}/sharedconfig/#{v[:as]}.yaml","r"))
      rescue Exception => e
        p "raise", __FILE__, __LINE__
        puts "not found #{v[:as]} config in #{BASE_DIR}/sharedconfig/"
      end
      v.delete :as
      v = sharedconfig.merge v
      config[k] = v
    end
  end unless config.nil?

  begin
    root_node = build_node(layout, nil) do |xtype, opt|

      unless config.nil?
        opt.merge! config[xtype] unless config[xtype].nil?
        opt.merge! config[opt[:id]] unless config[opt[:id]].nil?
      end

      if opt[:as]
        # read sharedconfig
        begin
          sharedconfig = YAML.load(File.open("#{BASE_DIR}/sharedconfig/#{opt[:as]}.yaml","r"))
          opt = sharedconfig.merge opt
        rescue Exception => e
          puts "#{e.message} not found #{opt[:as]} config in #{BASE_DIR}/sharedconfig/"
        end
        opt.delete :as
      end

      opt
    end
  rescue Exception => e
    p "raise", __FILE__, __LINE__, e
    raise e
  end

  # tree has built

  # set to_extjs option
  engine.merge! options
  ExtNode.set_generator_config(engine)

  # extjs_tree = root_node.to_extjs
  event_template = []
  ExtNode.get_events.each do |el, h|
    event_template << "self.#{el}.on(\"#{h[0]}\", self.#{h[1]}, self);"
  end

  unless engine[:with_requirejs]

    ui_class_content = %Q{ 
    var #{js_class}UI = Ext.extend(#{root_node.xtype.to_extclassname},{
    #{JSON.pretty_generate(root_node.config).gsub!(/\{|\}/,"").strip!},
  initComponent: function(){
    Ext.applyIf(this,#{root_node.config={};nil}
    #{JSON.pretty_generate(root_node.to_extjs, { space: "", max_nesting: 50})});
    #{js_class}UI.superclass.initComponent.call(this);
    var self = this;
    #{event_template.join("\n")}
    #{ExtNode.get_refs.map{|id, ref| "self._#{ref} = Ext.getCmp(\"#{id}\");"}.join("\n")}
  }
});
    }.strip
  else
    res_json = JSON.pretty_generate(root_node.to_extjs, { space: "", max_nesting: 50})
    required_store = ExtNode.get_used_store_filename
    ui_class_content = %Q{ 
define(#{required_store}, function(){
  var #{js_class}UI = Ext.extend(#{root_node.xtype.to_extclassname},{
    #{JSON.pretty_generate(root_node.config).gsub!(/\{|\}/,"").strip!},
    initComponent: function(){
      Ext.applyIf(this,#{root_node.config={};nil}#{res_json});
      #{js_class}UI.superclass.initComponent.call(this);
      var self = this;
      #{event_template.join("\n")}
      // manually make auto ref
      Ext.each(self.query('*'), function(element, index){
        if(element.cmp_id) {
          self["_" + element.cmp_id] = element;
        }
      });
    }
  });

  return #{js_class}UI;
});
      }.strip
  end

  # INQUIRY
  eve_inqury = ""
  if engine[:mode] == "inqury"
    # Must have base
    base_model = engine[:base]
    # TODO 
    eve_inqury = %Q{
    self.search.on({
      click: function(){
        if(self.frm.isValid()){
          var params = Ext.apply(self.frm.serializeObject({ onlyDirty: false}), { model: "#{base_model}" });
          self.grd.fetch(params);
        }
      }
    });

    self.toggleWidth.on({
        click: function() {
            var el_id = "#" + this.el.id;
            var filter_id = "#" + self.frm.id;
            var pressed = $(el_id).attr("is_pressed");
            if(pressed == "t"){
                $(el_id).attr("is_pressed", "f");
                this.setText("Expand Width");
                self.grd.setSize(780); // TODO
                self.grd.doLayout();
                $(filter_id).parent().fadeIn();
            } else{
                $(el_id).attr("is_pressed", "t");
                this.setText("Reduce Width");
                var w = $(window.document).width() - 50;
                self.grd.setSize(w);
                self.grd.doLayout();
                $(filter_id).parent().hide();
            }
        }
    });

    self.exportXlsx.on({
      click: function() {
        if(self.frm.isValid()){
          var params = Ext.apply(self.frm.serializeObject({ onlyDirty: false}), { model: "#{base_model}", export_xlsx: true });

          if(self.grd.store.getSortState()){
            var sort = self.grd.store.getSortState();

            params = Ext.apply(params, {
              sort: sort.field,
              dir:  sort.direction
            });
          }

          var url = "/inquiry?" + Ext.urlEncode(params);

          window.open(url, "_blank")
        }
      }
    });

    self.exportCsv.on({
      click: function() {
        if(self.frm.isValid()){
          var params = Ext.apply(self.frm.serializeObject({ onlyDirty: false}), { model: "#{base_model}", export_csv: true });

          if(self.grd.store.getSortState()){
            var sort = self.grd.store.getSortState();

            params = Ext.apply(params, {
              sort: sort.field,
              dir:  sort.direction
            });
          }

          var url = "/inquiry?" + Ext.urlEncode(params);

          window.open(url, "_blank")
        }
      }
    });

    self.exportPdf.on({
      click: function() {
        if(self.frm.isValid()){
          var params = Ext.apply(self.frm.serializeObject({ onlyDirty: false}), { model: "#{base_model}", export_pdf: true });

          if(self.grd.store.getSortState()){
            var sort = self.grd.store.getSortState();

            params = Ext.apply(params, {
              sort: sort.field,
              dir:  sort.direction
            });
          }

          var url = "/inquiry?" + Ext.urlEncode(params);

          window.open(url, "_blank")
        }
      }
    });

    self.grd.on({
      datachanged: function  () {
          var st = self.grd.getStore();
          try {

            if(st && st.reader.jsonData.grand_summary){
              var summary = st.reader.jsonData.grand_summary;
              self.grandSummary.fillData(summary);
            }

            if(st && st.reader.jsonData.page_summary){
              var summary = st.reader.jsonData.page_summary;
              self.pageSummary.fillData(summary);
            }

          } catch(e){
            console.log("summary stuff " + e);
          }
      }
    });

    }
  end
  #################################################

  # REPORT
  eve_report = ""
  if engine[:mode] == "report"
    eve_inqury = %Q{
    self.search.on({
        click: function() {
          var f = $("iframe")
          if(f){
            var url = f.attr("src");
            var ff = f[0];
            var fragments = url.split("?");
            var host = fragments[0];
            var params = fragments[1];
            params = Ext.urlDecode(params);

            // reset params
            for(var k in params){
              console.log("key", k)
              if(k != "cmd" && k != "code"){
                delete params[k];
              }
            }
            var filter = self.frm.serializeObject();

            var src = host + "?" + Ext.urlEncode(Ext.apply(params, filter));
            ff.contentWindow.location = src;
          } else{
            Ext.Notify.error("Cannot Render");
          }
        }
    });
    }
  end

  #################################################

  unless engine[:with_requirejs]
    event_class_content = %Q{ 
    var #{js_class} = Ext.extend(#{js_class}UI,{
  constructor: function  (config) {
    config = config || {};
    Ext.apply(this, config);
    #{js_class}.superclass.constructor.call(this)
  },

  initComponent: function(){
    #{js_class}.superclass.initComponent.call(this);
    var self = x = this;
    // use x for debugging at console
    #{eve_report}
    #{eve_inqury}
  }
});
    }.strip
  else
    file_output_name = options[:file_output_name]
    event_class_content = %Q{ 
define(["./#{file_output_name}.ui"], function(#{js_class}UI){
  var #{js_class} = Ext.extend(#{js_class}UI,{
    constructor: function  (config) {
      config = config || {};
      Ext.apply(this, config);
    #{js_class}.superclass.constructor.call(this)
    },

    initComponent: function(){
    #{js_class}.superclass.initComponent.call(this);
      var self = x = this;
      // use x for debugging at console
    #{eve_report}
    #{eve_inqury}
    }
  });

  return #{js_class};
});
    }.strip
  end # end engine.with_requirejs

  # replace js code
  if ui_class_content.match(/<js>(.*)<\/js>/im)
    buf = []
    ui_class_content.each_line do |line|
      jscode = line.match(/<js>(.*)<\/js>/im)
      unless jscode.nil?
        line.gsub!(/\"[^:]*<js>(.*)<\/js>.*\"/im,'\1') 
        line.gsub!(/\\n/,"")
        line.gsub!(/\\\"/,'"')
      end
      # TODO
      # buf << JSMin.minify(line)
      buf << line
    end
    ui_class_content = buf.join("").strip
  end

  ExtNode.reset_generator_config

  return {ui_class_content: ui_class_content,
          event_class_content: event_class_content}
end
