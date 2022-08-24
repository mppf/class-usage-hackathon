use List;
use Map;

class Graph {
  // store all nodes so that they can be freed when the graph is freed
  var n: int;
  var allNodesDom = {1..0};
  // error message: cannot default initialize...
  // but I want to initialize it with no elements.
  // error message: type in new expression is missing its argument list
  //var allNodes: [allNodesDom] owned Node = [i in allNodesDom] new Node();
  var allNodes: [allNodesDom] owned Node;
  proc init() {
    this.n = 0;
    this.allNodesDom = {1..0};
    this.allNodes = for i in allNodesDom do new Node("");
  }
}

class Node {
  var value: string;

  var n: int;
  var edgesDom = {1..0};
  var edges: [edgesDom] borrowed Node;
  var labels: [edgesDom] string;
  // error message: I can't figure out how to initialize 'edges'
  // here since I don't have any Nodes to point to
  proc init(value: string) {
    // error message: Could not coerce 'nil' to 'Node?' in initialization
    //var dummyNode: Node? = nil;
    // error message: Scoped variable aa would outlive the value it is set to
    //var dummyNode: borrowed Node? = nil;
    var dummyNode: unmanaged Node? = nil;
    this.value = value;
    this.n = 0;
    this.edgesDom = {1..0};
    this.edges = for i in edgesDom do dummyNode!;
    this.labels = for i in edgesDom do "";
  }
}

proc Graph.addNode(val: string) : borrowed Node {
  n += 1;
  manage allNodesDom.unsafeAssign({1..n}, checks=true) as mgr {
    mgr.initialize(allNodes, n, new Node(value=val));
  }
  return allNodes[n];
  // It seems that it is a bit tricky that I can't return a 'borrow'
  // to the local variable; this is what I would do in an 'unmanaged' design.
  // But returning a borrow from the "real" value in the list seems OK.
}

proc Graph.addEdge(from: borrowed Node, to: borrowed Node, val: string) {
  from.n += 1;
  var n = from.n;
  manage from.edgesDom.unsafeAssign({1..n}, checks=true) as mgr {
    mgr.initialize(from.edges, n, to); 
    // error: Cannot call 'initialize' on array with default-initializable element type 'string'
    //mgr.initialize(from.labels, n, val); 
  }
  from.labels[n] = val;
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
