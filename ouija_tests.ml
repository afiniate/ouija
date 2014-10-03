open OUnit2

let rest _ =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/bar/**" "hello" in
  assert_equal [([("**", "/baz")], "hello")]
    (Ouija.resolve_path sys1 "/foo/bar/baz");
  assert_equal [([("**", "/baz/z/foo")], "hello")]
    (Ouija.resolve_path sys1 "/foo/bar/baz/z/foo");
  assert_equal [] (Ouija.resolve_path sys1 "/foo/")

let vars _ =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/baz" "hello" in
  assert_equal [([("bar", "bar")], "hello")]
    (Ouija.resolve_path sys1 "/foo/bar/baz");
  assert_equal [([("bar", "super")], "hello")]
    (Ouija.resolve_path sys1 "/foo/super/baz");
  assert_equal [] (Ouija.resolve_path sys1 "/foo/bar/bazer")

let multi_vars _ =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/:baz" "hello" in
  assert_equal [([("baz", "baz");
                  ("bar", "bar")], "hello")]
    (Ouija.resolve_path sys1 "/foo/bar/baz");
  assert_equal [([("baz", "baz");
                  ("bar", "super")], "hello")]
    (Ouija.resolve_path sys1 "/foo/super/baz");
  assert_equal [([("baz", "bazer");
                  ("bar", "bar")], "hello")] (Ouija.resolve_path sys1 "/foo/bar/bazer")

let multi_vars_rest _ =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/**" "hello" in
  assert_equal [([("**", "/baz");
                  ("bar", "bar")], "hello")]
    (Ouija.resolve_path sys1 "/foo/bar/baz");
  assert_equal [([("**", "/baz/back/bas");
                  ("bar", "super")], "hello")]
    (Ouija.resolve_path sys1 "/foo/super/baz/back/bas");
  assert_equal [([("**", "/bazer");
                  ("bar", "bar")], "hello")] (Ouija.resolve_path sys1 "/foo/bar/bazer")

let dot_multi_rest _ =
  let sys0 = Ouija.init '.' in
  let sys1 = Ouija.insert sys0 "foo.:bar.**" "hello" in
  assert_equal [([("**", ".baz");
                  ("bar", "bar")], "hello")]
    (Ouija.resolve_path sys1 "foo.bar.baz");
  assert_equal [([("**", ".baz.back.bas");
                  ("bar", "super")], "hello")]
    (Ouija.resolve_path sys1 "foo.super.baz.back.bas");
  assert_equal [([("**", ".bazer");
                  ("bar", "bar")], "hello")] (Ouija.resolve_path sys1 "foo.bar.bazer")

let star_vars _ =
  let sys0 = Ouija.init '.' in
  let sys1 = Ouija.insert sys0 "foo.*.*" "hello" in
  assert_equal [([("*", "baz");
                  ("*", "bar")], "hello")]
    (Ouija.resolve_path sys1 "foo.bar.baz");
  assert_equal [([("*", "baz");
                  ("*", "super")], "hello")]
    (Ouija.resolve_path sys1 "foo.super.baz");
  assert_equal [([("*", "bazer");
                  ("*", "bar")], "hello")] (Ouija.resolve_path sys1 "foo.bar.bazer")

let suite = "Ouija Tests" >::: ["add path rest" >:: rest;
                                "add path var" >:: vars;
                                "add multi vars" >:: multi_vars;
                                "add multi var rest" >:: multi_vars_rest;
                                "add dot multi rest" >:: dot_multi_rest;
                                "add star vars" >:: star_vars]
