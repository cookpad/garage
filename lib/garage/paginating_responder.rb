module Garage
  module PaginatingResponder
    def display(resource, *args)
      if @options[:paginate]
        resource = paginate resource, @options
      end
      super(resource, *args)
    end

    # hooks for privileged apps
    def max_per_page=(count)
      @max_per_page = count
    end

    def reveal_total!
      @options[:hide_total] = false
    end

    private

    def hide?
      @options[:hide_total]
    end

    def max_per_page
      @max_per_page || 100
    end

    def set_total_count(rs, base)
      delegate = CacheableListDelegate.new(rs, base)
      total = Rails.cache.fetch(delegate.cache_key_count) { rs.total_count }
      rs.instance_variable_set(:@total_count, total) # OMG
    end

    def paginate(rs, options={})
      per_page = [ options[:max_per_page] || max_per_page, (controller.params[:per_page] || options[:per_page] || 20).to_i ].min

      rs.page(controller.params[:page] || 1).per(per_page).tap do |rs|
        set_total_count(rs, @options[:cacheable_with]) if @options[:cacheable_with]
        construct_links(rs, per_page)

        # Get total count *after* pagination so that `total_count` can be fetched from caches
        unless hide?
          controller.response.headers['X-List-TotalCount'] = rs.total_count.to_s
        end
      end
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

      unless rs.last_page? || hide?
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

