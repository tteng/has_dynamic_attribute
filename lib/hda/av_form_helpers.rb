module ActionView

  module Helpers

    module FormHelper

      def add_dy_attrs_link link_name, obj, options={}
        default_options = { :container => 'dy_attrs', :partial => 'dy_attrs'}
        options = default_options.merge(options)
        link_to_function link_name do |page|
          page.insert_html :bottom, options[:container], :partial => options[:partial], :locals => {:obj => obj}
        end
      end

      def dynamic_attrs_for obj, &block
        fields_for("dy_attributes[]", obj, &block)
      end

    end

  end

end
