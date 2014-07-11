# require "active_support/all"
class	ExtNode
  include Enumerable

	attr_accessor :xtype, :config, :parent, :childs, :default_config, :deep_lvl

  # def self.inherited(klass)
  #   klass.class_attribute :before_filters
  #   klass.before_filters = []
  # end

	def initialize(xtype, config = {}, parent = nil)
		@xtype = xtype
    @config ||= {} # init config first for future use
    @config.merge! :autoDestroy => true
    # TODO able to alias config key
    override_config config
    # Hook
    do_alias_config
    prepare_config rescue "next"
		apply_config @default_config unless @default_config.nil?
		@parent = parent
		@childs = []
	end
  
  def do_alias_config
    if self.class.class_variable_defined? :@@ALIAS_CONFIG
      # replace alias with actual config attributes
      ac = self.class.class_variable_get :@@ALIAS_CONFIG
      nc = {}
      @config.each do |k, v|
        if ac.keys.include? k
          nc[ac[k]] = @config[k] 
          @config.delete k
        end
      end
      @config.merge! nc
    end
  end

  def conv_id_to_ref
    return nil unless @config[:id]
    sid = @config[:id].split("-")
    temp = sid[1..-1]
    fword = sid[0];
    temp.each do |el|
     fword += (el[0].upcase + el[1..-1])
    end
    
    fword
  end

  def conv_id_to_label
    @config[:id].split("-").map(&:capitalize) * " "
  end

  def conv_id_to_name
    @config[:id].nil? ? "" : @config[:id].split("-") * "_"
  end

	def add_child(node)
    return if node.nil?
    if node.is_a? Array
      @childs += node
      node.each do |n|
        n.set_parent self  
      end
    else
      @childs << node
      node.set_parent self
    end
	end

	def set_parent(node)
		@parent = node	
	end

	def root?
		@parent.nil?
	end
	
	def do_layout
		raise "Not Implemented"	
	end

  def get_all_siblings
    parent.childs rescue [] 
  end

	def prepare_config(h)
    @default_config.merge! @@magic_config
	end

  def find_parent(*xtype)
    return nil if parent.nil? 
    if xtype.include? parent.xtype
      parent
    else 
      parent.find_parent(*xtype)
    end
  end

  def is_field_element?
    ExtUtil.field_xtype.include? self.xtype
  end

  def find_field_elements
    element = []
    if self.childs.count > 0
      childs.each do |c|
        if c.is_field_element?
          element << c
        else
          element += c.find_field_elements
        end
      end
    end

    element
  end

  def find(xtype, option = nil)
    return false unless has_child?
    if(!option.nil? and option[:recursive])
      return false if option[:recursive] == 0
      option[:recursive] -= 1
    end
    found = false
    childs.each do |c|
      if c.xtype == xtype
        unless option.nil?
          match_option = true
          option.each do |k, v|
            next if k == :recursive
            match_option = false if option[k] != c.config[k] 
          end
          if match_option
            found = c 
            break
          end
        else
          found = c 
          break
        end
      end
      found = c.find xtype, option
      break if found
    end
    found 
  end

  def remove_childs(xtype, options = {:recursive => 1})
    return false unless has_child?
    opt = options
    if opt[:recursive]
      opt[:recursive] -= 1
    end
    new_childs = []
    childs.each do |c|
      c.remove_childs xtype if opt[:recursive] > 0
      unless c.xtype == xtype 
        new_childs << c
      end
    end
    self.childs = new_childs
  end

  def child_of?(*xxtype)
    if parent.nil?
      false
    elsif xxtype.include?(parent.xtype)
      true
    else
      parent.child_of?(*xxtype)
    end
  end

  def child_of_form?
    if parent.nil?
      false
    elsif parent.xtype == "form"
      true
    else
      parent.child_of_form?
    end
  end

  def apply_config(h)
    if not @config[:cls].nil? and not h[:cls].nil?
      @config[:cls] += " #{h[:cls]}"
    end
    @config = h.merge @config 
  end

  def remove_config(key)
    @config.delete key
  end

  def override_config(h)
    if not @config[:cls].nil? and not h[:cls].nil?
      @config[:cls] += " #{h[:cls]}"
      delete h[:cls]
    end
    @config.merge! h 
  end

  def has_child?
   childs.count > 0 
  end

  def to_extjs(at_deep = 0)
    # if self.before_filters.count > 0
    #   self.before_filters.each do |method|
    #     self.send method, at_deep
    #   end
    # end

    ref = conv_id_to_ref
    # if not root? and ref
      # TODO skip if id is the same of instance method
      # puts "../"*(at_deep == 0 ? 0 : at_deep-1 ) + conv_id_to_ref unless @config[:id].nil?
      # @config = @config.merge({ :ref => "../"*(at_deep-1) + conv_id_to_ref }) unless @config[:id].nil?
    # end

    # not gen id
    @config[:cmp_id] = conv_id_to_ref
    unless @@generator[:noid].nil? 
      # skip if force gen id
      unless @config[:forceId]
        # remove id
        @config.delete :id
        # @config[:id] = ExtUtil.random_id
      end
      # gen random id for ref
    end

    collect_events
    # TODO remove ref for *column xtype ?
    collect_ref(ref)

    if has_child?
      child_h = { :items => [] }
      childs.each do |c|
        child_h[:items] << c.to_extjs(at_deep + 1) 
      end
      h = {:xtype => @xtype}.merge(@config).merge(child_h)
    else
      {:xtype => @xtype}.merge(@config)
    end
  end

  @@refs = {}
  def collect_ref(ref)
    return false if not ref or @config[:id].nil?
    @@refs[@config[:id].dup] = ref.dup
  end

  @@events_store = {}
  def collect_events
    del_keys = []
    @config.each do |k, v|
      if k =~ /^on-/i
        del_keys << k
        # v is fn_name
        ev = /^on-(.*)/.match(k)[1]
        @@events_store[conv_id_to_ref.to_sym] = [ev, v]
        # p conv_id_to_ref, ev, v
      end
    end  

    del_keys.each do |k|
      @config.delete k
    end
  end

  def self.get_events
    @@events_store 
  end

  def self.get_refs
    @@refs 
  end

  def build_abstract_function
    # unless root?
    #   @config = @config.merge({ :ref => "../"*(at_deep-1) + conv_id_to_ref }) unless @config[:id].nil?
    # end

    code = [] 
      p @xtype, @config
    if has_child?
      childs.each do |c|
        code += c.build_abstract_function
      end
    else
      return code if @config[:call].nil?
      code << "this.#{conv_id_to_ref}.on('#{@config[:call_on]}', this.#{@config[:call_fn]}, this)"
    end

    code
  end

  def get_deep()
    deep = 0
    node = self
    while true
      unless node.root? 
        node = node.parent
        deep += 1
      else 
        break
      end
    end
    deep
  end

  #def to_s
  #  o = self.dup
  #  n = get_deep
  #  o.parent = nil
  #  o.config[:items] = nil
  #  %Q{
  #    #{"  "*n}#{o.xtype}(#{o.config}) 
  #      #{"  "*n}>#{o.childs}"}  
  #end

  @@generator = {}
  def self.set_generator_config(option)
    @@generator.merge! option 
  end

  def self.reset_generator_config
    @@generator = {}
  end

  def self.before_to_extjs(method)
    # @before_filters ||= []
    before_filters << method
    # p method, name, @@before_filters, self 
  end

  def self.get_before_filters
    before_filters
    # @@before_filters 
  end
	
end
