;; Election Management Contract

(define-map elections
  { election-id: uint }
  { name: (string-ascii 100), start-date: uint, end-date: uint, status: (string-ascii 20) }
)

(define-map candidates
  { election-id: uint, candidate-id: uint }
  { name: (string-ascii 50), platform: (string-utf8 500) }
)

(define-data-var election-nonce uint u0)

(define-public (create-election (name (string-ascii 100)) (start-date uint) (end-date uint))
  (let
    ((new-id (+ (var-get election-nonce) u1)))
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (map-set elections
      { election-id: new-id }
      { name: name, start-date: start-date, end-date: end-date, status: "upcoming" }
    )
    (var-set election-nonce new-id)
    (ok new-id)
  )
)

(define-public (add-candidate (election-id uint) (candidate-id uint) (name (string-ascii 50)) (platform (string-utf8 500)))
  (let
    ((election (unwrap! (map-get? elections { election-id: election-id }) (err u404))))
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (asserts! (is-eq (get status election) "upcoming") (err u403))
    (map-set candidates
      { election-id: election-id, candidate-id: candidate-id }
      { name: name, platform: platform }
    )
    (ok true)
  )
)

(define-public (update-election-status (election-id uint) (new-status (string-ascii 20)))
  (let
    ((election (unwrap! (map-get? elections { election-id: election-id }) (err u404))))
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (map-set elections
      { election-id: election-id }
      (merge election { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-election-info (election-id uint))
  (map-get? elections { election-id: election-id })
)

(define-read-only (get-candidate-info (election-id uint) (candidate-id uint))
  (map-get? candidates { election-id: election-id, candidate-id: candidate-id })
)

