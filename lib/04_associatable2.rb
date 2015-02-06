require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    through_options = self.assoc_options[through_name]

    define_method(name) do

      through_model = through_options.model_class
      #debugger
      f_key1 = self.send(through_options.foreign_key)
      intermediate = through_model.where(id: f_key1).first

      source_options =
        through_model.assoc_options[source_name]

      source_model = source_options.model_class
      f_key2 = intermediate.send(source_options.foreign_key)

      source_model.where(id: f_key2).first
    end
  end
end
#
# model = options.model_class
# f_key = self.send(options.foreign_key)
# model.where(id: f_key).first
