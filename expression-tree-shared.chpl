use Map;

type environment = map(string, int);

class Exp {
  proc eval(env: environment): int {
    halt("error -- base class eval was called");
  }
  proc dump() { }
}

class IntExp : Exp {
  var value: int;

  override proc eval(env: environment): int {
    return value;
  }
  override proc dump() {
    write("IntExp(", value, ")");
  }
}

class VarExp : Exp {
  var name: string;

  override proc eval(env: environment): int {
    return try! env.getValue(name);
  }
  override proc dump() {
    write("VarExp(", name, ")");
  }
}

class AddExp : Exp {
  var op1: shared Exp;
  var op2: shared Exp;

  override proc eval(env: environment): int {
    return op1.eval(env) + op2.eval(env);
  }
  override proc dump() {
    write("AddExp(");
    op1.dump();
    write(", ");
    op2.dump();
    write(")");
  }
}

class SubExp : Exp {
  var op1: shared Exp;
  var op2: shared Exp;

  override proc eval(env: environment): int {
    return op1.eval(env) - op2.eval(env);
  }
  override proc dump() {
    write("SubExp(");
    op1.dump();
    write(", ");
    op2.dump();
    write(")");
  }
}

class MultExp : Exp {
  var op1: shared Exp;
  var op2: shared Exp;

  override proc eval(env: environment): int {
    return op1.eval(env) * op2.eval(env);
  }
  override proc dump() {
    write("MultExp(");
    op1.dump();
    write(", ");
    op2.dump();
    write(")");
  }
}

// at first, I forgot 'borrow' here, which led to the error
// "cannot pass result of coercion by reference"
proc process(env: environment, tree: borrowed Exp) {
  write("Evaluating: ");
  tree.dump();
  writeln();

  var result = tree.eval(env);
  writeln("Result: ", result);
}

proc main() {
  var env: environment;
  env["x"] = 3;

  var tree = new shared MultExp(new shared VarExp("x"), new shared IntExp(2));

  process(env, tree);
}
