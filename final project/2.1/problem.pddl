(define (problem problem-1) (:domain artifacts-2-1)
(:objects 
    a1 a2 a3 b1 b2 - artifact
    h_alpha h_beta h_cryo h_stasis - hall
    p1 p2 - pod
    r - robot
)

(:init
;
(artifactorigin a1 h_alpha)
(artifactorigin a2 h_alpha)
(artifactorigin a3 h_alpha)
(artifactorigin b1 h_beta)
(artifactorigin b2 h_beta)

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
(unsealed r)
(coolingoff r)
(empty r)
)

(:goal (and
    (indestination a1)
    (indestination a2)
    (indestination a3)
    (indestination b1)
    (indestination b2)
    (at r h_cryo)
    (unsealed r)
    (coolingoff r)
))
)
