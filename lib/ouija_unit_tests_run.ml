open Core.Std
open Async.Std
open Sentinel.Std
open Ouija_tests

let () =
  Async.Executor.run Ouija_tests.unit_tests
