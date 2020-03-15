require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "pragma table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        
        column_names = []
        table_info.each do |row|
            column_names << row["name"]
        end
        column_names.compact
    end

    def initialize(options={})
      options.each do |property, value|
        self.send("#{property}=", value)
      end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col|
            values << "'#{send(col)}'" unless send(col).nil?
        end
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
        attributes = DB[:conn].execute("SELECT * FROM #{table_name_for_insert} WHERE id = #{@id}")
        attributes.first.delete_if{|key, value| key.class == Integer}
        attributes
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        attributes = DB[:conn].execute(sql, name)
        attributes.first.delete_if{|key, value| key.class == Integer}
        attributes
        #binding.pry
    end

    def self.find_by(hash) 
        hash_key = hash.keys.join()
        hash_value = hash.values.first
        sql = "SELECT * FROM #{self.table_name} WHERE #{hash_key} = '#{hash_value}' LIMIT 1"
        attributes = DB[:conn].execute(sql)
        attributes.first.delete_if{|key, value| key.class == Integer}
        attributes
    end

end