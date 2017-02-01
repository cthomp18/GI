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

triangle {
<-0.5, -1.0, -6.0>,
<-0.25, -1.0, -6.0>,
<-0.5, -1.25, -6.0>
pigment { color rgb <1, 0, 0>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.25, -1.0, -6.0>,
<-0.00, -1.0, -6.0>,
<-0.25, -1.25, -6.0>
pigment { color rgb <0, 1, 0>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.0, -1.0, -6.0>,
<0.25, -1.0, -6.0>,
<-0.0, -1.25, -6.0>
pigment { color rgb <0, 0, 1>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.5, -1.25, -6.0>,
<-0.25, -1.25, -6.0>,
<-0.5, -1.5, -6.0>
pigment { color rgb <1, 1, 0>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.0, -1.25, -6.0>,
<0.25, -1.25, -6.0>,
<-0.0, -1.5, -6.0>
pigment { color rgb <0, 1, 1>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.5, -0.75, -6.0>,
<-0.25, -0.75, -6.0>,
<-0.5, -1.0, -6.0>
pigment { color rgb <0, 0, 0>}
finish {preflect 0 prefract 0}
}

triangle {
<0.25, -1.25, -6.0>,
<0.5, -1.25, -6.0>,
<0.25, -1.5, -6.0>
pigment { color rgb <1, 0, 1>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.5, -0.0, -6.0>,
<-0.25, -0.0, -6.0>,
<-0.5, -0.25, -6.0>
pigment { color rgb <1, 0, 0>}
finish {preflect 0 prefract 0}
}

triangle {
<-0.25, -0.0, -6.0>,
<-0.00, -0.0, -6.0>,
<-0.25, -0.25, -6.0>
pigment { color rgb <0, 1, 0>}
finish {preflect 0 prefract 0}
}
