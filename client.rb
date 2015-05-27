require './config'
require 'httparty'
require 'active_support/inflector'

module Rexster

  class Client

    include ActiveSupport::Inflector
    include HTTParty
    format :json

    attr_reader :url

    def initialize(url = nil, graph = nil)
      @url      = URI.join(Rexster.configuration.url, url.to_s)
      @response = Client.get(@url)
      @graph    = graph
    end

    def graphs
      Client.get(@url)["graphs"].map { |graph| Graph.new(graph << '/') }
    end

    def destroy
      Client.delete(@url)
    end

    def id
      @response["results"]["_id"]
    end

    private

    def get_items(type, key: nil, value: nil, base_url: @url)
      url = URI.join(@url, type << '/')
      # Only add this in if present
      url.query = "key=#{key}&value=#{value}" if key && value
      results = Client.get(url)["results"]
      # Return an array of objects. If this is not possible, just return URLs.
      results.map do |result|
        klass = Object.const_get(result["_type"].capitalize)
        url_class  = pluralize(result["_type"]) << '/'
        id = result["_id"].to_s << '/'
        graph = @graph
        uri  = URI.join(base_url, url_class, id)
        klass.new(uri, graph) 
      end
    end

    def get_count(type)
      url = URI.join(@url, type << '/')
      Client.get(url)["totalSize"]
    end

    def method_missing(*args)
      @response[args.join] || super
    end

  end

  class Graph < Client

    def initialize(url = nil, graph = self)
      super
    end

    def vertices(key: nil, value: nil)
      get_items('vertices', key: key, value: value)
    end

    def edges(key: nil, value: nil)
      get_items('edges', key: key, value: value)
    end

    def vertex_count
      get_count('vertices')
    end

    def edge_count
      get_count('edges')
    end

    # This inherits destroy method, but cannot be deleted
    def destroy
      warn "Can't delete a graph"
    end

    # This inherits id method, but has no id
    def id
      warn "Graph has no id"
    end

    class << self

      def add_vertex(id: nil, **attrs)
        url = URI.join(@url, 'vertices/', id.to_s)
        url.query = URI::encode_www_form(attrs)
        Vertex.new(Client.post(url))
      end

      def add_edge(id: nil, outV:, inV:, **attrs) 
        url = URI.join(@url, 'edges/', id.to_s)
        attrs.merge!({ _outV: outV, _inV: inV })
        url.query = URI::encode_www_form(attrs)
        Edge.new(Client.post(url))
      end

    end

  end

  class Vertex < Client

    def out_edges
      Client.get(URI.join(@url, 'outE'))
    end

    def edges
      get_items('bothE', base_url: @graph.url)
      #Client.get(URI.join(@url, 'bothE'))
    end

    def in_edges
      Client.get(URI.join(@url, 'inE'))
    end

  end

  class Edge < Client
  end

end
