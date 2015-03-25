require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    cols = DBConnection.execute2(<<-SQL)
             SELECT
               *
             FROM
               #{self.table_name}
           SQL
    cols.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |sym|

      define_method("#{sym}") do
        attributes[sym]
      end

      define_method("#{sym}=") do |arg|
        attributes[sym] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    attrs = DBConnection.execute(<<-SQL)
              SELECT
                #{table_name}.*
              FROM
                #{table_name}
            SQL
    parse_all(attrs)
  end

  def self.parse_all(results)
    instances = []

    results.each do |attrs|
      instances << self.new(attrs)
    end

    instances
  end

  def self.find(id)
    attrs = DBConnection.execute(<<-SQL, id)
              SELECT
                #{self.table_name}.*
              FROM
                #{self.table_name}
              WHERE
                #{self.table_name}.id = ?
            SQL
    parse_all(attrs).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym

      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr_name| self.send(attr_name) }
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    assignments = self.class.columns.map { |attr_name| "#{attr_name} = ?" }
    assignments = assignments.join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{assignments}
      WHERE
        #{self.id} = id
    SQL
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
  end
end
