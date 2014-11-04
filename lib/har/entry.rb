module HAR
  class Entry < SchemaType
    attr_reader :har
    
    def initialize(input, archive=nil)
      super(input)
      @har = archive
    end

    def referer_url
      @referer_url ||= request.headers.select { |h| h['name'] == 'Referer' }.map { |h| h['value'] }.first
    end

    def referer
      Referer.new(har, referer_url) if referer_url
    end

    def send_time
      timings.instance_variable_get(:@send).to_i
    end

    def to_hash
      {
        id: "#{request.url}-#{started_date_time}",
        url: request.url,
        domain: request.domain,
        total_time: time,
        blocked_time: timings.blocked,
        dns_time: timings.dns,
        connect_time: timings.connect,
        send_time: send_time,
        wait_time: timings.wait,
        receive_time: timings.receive,
        started_at: started_date_time,
        ended_at: started_date_time + time
      }
    end

  end
end
