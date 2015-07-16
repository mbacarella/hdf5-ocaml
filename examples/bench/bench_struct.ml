open Hdf5_caml

module A = Array

module Particle = struct
  [%h5struct
    pressure    "Pressure"    Float64;
    lati        "Latitude"    Float64;
    longi       "Longitude"   Float64;
    temperature "Temperature" Float64]
end

let bench s loops f =
  let nreps = 100 in
  let t0 = Unix.gettimeofday () in
  for i = 1 to nreps do
    let _ = f () in ()
  done;
  let t1 = Unix.gettimeofday () in
  let dt = (t1 -. t0) /. float_of_int (nreps * loops) in
  Printf.printf "%-16s %-16s\n%!" s (
    if dt > 1. then Printf.sprintf "%7.3fs" dt
    else if dt > 0.001 then Printf.sprintf "%7.3fms" (dt *. 1000.)
    else if dt > 0.000001 then Printf.sprintf "%7.3fus" (dt *. 1_000_000.)
    else Printf.sprintf "%7.3fns" (dt *. 1_000_000_000.))

let () =
  let len = 1_000 in
  let a = Particle.Array.init len (fun i e ->
    let f = float_of_int i in
    Particle.set e ~lati:f ~longi:f ~pressure:f ~temperature:(f *. 2.);
    assert (Particle.pressure e = f)) in
  let e = Particle.Array.unsafe_get a 0 in
  for i = 0 to len - 2 do
    Particle.unsafe_move e i;
    assert (float_of_int i = Particle.pressure e)
  done;
  bench "unsafe_next" len (fun () ->
    let e = Particle.Array.unsafe_get a 0 in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e;
      Particle.unsafe_next e
    done;
    !lati +. !longi +. !pressure +. !temperature);
  bench "next" len (fun () ->
    let a = a in
    let e = Particle.Array.get a 0 in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e;
      Particle.next e
    done;
    !lati +. !longi +. !pressure +. !temperature);
  bench "unsafe_prev" len (fun () ->
    let e = Particle.Array.unsafe_get a (len - 1) in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e;
      Particle.unsafe_prev e
    done;
    !lati +. !longi +. !pressure +. !temperature);
  bench "prev" len (fun () ->
    let a = a in
    let e = Particle.Array.get a (len - 1) in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e;
      Particle.prev e
    done;
    !lati +. !longi +. !pressure +. !temperature);
  bench "unsafe_move" len (fun () ->
    let e = Particle.Array.unsafe_get a 0 in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      Particle.unsafe_move e i;
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e
    done;
    !lati +. !longi +. !pressure +. !temperature);
  bench "move" len (fun () ->
    let a = a in
    let e = Particle.Array.get a 0 in
    let lati        = ref 0. in
    let longi       = ref 0. in
    let pressure    = ref 0. in
    let temperature = ref 0. in
    for i = 0 to len - 2 do
      Particle.move e i;
      lati        := !lati        +. Particle.lati        e;
      longi       := !longi       +. Particle.longi       e;
      pressure    := !pressure    +. Particle.pressure    e;
      temperature := !temperature +. Particle.temperature e
    done;
    !lati +. !longi +. !pressure +. !temperature)