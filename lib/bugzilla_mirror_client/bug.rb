class BugzillaMirrorClient
  class Bug
    attr_accessor :attributes
    attr_accessor :blocks
    attr_accessor :clones
    attr_accessor :depends_on
    attr_accessor :fixed_in
    attr_accessor :flags
    attr_accessor :id
    attr_accessor :keywords
    attr_accessor :status
    attr_accessor :summary
    attr_accessor :target_release

    def initialize(attribute_set)
      @blocks         = attribute_set.delete("blocks")
      @clones         = attribute_set.delete("clones")
      @depends_on     = attribute_set.delete("depends_on")
      @fixed_in       = attribute_set.delete("fixed_in")
      @flags          = attribute_set.delete("flags")
      @id             = attribute_set.delete("bug_id")
      @keywords       = attribute_set.delete("keywords")
      @status         = attribute_set.delete("status")
      @summary        = attribute_set.delete("summary")
      @target_release = attribute_set.delete("target_release")

      @attributes = attribute_set
    end

    def ==(other)
      id == other.id
    end
  end
end
