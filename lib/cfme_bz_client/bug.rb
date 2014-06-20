class CfmeBzClient
  class Bug

    attr_accessor :attributes
    attr_accessor :id

    def initialize(attribute_set)
      @id         = attribute_set.delete("bug_id")
      @attributes = attribute_set
    end
  end
end