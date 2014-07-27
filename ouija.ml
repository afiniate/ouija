type params = (string * string) list

type descr = Name of string
           | Var of string
           | Rest

type ('a) child = descr * 'a node
 and ('a) node = {children: 'a child list;
                  handlers: 'a list}

type ('a) found = Found of 'a list
                | NotFound of 'a list

type ('a) t = {path_char: char;
               root: 'a node}

let empty_node = {children = []; handlers = []}

let rec search_deeper element path_rest handler acc descr =
  match (acc, descr) with
  | (Found children, _) ->
     Found (descr::children)
  | (NotFound children, (el, node)) when el = element ->
     Found ((element, insert_into_node node handler path_rest)::children)
  | (NotFound children, _) ->
     NotFound (descr::children)
and update_children element path_rest node handler =
  let walker = search_deeper element path_rest handler in
  match List.fold_left walker (NotFound []) node.children with
  | Found children -> children
  | NotFound children ->
     (element,
      insert_into_node empty_node handler path_rest)::children
and insert_into_node node handler path =
  match path with
  | [] -> {node with handlers = handler::node.handlers}
  | element::rest ->
     {node with children = update_children element rest node handler}

let strip_leading_colon element =
  String.sub element 1 ((String.length element) - 1)

let convert_element el =
  match el with
  | "**" -> Rest
  | "*" -> Var "*"
  | _ ->  match el.[0] with
          | ':' -> Var (strip_leading_colon el)
          | _ -> Name el

let parse_path split_ch path =
  let rec first count = if (count < String.length path &&
                              path.[count] = split_ch)
                        then first (count + 1)
                        else count in
  let rec split last current length acc =
    if current < length
    then if path.[current] = split_ch
         then split (current + 1) (current + 1) length
                    (String.sub path last (current - last)::acc)
         else split last (current + 1) length acc
    else
      List.rev (String.sub path last (current - last)::acc) in
  let start = first 0 in
  split start start (String.length path) []

let convert_to_searchable_path split_ch path =
  List.map convert_element (parse_path split_ch path)

type ('a) best_carry = {depth: int;
                        param_count: int;
                        params: params;
                        handler: 'a}

(* The goal here is to ensure that the most specific path is sorted
 * first and the least specific path sorted last. We determine
 * specificity by two things. The number of params in the path list and
 * whether or not there is a rest argument.
 *
 * For example, the following paths are ordered by specificity
 * * `/foo/bar/baz/bash`
 * * `/foo/:bar/baz/bash`
 * * `/foo/:bar/**`
 * * `/foo/**`
 *)
let carry_compare a b =
  match (a,b) with
  | {depth = a_depth; param_count = a_param_count},
    {depth = b_depth; param_count = b_param_count}
       when a_depth = b_depth ->
     compare a_param_count b_param_count
  | {depth = a_depth}, {depth = b_depth}
       when a_depth != b_depth ->
     compare a_depth b_depth
  | _, _ -> 0

let node_to_acc node element_count params =
  let param_count = List.length params in
  List.map (fun handler ->
            {depth = element_count;
             param_count = param_count;
             params = params;
             handler = handler}) node.handlers

let merge {path_char=ch} =
  List.fold_left (fun acc element ->
                  acc ^ String.make 1 ch ^ element) ""

let rec p sys element element_count path params acc child  =
  match child with
  | (Name name, node) when name = element ->
     get_handler sys node element_count path params acc
  | (Var name, node) ->
     get_handler sys node element_count path ((name, element)::params) acc
  | (Rest, node) ->
     List.concat [node_to_acc node
                              element_count
                              (("**", merge sys (element::path))::params);
                  acc]
  | (Name _, _) ->
     acc
and get_handler sys node element_count path params acc =
  match path with
  | [] -> List.concat [node_to_acc node element_count params; acc]
  | element::t ->
     let new_count = element_count + 1 in
     let get_deep = p sys element new_count t params in
     List.fold_left get_deep [] node.children

let resolve_path sys path =
  let {path_char=sp; root=node} = sys in
  let path_elements = parse_path sp path in
  let result = get_handler sys node 0 path_elements [] [] in
  List.map (fun {params=params; handler=handler} ->
            (params, handler)) (List.sort carry_compare result)

let init path_split =
  {path_char=path_split; root=empty_node}

let insert {path_char=ch; root=node} path handler =
  {path_char=ch;
   root=insert_into_node node handler (convert_to_searchable_path ch path)}
