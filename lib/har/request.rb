module HAR
  class Request < SchemaType
    def initialize(input)
      super(input)
    end

    def domain
      URI.parse(URI.encode(url)).host
    end
  end
end
