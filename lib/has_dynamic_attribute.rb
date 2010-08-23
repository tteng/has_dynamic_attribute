require 'hda/ar_validators'
require 'hda/av_form_helpers'
require 'hda/ar_accessors'

ActiveRecord::Base.send :include, HdaArAccessor
