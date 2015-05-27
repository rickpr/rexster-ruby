# Rexster client for Ruby

First require this module:

``` ruby
require './client.rb'
```

Then include it in your project:

```
include Rexster
```

To configure the url, do this:

``` ruby
Rexster.configure do |config|
  config.url = 'http://localhost:8182'
end
```

Next, begin using it:

``` ruby
# Start the client
client = Client.new
# Get all the graphs
graphs = client.graphs
# Choose a graph
my_graph = graph.first
# Get all the vertices
vertices = mygraph.vertices
# Choose a vertex
my_vertex = vertices.first
# Get edges
my_edges = my_vertex.edges
```
