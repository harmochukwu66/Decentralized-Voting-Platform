;; Voter Achievement NFT Contract

(define-non-fungible-token voter-achievement uint)

(define-map achievement-info
  { achievement-id: uint }
  { name: (string-ascii 50), description: (string-utf8 200), image-url: (string-ascii 200) }
)

(define-map voter-achievements
  { voter: principal, achievement-id: uint }
  { earned-date: uint }
)

(define-data-var achievement-nonce uint u0)

(define-public (create-achievement (name (string-ascii 50)) (description (string-utf8 200)) (image-url (string-ascii 200)))
  (let
    ((new-id (+ (var-get achievement-nonce) u1)))
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (map-set achievement-info
      { achievement-id: new-id }
      { name: name, description: description, image-url: image-url }
    )
    (var-set achievement-nonce new-id)
    (ok new-id)
  )
)

(define-public (award-achievement (voter principal) (achievement-id uint))
  (let
    ((achievement (unwrap! (map-get? achievement-info { achievement-id: achievement-id }) (err u404))))
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (try! (nft-mint? voter-achievement achievement-id voter))
    (map-set voter-achievements
      { voter: voter, achievement-id: achievement-id }
      { earned-date: block-height }
    )
    (ok true)
  )
)

(define-read-only (get-achievement-info (achievement-id uint))
  (map-get? achievement-info { achievement-id: achievement-id })
)

(define-read-only (has-achievement (voter principal) (achievement-id uint))
  (is-some (map-get? voter-achievements { voter: voter, achievement-id: achievement-id }))
)

