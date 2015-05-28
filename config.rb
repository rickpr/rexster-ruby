require 'uri'
module Rexster

  class Configuration
    attr_reader :url, :graph

    def url=(url)
      new_url = URI(url)
      new_url.path = '/graphs/' if new_url.path.empty?
      @url   = new_url
    end

    def init_graph(graph = Client.new.graphs.first)
      @graph = graph
    end

  end

  class << self

    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

  end

end
