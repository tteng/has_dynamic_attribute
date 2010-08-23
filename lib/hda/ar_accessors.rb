#reader,writer for dynatic attributes 
require 'ostruct'

module HdaArAccessor

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def has_dynamic_attribute attr
      include HdaArAccessor::InstanceMethods
      write_inheritable_attribute :dynamic_attr, attr 
    end

    class_inheritable_reader :dynamic_attr

    after_validation :map_struct_to_json!
   
  end

  module InstanceMehtods

    attr_accessor :dy_attrs

    def method_missing mth, *args
      if mth.to_s =~ /^(.*)=$/  
        return  @dy_attrs.send("#{$1}=", args)
      else
        return @dy_attrs.send($1)
      end
      super
    end

    def find *args
      super 
      map_json_to_struct!
    end

    private

    def map_json_to_struct!
      @dy_attrs = OpenStruct.new(self.send(dynamic_attr))
      self
    end

    def map_struct_to_json!
      self.send "#{dynamic_attr}=", (@dy_attrs.as_json.values.shift.to_json rescue "{}")
    end

  end 
 
end
