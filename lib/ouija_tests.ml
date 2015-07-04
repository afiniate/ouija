open Core.Std
open Sentinel.Std

let check exp op = fun _ -> exp = op ()

let rest =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/bar/**" "hello" in
  let test1 = Basic.Test.make
    "'**' 1 component"
    (check [([("**", "/baz")], "hello")]
      (fun () -> Ouija.resolve_path sys1 "/foo/bar/baz")) in
  let test2 = Basic.Test.make
    "'**' multiple components"
    (check [([("**", "/baz/z/foo")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "/foo/bar/baz/z/foo")) in
  let test3 = Basic.Test.make
    "final '/'"
    (check [] (fun () -> Ouija.resolve_path sys1 "/foo/")) in
  [ test1; test2; test3 ]

let vars =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/baz" "hello" in
  let test1 = Basic.Test.make
    "1 ':' var alone (match is var name)"
    (check [([("bar", "bar")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "foo/bar/baz")) in
  let test2 = Basic.Test.make
    "1 ':' var matching tail"
    (check [([("bar", "super")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "foo/super/baz")) in
  let test3 = Basic.Test.make
    "1 ':' var non matching tail"
    (check []
       (fun () -> Ouija.resolve_path sys1 "foo/bar/bazer")) in
  [ test1; test2; test3 ]

let multi_vars =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/:baz" "hello" in
  let test1 = Basic.Test.make
    "2 ':' vars same name"
    (check [([("baz", "baz"); ("bar", "bar")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "/foo/bar/baz")) in
  let test2 = Basic.Test.make
    "2 ':' vars first another name"
    (check [([("baz", "baz"); ("bar", "super")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "/foo/super/baz")) in
  let test3 = Basic.Test.make
    "2 ':' vars last another name"
    (check [([("baz", "bazer"); ("bar", "bar")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "/foo/bar/bazer")) in
  [ test1; test2; test3 ]

let multi_vars_rest =
  let sys0 = Ouija.init '/' in
  let sys1 = Ouija.insert sys0 "/foo/:bar/**" "hello" in
  let test1 = Basic.Test.make
    "':' and '**' with another path element"
    (check [([("**", "/baz"); ("bar", "bar")], "hello")]
       (fun () ->Ouija.resolve_path sys1 "/foo/bar/baz")) in
  let test2 = Basic.Test.make
    "':' and '**' with several path element"
    (check [([("**", "/baz/back/bas"); ("bar", "super")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "/foo/super/baz/back/bas")) in
  [ test1; test2 ]

let dot_multi_rest =
  let sys0 = Ouija.init '.' in
  let sys1 = Ouija.insert sys0 ".foo.:bar.**" "hello" in
  let test1 = Basic.Test.make
    "':' and '**' with another path element in '.' separated path"
    (check [([("**", ".baz"); ("bar", "bar")], "hello")]
       (fun () ->Ouija.resolve_path sys1 ".foo.bar.baz")) in
  let test2 = Basic.Test.make
    "':' and '**' with several path element '.' separated path"
    (check [([("**", ".baz.back.bas"); ("bar", "super")], "hello")]
       (fun () -> Ouija.resolve_path sys1 ".foo.super.baz.back.bas")) in
  [ test1; test2 ]

let star_vars =
  let sys0 = Ouija.init '.' in
  let sys1 = Ouija.insert sys0 "foo.*.*" "hello" in
  let test1 = Basic.Test.make
    "'*' delimiting a fixed amount of positions"
    (check [([("*", "baz"); ("*", "bar")], "hello")]
       (fun () -> Ouija.resolve_path sys1 "foo.bar.baz")) in
  let test2 = Basic.Test.make
    "'*' delimiting a fixed amount of positions nomatch"
    (check [] (fun () -> Ouija.resolve_path sys1 "foo.bar.baz.bas")) in
  [ test1; test2 ]

let unit_tests = List.concat
  [rest; vars; multi_vars; multi_vars_rest; dot_multi_rest; star_vars]
