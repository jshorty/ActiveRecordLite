require_relative 'associatable'

module Associatable

  def has_one_through(name, through_name, source_name)

    through_options = self.assoc_options[through_name]

    define_method(name) do

      through_model = through_options.model_class
      #f_key1 = self.send(through_options.foreign_key)
      #intermediate = through_model.where(id: f_key1).first

      source_options = through_model.assoc_options[source_name]
      source_model = source_options.model_class
      #f_key2 = intermediate.send(source_options.foreign_key)
      #source = source_model.where(id: f_key2).first

      source_table = source_model.table_name
      through_table = through_model.table_name
      initial_table = self.class.table_name

      source = source_options.model_class.parse_all(
      DBConnection.execute(<<-SQL, )
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
          JOIN
          #{through_table}
            ON
            #{through_table}.#{source_options.foreign_key} =
            #{source_table}.#{source_options.primary_key}
          JOIN
          #{initial_table}
            ON
            #{initial_table}.#{through_options.foreign_key} =
            #{through_table}.#{through_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} =
          #{self.id}
      SQL
      ).first
    end
  end
end
