camera {
   location  <0.0, 0.0, 1.0>
   up        <0.0, 1.0, 0.0>
   right     <1.0, 0.0, 0.0>
   look_at   <0.0, 0.0, 0.0>
}

light_source {<0.0, 2.7, -7.0> color rgb <400.0, 400.0, 400.0>}

sphere { <1.25, -2.15, -6.0>, 0.85
   pigment { color rgb <1.0, 1.0, 1.0>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5 preflect 0.5}
}

sphere { <-1.25, -1.65, -10.0>, 1.35
   pigment { color rgb <0.2, 1.0, 0.4>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5 preflect 0.5}
}

sphere { <1.25, 0.5, -9.0>, 0.75
   pigment { color rgb <0.2, 0.3, 1.0>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5 preflect 0.5}
}

sphere { <-1.15, -0.15, -8.0>, 0.25
   pigment { color rgb <0.0, 0.0, 0.0>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5 preflect 0.0}
}
   
// Floor
plane {<0.0, 1.0, 0.0>, -3.0 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Ceiling
plane {<0.0, -1.0, 0.0>, -3.5 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Left Wall
plane {<1.0, 0.0, 0.0>, -3.5 
   pigment {color rgb <1.0, 0.2, 0.2>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Right Wall
plane {<-1.0, 0.0, 0.0>, -3.5 
   pigment {color rgb <0.2, 1.0, 0.2>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Back Wall
plane {<0.0, 0.0, 1.0>, -13.0 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Front Wall
plane {<0.0, 0.0, -1.0>, -1.5 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}
