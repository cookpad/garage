module Garage
  module PaginatingResponder
    def display(resource, *args)
      if @options[:paginate]
        resource = paginate resource
      end
      super(resource, *args)
    end

    def max_per_page=(count)
      @max_per_page = count
    end

    def reveal_total!
      @options.delete(:hard_limit)
    end

    private

    def distinct?
      !!@options[:distinct_by]
    end

    def hide_total?
      !!@options[:hard_limit]
    end

    def hard_limit
      @options[:hard_limit]
    end

    def max_per_page
      @options[:max_per_page] || @max_per_page || 100
    end

    def set_total_count(rs, per_page)
      if hard_limit
        limit = hard_limit
        rs.instance_variable_set(:@total_count, limit)
      elsif @options[:cacheable_with]
        delegate = CacheableListDelegate.new(rs, @options[:cacheable_with])
        total = Rails.cache.fetch(delegate.cache_key_count) { total_count(rs) }
        rs.instance_variable_set(:@total_count, total) # OMG
      end
    end

    def total_count(rs)
      if distinct?
        rs.total_count(@options[:distinct_by], distinct: true)
      else
        rs.total_count
      end
    end

    def paginate(rs)
      @options[:hard_limit] ||= 1000 if @options[:hide_total] # backward compat for hide_total

      per_page = [ max_per_page, (controller.params[:per_page] || @options[:per_page] || 20).to_i ].min

      rs = rs.page(controller.params[:page] || 1).per(per_page)

      set_total_count(rs, per_page)

      unless hide_total?
        controller.response.headers['X-List-TotalCount'] = total_count(rs).to_s
      end

      # construct_links must be called after calling rs.total_count to avoid invalid count cache
      construct_links(rs, per_page)

      if hide_total?
        if rs.offset_value > hard_limit
          rs = []
        elsif rs.offset_value + per_page > hard_limit
          rs = rs.slice 0, (hard_limit - rs.offset_value) # becomes Array here, and hope it's ok
        end
      end

      rs
    end

    def construct_links(rs, per_page)
      build_link_hash(rs, links={})
      add_link_header(links, per_page) unless links.empty?
    end

    def build_link_hash(rs, links)
      unless rs.first_page?
        links[:first] = 1
        links[:prev]  = rs.current_page - 1
      end

      if rs.current_page < rs.total_pages
        links[:next] = rs.current_page + 1
      end

      unless rs.last_page? || hide_total?
        links[:last] = rs.total_pages
      end
    end

    def build_path_for(params)
      parameters = controller.request.query_parameters.merge(params).tap {|p| p.delete(:access_token) }
      "#{controller.request.path}?#{parameters.to_query}"
    end

    def add_link_header(links, per_page)
      headers = []
      links.each do |rel, page|
        url = build_path_for(:page => page, :per_page => per_page)
        headers << "<#{url}>; rel=\"#{rel}\""
      end
      controller.response.headers['Link'] = headers.join ', '
    end
  end
end

