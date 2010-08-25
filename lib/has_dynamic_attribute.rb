require 'rubygems'
require 'hda/ar_accessors'
require 'hda/av_form_helpers'

ActiveRecord::Base.send :include, HdaArAccessor
