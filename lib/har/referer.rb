require "addressable/uri"

module HAR
  class Referer
    attr_reader :har, :url, :host

    def initialize archive, url
      @har  = archive
      @url  = url
      @host = Addressable::URI.parse(URI.encode(url)).host
    end

    # def refered_by
      
    # end

    def parent
      @parent ||= entry_collection.parent_for(url) || NullParent.new(url, children)
    end

    def children
      @entries ||= entry_collection.collection_for(url)
    end

    def started_at
      @started_at ||= children.started_at #parent.started_date_time
    end

    def ended_at
      @ended_at ||= children.ended_at
    end

    def async_time
      @async_time ||= ((ended_at - started_at) * 1000).to_i # convert to ms
    end

    def total_time
      @total_time ||= parent.time + children.total_time
    end
    alias_method :sync_time, :total_time

    def blocked_time
      parent.timings.blocked + children.blocked_time
    end

    def dns_time
      parent.timings.dns + children.dns_time
    end

    def connect_time
      parent.timings.connect + children.connect_time
    end

    def send_time
      children.send_time + parent.send_time
    end

    def wait_time
      parent.timings.wait + children.wait_time
    end

    def receive_time
      parent.timings.receive + children.receive_time
    end

    def to_hash
      {
        id: url,
        url: url,
        domain: parent.request.domain,
        data: children.map(&:to_hash).sort_by { |h| h[:total_time] }.reverse,
        total_time: total_time,
        blocked_time: blocked_time,
        dns_time: dns_time,
        connect_time: connect_time,
        send_time: send_time,
        wait_time: wait_time,
        receive_time: receive_time,
        started_at: started_at,
        ended_at: ended_at
      }      
    end

    private

    def entry_collection
      @entry_collection ||= EntryCollection.new(har)
    end

  end

  class NullParent
    attr_reader :url, :time, :children, :started_date_time, :request, :timings, :send_time
    
    def initialize url, children
      @url      = url
      @children = children
      @time     = 0
      @started_date_time = children.started_at
      @request  = OpenStruct.new(:domain => nil)
      @send_time = 0
      @timings = OpenStruct.new(:blocked => 0, :dns => 0, :connect => 0, :send => 0, :wait => 0, :receive => 0)
    end
  end
end
