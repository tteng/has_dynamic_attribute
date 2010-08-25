#reader,writer for dynatic attributes 
require 'ostruct'

module HdaArAccessor

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def has_dynamic_attribute attr
      instance_eval <<-EOF
        alias origin_find find
        def find *args
          obj = origin_find(args.shift)
          unless obj.blank?
            case obj
              when Array
                obj.map{|o| o.map_json_text_to_struct!}
              else
                obj.map_json_text_to_struct!
            end
          end
          obj
        end
      EOF
      include HdaArAccessor::InstanceMethods
      write_inheritable_attribute :dynamic_attr, attr 
      class_inheritable_reader :dynamic_attr
      after_validation :map_struct_to_json_text!
    end

  end

  module InstanceMethods

    attr_accessor :dy_attrs

    def method_missing mth, *args
      if mth.to_s =~ /^da_(.*)=$/  
        return  @dy_attrs.send("#{$1}=", args.shift)
      elsif  mth.to_s =~ /^da_(.*)$/ 
        return @dy_attrs.send($1)
      end
      super
    end

    def initialize args={}
      super args.merge(:dy_attrs => OpenStruct.new)
    end

    def map_json_text_to_struct!
      self.dy_attrs = OpenStruct.new(JSON.parse(self.send(dynamic_attr) || "{}")) 
      self
    end

    def dy_attributes= attrs
      if attrs.blank?
        self.dy_attrs = OpenStruct.new({})
      else
        deleted_attrs = dy_attrs_hash.keys - attrs.map{|hsh| hsh[:da_label]}
        deleted_attrs.each do |attr|
          self.send("da_#{attr}=",nil)
        end 
        attrs.each do |hash|
          dy_attr, value = hash[:da_label], hash[:da_value]
          next if (dy_attr.blank? || value.blank?)
          self.send("da_#{dy_attr}=", value)
        end
      end
    end

    def dy_attrs_hash
      @dy_attrs.as_json.values.shift rescue {}
    end

    private

    def map_struct_to_json_text!
      value = dy_attrs_hash
      value.delete_if{|k,v|v.blank?}
      self.send "#{dynamic_attr}=", value.to_json
      self
    end

  end 
 
end
