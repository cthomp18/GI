camera {
   location  <0.0, -1.0, 1.0>
   up        <0.0, 1.0, 0.0>
   right     <1.0, 0.0, 0.0>
   look_at   <0.0, -1.0, 0.0>
}

light_source {<0.0, 2.7, -7.0> color rgb <400.0, 400.0, 400.0>}

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
plane {<0.0, 0.0, 1.0>, -12.0 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

// Front Wall
plane {<0.0, 0.0, -1.0>, -1.5 
   pigment {color rgb <0.7, 0.7, 0.7>}
   finish {ambient 0.2 diffuse 1.0 ior 1.5}
}

gerstner_wave {
   lowerleft <-4.0, 0.0, -13.0>
   upperright <4.0, 0.0, 2.0>
   direction <0.0, 0.0, 1.0>
   amplitude 0.1
   wavelength 3.0
   speed 0.1
   yposition 0.0
   wave { 0.04 1.0 0.1 <1.0, 0.0, 1.0> }
   wave { 0.03 0.5 1.0 <-1.0, 0.0, 0.0> }
   pigment {color rgb <1.0, 1.0, 1.0>}
   finish {ior 1.33 refraction 1.0 preflect 0.0 prefract 1.0 dropoff 0.95}
}

