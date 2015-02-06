require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id
    }.merge!(options)

    self.class_name = defaults[:class_name]
    self.foreign_key = defaults[:foreign_key]
    self.primary_key = defaults[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id
    }.merge!(options)

    self.class_name = defaults[:class_name]
    self.foreign_key = defaults[:foreign_key]
    self.primary_key = defaults[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(options.class_name.underscore) do
      model = options.model_class
      f_key = self.send(options.foreign_key)
      model.where(id: f_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(options.table_name) do
      model = options.model_class
      model.where(options.foreign_key => self.id)
    end
  end

  def assoc_options
    @options ||= {}
  end
end

class SQLObject
  extend Associatable
end
