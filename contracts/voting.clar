;; Voting Contract

(define-map votes
  { election-id: uint, voter: principal }
  { candidate-id: uint, timestamp: uint }
)

(define-map vote-counts
  { election-id: uint, candidate-id: uint }
  { count: uint }
)

(define-public (cast-vote (election-id uint) (candidate-id uint))
  (let
    ((voter tx-sender))
    (asserts! (is-none (map-get? votes { election-id: election-id, voter: voter })) (err u403))
    (map-set votes
      { election-id: election-id, voter: voter }
      { candidate-id: candidate-id, timestamp: block-height }
    )
    (map-set vote-counts
      { election-id: election-id, candidate-id: candidate-id }
      { count: (+ u1 (default-to u0 (get count (map-get? vote-counts { election-id: election-id, candidate-id: candidate-id })))) }
    )
    (ok true)
  )
)

(define-read-only (get-vote (election-id uint) (voter principal))
  (map-get? votes { election-id: election-id, voter: voter })
)

(define-read-only (get-vote-count (election-id uint) (candidate-id uint))
  (default-to { count: u0 } (map-get? vote-counts { election-id: election-id, candidate-id: candidate-id }))
)

