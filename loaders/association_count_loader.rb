class AssociationCountLoader < GraphQL::Batch::Loader
  class MissingInverseOf < StandardError; end
  class UnsupportedReflection < StandardError; end

  def initialize(model, association_name)
    super()
    @model = model
    @association_name = association_name
  end

  def perform(records)
    reflection = @model.reflect_on_association(@association_name)
    reflection.check_preloadable!

    klass = reflection.klass
    field = reflection.join_primary_key

    # has_many
    if reflection.instance_of?(ActiveRecord::Reflection::HasManyReflection)
      counts = klass.where(field => records).group(field).count
    # has_and_belongs_to_many, has_many :through
    elsif reflection.instance_of?(ActiveRecord::Reflection::HasAndBelongsToManyReflection) || reflection.instance_of?(ActiveRecord::Reflection::ThroughReflection)
      if reflection.inverse_of.nil?
        raise MissingInverseOf, "`#{@model}` does not have inverse of `#{@model}##{reflection.name}`."
      end

      primary_key = reflection.inverse_of.association_primary_key.to_sym
      counts = klass.joins(reflection.inverse_of.name).where(reflection.inverse_of.name => { primary_key => records.map(&primary_key) }).group(reflection.inverse_of.foreign_key).count
    else
      raise UnsupportedReflection, "`#{reflection.class}` is not supported by AssociationCountLoader"
    end

    records.each do |record|
      record_key = record[reflection.active_record_primary_key]
      fulfill(record, counts[record_key] || 0)
    end
  end
end
