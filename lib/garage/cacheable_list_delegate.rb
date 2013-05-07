require 'digest/md5'

class Garage::CacheableListDelegate
  def initialize(*args)
    @resource, @delegate = *args
  end

  def cacheable?
    true
  end

  def canonical
    if @resource.respond_to?(:parameters)
      @resource.parameters
    else
      @resource.to_sql
    end
  end

  def cache_key
    [@delegate.cache_key, Digest::MD5.hexdigest(canonical)].join('-')
  end

  def cache_key_count
    count_sql_base = @resource.except(:offset, :limit, :order).to_sql
    [@delegate.cache_key, Digest::MD5.hexdigest(count_sql_base), 'count'].join('-')
  end
end
