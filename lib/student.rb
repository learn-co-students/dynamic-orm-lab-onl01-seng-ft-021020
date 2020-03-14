require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

self.column_names.each do |col_names|
  attr_accessor col_names.to_sym
end 

end
