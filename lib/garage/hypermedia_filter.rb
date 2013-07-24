module Garage
  class HypermediaFilter
    MIME_DICT = %r[application/vnd\.cookpad\.dictionary\+(json|x-msgpack)]

    def self.filter(controller)
      helper = new(controller)
      controller.representation = helper.dictionary_representation if helper.has_dictionary_mime_type?
      controller.request.format = helper.dictionary_request_format if helper.has_dictionary_mime_type?
      controller.field_selector = helper.field_selector
    rescue Garage::NestedFieldQuery::InvalidQuery
      raise HTTPStatus::BadRequest, "Invalid query in ?fields="
    end

    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def field_selector
      Garage::NestedFieldQuery::Selector.build(fields_param)
    end

    def fields_param
      controller.params[:fields]
    end

    def dictionary_representation
      :dictionary
    end

    def dictionary_request_format
      dictionary_match_data[1].sub(/^x-/, "").to_sym
    end

    def has_dictionary_mime_type?
      dictionary_match_data
    end

    def dictionary_match_data
      @dictionary_match_data ||= controller.request.format.to_s.match(MIME_DICT)
    end
  end
end
