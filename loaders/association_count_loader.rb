class AssociationCountLoader < GraphQL::Batch::Loader
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
    counts = klass.where(field => records).group(field).count

    records.each do |record|
      record_key = record[reflection.active_record_primary_key]
      fulfill(record, counts[record_key] || 0)
    end
  end
end
