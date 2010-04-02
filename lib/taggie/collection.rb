module Taggie
  class Collection < Array

    attr_reader :parent

    def initialize(array, parent)
      super array
      @parent = parent
    end

    [:<<, :clear, :compact!, :delete, :delete_at, :delete_if, :insert, :pop, :push, :reject!, :reverse!, :slice!, :sort!, :uniq!].each do |method|
      define_method(method) do |*args|
        result = super
        parent.rebuild! if parent
        result
      end
    end

  end
end