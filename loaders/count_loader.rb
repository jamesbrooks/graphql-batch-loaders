class CountLoader < GraphQL::Batch::Loader
  def initialize(model, field)
    super()
    @model = model
    @field = field
  end

  def perform(ids)
    counts = @model.where(@field => ids).group(@field).count

    counts.each { |id, count| fulfill(id, count) }
    ids.each { |id| fulfill(id, 0) unless fulfilled?(id) }
  end
end
