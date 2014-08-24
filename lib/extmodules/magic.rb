module Magic
  module Column
    def self.included(base)
      base.class_eval do
        define_method :id_to_title do 
          return if @config[:id].nil? 
          @config[:id].split("-").map(&:capitalize) * " "
        end

        alias_method :mod_column, :prepare_config

        define_method :prepare_config do
          mod_column rescue "skip"
          @default_config.merge! :header => id_to_title, :dataIndex => conv_id_to_name unless @config[:id].nil?
          @default_config.merge! :sortable => true
          @default_config.merge! :width => 'auto'
        end
      
      end
    end
  end

  module Title
    def self.included(base)
      base.class_eval do
        define_method :id_to_title do 
          return if @config[:id].nil? 
          @config[:id].split("-").map(&:capitalize) * " "
        end

        alias_method :mod_title, :prepare_config

        define_method :prepare_config do
          mod_title rescue "skip"
          @default_config.merge! :title => id_to_title unless @config[:id].nil?
        end

      end
    end
  end

  module Store
    def self.included(base)
      base.class_eval do

        define_method :cls_to_store do 
          return if @config[:cls].nil? 
          first_cls = @config[:cls].split(" ").first.to_storeid
        end

        alias_method :mod_store, :prepare_config

        define_method :prepare_config do
          mod_store rescue "skip"
          @default_config.merge! :store => cls_to_store unless @config[:cls].nil?
        end

      end
    end
  end

  module Text
    def self.included(base)
      base.class_eval do

        alias_method :mod_text, :prepare_config

        define_method :prepare_config do
          mod_text rescue "skip"
          @default_config.merge! :text => conv_id_to_label.capitalize unless @config[:id].nil?
        end

      end
    end
  end

  module InputValue
    def self.included(base)
      base.class_eval do

        alias_method :mod_input_value, :prepare_config

        define_method :prepare_config do
          mod_input_value rescue "skip"
          @default_config.merge! :inputValue => conv_id_to_name unless @config[:id].nil?
        end

      end
    end
  end

  module EmptyText
    def self.included(base)
      base.class_eval do

        alias_method :mod_empty_text, :prepare_config

        define_method :prepare_config do
          mod_empty_text rescue "skip"
          text = @config[:fieldLabel] || @default_config[:fieldLabel]
          @default_config.merge! :emptyText => "Select #{text}" unless text.nil?
        end

      end
    end
  end

  module Listener
    def self.included(base)
      base.class_eval do

        alias_method :mod_listener, :prepare_config

        define_method :prepare_config do
          mod_listener rescue "skip"
          call = @config[:call]
          if call.is_a? Array
            if call.first.is_a? Array 
              call.each do |c|
                call_on = call[0]
                call_fn = call[1]
              end
            else
              call_on = call[0]
              call_fn = call[1]
            end
          else
            call = []
            { 
              :call_on => @default_config[:call_on],
              :call_fn => @config[:call]
            }
            call << [@default_config[:call_on], @config[:call]]
          end

          @default_config.merge! :emptyText => "Select #{text}" unless text.nil?
        end

      end
    end
  end

  module IconClass
    # depend icon framework
    def self.included(base)
      base.class_eval do

        alias_method :mod_icon_class, :prepare_config

        define_method :prepare_config do
          mod_icon_class rescue "skip"
          unless @default_config[:text].nil?
            t = @default_config[:text] 
            if t =~ /add|create|new/i
              icon_cls = "icon-add"
            elsif t =~ /update|edit/i
              icon_cls = "icon-application_form_edit"
            elsif t =~ /delete/i
              icon_cls = "icon-bullet_cross"
            elsif t =~ /search/i
              icon_cls = "icon-magnifier" 
            elsif t =~ /save/i
              icon_cls = "icon-table_save" 
            elsif t =~ /select/i
              icon_cls = "icon-bullet_tick" 
            end 
          end
          @default_config.merge! :iconCls => icon_cls unless icon_cls.nil?
        end
      end
    end

  end

  module Toolbar
    def self.included(base)
      base.class_eval do

        before_to_extjs :arrage_toolbar

        define_method :arrage_toolbar do |at_deep|
          if @childs.last.xtype == "toolbar"
            @config.merge! :fbar => @childs.last.to_extjs(at_deep + 1)
            @childs.pop
          end

          if @childs.first.xtype == "toolbar"
            @config.merge! :tbar => @childs.first.to_extjs(at_deep + 1)
            @childs.slice!(0)
          end 
        end
      end
    end

  end

end
