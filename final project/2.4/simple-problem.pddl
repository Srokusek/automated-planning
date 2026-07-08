(define (problem problem-1) (:domain artifacts-2-4)
(:objects 
    ;a1 - alpha-artifact
    ;a2 a3 - alpha-artifact
    ;b1 - beta-artifact
    ;b2 - beta-artifact
    c1 - cryo-artifact
    ;c2 - cryo-artifact
    h_alpha h_beta h_cryo h_stasis - hall
    p1 p2 - pod
    r - standard-robot
    t - heavy-transporter
    d1 d2 - loading-drone
)

(:init
;artifact availability inits
;(available a1)
;(available a2)
;(available a3)
;(available b1)
;(available b2)
(available c1)
;(available c2)

;hall types
(iscryochamber h_cryo)
(isalpha h_alpha)
(isbeta h_beta)
(isstasislab h_stasis)
(hallfree h_alpha)
(hallfree h_beta)
(tunnelfree)

;pod inits
(podstored p1)
(podstored p2)
(podempty p1)
(podempty p2)

;robot inits
(at r h_cryo)
(unsealed r)
(coolingoff r)
(empty r)

;heavy transporter inits
(at t h_stasis)
(unsealed t)
(coolingoff t)
(empty t)

;loading drone inits
(at d1 h_stasis)
(at d2 h_stasis)
(batteryfull d1)
(batteryfull d2)
(dronepair d1 d2)
(dronepair d2 d1)
)

(:goal (and
    ;(indestination a1)
    ;(indestination a2)
    ;(indestination a3)
    ;(indestination b1)
    ;(indestination b2)
    (indestination c1)
    ;(indestination c2)
))

(:metric minimize (total-time))
)
