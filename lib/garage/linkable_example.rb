class Garage::LinkableExample
  def initialize(example, controller)
    @example = example
    @controller = controller
  end

  def url
    if @example.is_a? String
      @example
    else
      rendered = Garage::AppResponder.new(@controller, [@example]).
        encode_to_hash(@example, selector: Garage::NestedFieldQuery::DefaultSelector.new)
      rendered['_links']['self']['href']
    end
  end
end
