class Platform2::LinkableExample
  def initialize(example, controller)
    @example = example
    @controller = controller
  end

  def url
    if @example.is_a? String
      @example
    else
      rendered = Platform2::AppResponder.new(@controller, [@example]).
        encode_to_hash(@example, nil, selector: Platform2::NestedFieldQuery::DefaultSelector.new)
      rendered['_links']['self']['href']
    end
  end
end
