(define (problem problem-1) (:domain artifacts-2-1)
(:objects 
    a1 a2 a3 b1 b2 c1 c2 - artifact
    h_alpha h_beta h_cryo h_stasis - hall
    p1 p2 - pod
    sr s1 s2 - slot
    r - standard-robot
    t - heavy-transporter
    d1 d2 - loading-drone
)

(:init
;artifact origins inits
(artifactorigin a1 h_alpha)
(artifactorigin a2 h_alpha)
(artifactorigin a3 h_alpha)
(artifactorigin b1 h_beta)
(artifactorigin b2 h_beta)
(artifactorigin c1 h_cryo)
(artifactorigin c2 h_cryo)

;heavy artifacts
(isheavy c1)
(isheavy c2)

;hall types
(iscryochamber h_cryo)
(isalpha h_alpha)
(isbeta h_beta)
(isstasislab h_stasis)

;pod inits
(podstored p1)
(podstored p2)
(podempty p1)
(podempty p2)

;robot inits
(at r h_cryo)
(occupied h_cryo)
(unsealed r)
(coolingoff r)
(slotof sr r)
(slotempty sr)

;heavy transporter inits
(at t h_stasis)
(occupied h_stasis)
(unsealed t)
(coolingoff t)
(slotof s1 t)
(slotof s2 t)
(slotpair t s1 s2)
(slotpair t s2 s1)
(slotempty s1)
(slotempty s2)

;loading drone inits
(at d1 h_stasis)
(at d2 h_stasis)
(unsealed d1)
(unsealed d2)
(coolingoff d1)
(coolingoff d2)
(batteryfull d1)
(batteryfull d2)
(dronepair d1 d2)
(dronepair d2 d1)
)

(:goal (and
    (indestination a1)
    (indestination a2)
    (indestination a3)
    (indestination b1)
    (indestination b2)
    (indestination c1)
    (indestination c2)
))
)
