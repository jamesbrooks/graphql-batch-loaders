class AssociationFindByLoader < GraphQL::Batch::Loader
  def initialize(record, association, field)
    super()
    @record = record
    @association = association
    @field = field
  end

  def perform(values)
    results = @record.public_send(@association).where(@field => values)

    results.each { |result| fulfill(result[@field], result) }
    values.each { |value| fulfill(value, nil) unless fulfilled?(value) }
  end
end
