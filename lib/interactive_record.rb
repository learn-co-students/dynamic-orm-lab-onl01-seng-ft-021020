require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("PRAGMA table_info(#{self.table_name})").map { |column| column["name"] }
  end

  def initialize(attributes={})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.select{ |name| name != 'id' }.compact.join(", ")
  end

  def values_for_insert
    self.class.column_names.map{ |name| "'#{self.send(name)}'" unless send(name).nil? }.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) 
      VALUES (#{self.values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute)
    value = attribute.values[0].to_i == 0 ? "'#{attribute.values[0]}'" : attribute.values[0].to_i
    key = attribute.keys[0].to_s
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = #{value}")
  end

end