use List;
use Map;

class Graph {
  // store all nodes so that they can be freed when the graph is freed
  var allNodes: list(owned Node);
}

class Node {
  var value: string;

  var edges: list(borrowed Node); 
  var labels: list(string);
}

proc Graph.addNode(val: string) : borrowed Node {
  allNodes.append(new Node(value=val));
  return allNodes.last();
  // It seems that it is a bit tricky that I can't return a 'borrow'
  // to the local variable; this is what I would do in an 'unmanaged' design.
  // But returning a borrow from the "real" value in the list seems OK.
}

proc Graph.addEdge(from: borrowed Node, to: borrowed Node, val: string) {
  from.edges.append(to);
  from.labels.append(val);

  // error message: I had 
  //  from.edges.append(val);
  // which is an error, but it showed errors inside of List
}

proc Graph.dump() {
  // create a map from unmanaged Node to integer ID
  var ptrToId: map(borrowed Node, int);

  writeln("NODES");
  var i = 0;
  for node in allNodes {
    writeln(i, " : ", node.value);
    ptrToId[node:borrowed] = i;
    i += 1;
  }
  writeln();
  writeln("EDGES");
  for node in allNodes {
    var fromId = ptrToId[node];
    for (otherNode, lbl) in zip(node.edges, node.labels) {
      var toId = ptrToId[otherNode];
      writeln(" ", fromId, " -> ", toId, " ", lbl);
    }
    i += 1;
  }
  writeln();
}

proc main() {
  var graph = new Graph();
  var nodeId1 = graph.addNode("n1");
  var nodeId2 = graph.addNode("n2");
  graph.addEdge(nodeId1, nodeId2, "e1");
  graph.addEdge(nodeId2, nodeId1, "e2");

  graph.dump();
}
