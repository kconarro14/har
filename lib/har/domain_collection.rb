module HAR
  class DomainCollection
    attr_reader :har

    def initialize archive
      @har = archive
    end

    def domains
      @domains ||= requests.map(&:domain).uniq
    end

    def merge domain_collection
      domain_collection = domain_collection.domain_stats if domain_collection.is_a?(HAR::DomainCollection)
      common_domains = domain_stats.keys & domain_collection.keys

      [self.domain_stats.values, domain_collection.values].flatten.inject({}) do |memo, el|
        (memo[el[:domain]] ||= {}).merge!(el) do |key, old_value, new_value|
          common_domains.include?(el[:domain]) && key != :domain ? (old_value + new_value) : old_value
        end
        memo
      end
    end

    def group_hashes arr, group_field, sum_fields
      arr.inject({}) do |res, h|
        (res[h[group_field]] ||= {}).merge!(h) do |key, oldval, newval|
          sum_fields.include?(key) ? (oldval.to_f + newval.to_f).to_s : oldval
        end
        res
      end
    end

    def entries_for domain
      domain_entries[domain]
    end

    def stats_for domain
      domain_stats[domain]
    end

    def domain_entries
      @domain_entries ||= domains.inject({}) {|h, d| h[d] = entries.select {|e| e.request.domain == d}; h }
    end

    def domain_stats
      @domain_stats ||= domain_entries.inject({}) do |hash, (domain, entries)|  
        attrs = {:total_time => 0}
          
        self.timing_types.each do |type|
          attrs["#{type}_time".to_sym] = entries.map(&:timings).map(&type).select {|t| t > -1 }.reduce(:+).to_i
          attrs[:total_time] += attrs["#{type}_time".to_sym]
        end
        
        attrs[:error_count]   = entries.map(&:response).count(&:is_error?)
        attrs[:total_size]    = entries.map(&:response).map(&:body_size).reduce(:+)
        attrs[:request_count] = entries.map(&:request).count
        attrs[:average_size]  = attrs[:total_size] / attrs[:request_count]
        attrs[:domain]        = domain

        self.content_types.each do |type|
          attrs["#{type}_count".to_sym] = entries.map(&:response).count(&"is_#{type}?".to_sym)
        end

        hash[domain] = attrs
        hash
      end

    end

    protected

    def entries
      @entries ||= har.entries
    end

    def requests
      @requests ||= entries.map(&:request)  
    end

    def timing_types
      [:dns, :receive, :wait, :connect, :blocked, :send]
    end

    def content_types
      [:image, :html, :javascript, :css, :flash, :other]
    end

  end
end
