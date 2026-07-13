(define (problem problem-1) (:domain artifacts-2-5)
(:objects
    a1 - alpha-artifact
    a2 a3 - alpha-artifact
    b1 - beta-artifact
    b2 - beta-artifact
    c1 - cryo-artifact
    c2 - cryo-artifact
    h_alpha h_beta h_cryo h_stasis h_tunnel - hall
    p1 p2 - pod
    sr s1 s2 - slot
    r - standard-robot
    t - heavy-transporter
    d1 d2 - loading-drone
)

(:init
;artifact availability inits
(available a1)
(available a2)
(available a3)
(available b1)
(available b2)
(available c1)
(available c2)

;hall types
(iscryochamber h_cryo)
(isalpha h_alpha)
(isbeta h_beta)
(isstasislab h_stasis)
(istunnel h_tunnel)
(adjacent h_tunnel h_alpha)
(adjacent h_alpha h_tunnel)
(adjacent h_tunnel h_beta)
(adjacent h_beta h_tunnel)
(adjacent h_tunnel h_cryo)
(adjacent h_cryo h_tunnel)
(adjacent h_tunnel h_stasis)
(adjacent h_stasis h_tunnel)
(hallfree h_alpha)
(hallfree h_beta)
(hallfree h_tunnel)

;pod inits
(podstored p1)
(podstored p2)
(podempty p1)
(podempty p2)

;robot inits
(landrobotat r h_cryo)
(robot-idle r)
(unsealed r)
(coolingoff r)
(slotof sr r)
(slotempty sr)

;heavy transporter inits
(landrobotat t h_stasis)
(robot-idle t)
(unsealed t)
(coolingoff t)
(slotof s1 t)
(slotof s2 t)
(slotpair t s1 s2)
(slotpair t s2 s1)
(slotempty s1)
(slotempty s2)

;loading drone inits
(droneat d1 h_stasis)
(droneat d2 h_stasis)
(drone-idle d1)
(drone-idle d2)
(batteryfull d1)
(batteryfull d2)
(dronepair d1 d2)
;(dronepair d2 d1)
)

(:goal (and
    (indestination a1)
    (indestination a2)
    ;(indestination a3)
    (indestination b1)
    ;(indestination b2)
    ;(indestination c1)
    (indestination c2)
))

(:metric minimize (total-time))
)
