module FormField
  def self.included(base)
    base.class_eval do
      alias_method :mod_field, :prepare_config

      define_method :prepare_config do
        mod_field rescue "skip"
        unless @config[:id].nil?
          @config.merge! :submitValue => true
          @config.merge! :name => conv_id_to_name

          if @xtype == 'textfield'
            @config.merge! :emptyText => conv_id_to_label.capitalize
          end

          if base.to_s.match /Checkbox$|Radio$|Radiogroup$/
            @config.merge! :boxLabel => conv_id_to_label.capitalize
          end
          # if base.to_s.match /Combo$/
            # user hidden name for combobox
            #@config.merge! :name => nil #, :hiddenName => conv_id_to_name
          # end
          unless base.to_s.match /Checkbox$|Radio$/
            @config.merge! :fieldLabel => conv_id_to_label.capitalize
          #   label_width = @config[:fieldLabel].size * ExtUtil.FontWidthRatio + 15
          #   @config.merge! :labelWidth => label_width
          end
        end
      end
    end
  end
end
