module FormField
  def self.included(base)
    base.class_eval do
      alias_method :mod_field, :prepare_config

      define_method :prepare_config do
        mod_field rescue "skip"
        unless @config[:id].nil?
          @default_config.merge! :submitValue => true
          @default_config.merge! :name => conv_id_to_name

          if @xtype == 'textfield'
            @default_config.merge! :emptyText => conv_id_to_label.capitalize
          end

          if base.to_s.match /Checkbox$|Radio$|Radiogroup$/
            @default_config.merge! :boxLabel => conv_id_to_label.capitalize
          end
          # if base.to_s.match /Combo$/
            # user hidden name for combobox
            #@default_config.merge! :name => nil #, :hiddenName => conv_id_to_name
          # end
          unless base.to_s.match /Checkbox$|Radio$/
            @default_config.merge! :fieldLabel => conv_id_to_label.capitalize
          #   label_width = @default_config[:fieldLabel].size * ExtUtil.FontWidthRatio + 15
          #   @default_config.merge! :labelWidth => label_width
          end
        end
      end
    end
  end
end
