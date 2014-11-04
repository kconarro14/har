module HAR
  class EntryCollection
    include Enumerable

    attr_reader :har, :entries

    def initialize archive, entries=[]
      @har     = archive
      @entries = entries.any? ? entries : har.entries
    end

    def each &block
      @entries.each(&block)
    end

    def referer_urls
      @referer_urls ||= map(&:referer_url).compact.uniq
    end

    def referers
      @referers ||= referer_urls.map { |url| Referer.new(har, url) }
    end

    def started_at
      @started_at ||= map(&:started_date_time).sort.first
    end

    def ended_at
      @ended_at ||= map(&:started_date_time).sort.last
    end

    def async_time
      @async_time ||= ((ended_at - started_at) * 1000).to_i # convert to ms
    end

    def total_time
      @total_time ||= map(&:time).reduce(:+)
    end
    alias_method :sync_time, :total_time

    def dns_time
      map(&:timings).map(&:dns).select {|t| t > -1 }.reduce(:+).to_i
    end

    def connect_time
      map(&:timings).map(&:connect).select {|t| t > -1 }.reduce(:+).to_i
    end

    def send_time
      map {|e| e.timings.send }.select {|t| t > -1 }.reduce(:+).to_i
    end

    def blocked_time
      map(&:timings).map(&:blocked).select {|t| t > -1 }.reduce(:+).to_i
    end

    def receive_time
      map(&:timings).map(&:receive).select {|t| t > -1 }.reduce(:+).to_i
    end

    def wait_time
      map(&:timings).map(&:wait).select {|t| t > -1 }.reduce(:+).to_i
    end

    def to_hash
      map(&:to_hash)
    end

    def entries_for referer
      select { |entry| entry.referer_url == referer }
    end

    def collection_for referer
      self.class.new(har, entries_for(referer))
    end

    def parent_for referer
      find { |entry| entry.request.url == referer }
    end

  end
end
