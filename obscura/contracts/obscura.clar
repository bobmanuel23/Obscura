;; Tokenized Data Marketplace
;; Enables the buying, selling, and licensing of data sets with
;; privacy controls and usage tracking

;; Define SIP-010 token trait (using a more generic approach)
(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  ))

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-PARAMS (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-EXPIRED (err u105))
(define-constant ERR-DISPUTED (err u106))
(define-constant ERR-INACTIVE (err u107))

;; Data asset registry
(define-map information-assets
  { resource-id: uint }
  {
    name: (string-utf8 128),
    details: (string-utf8 1024),
    holder: principal,
    established-at: uint,
    information-type: (string-ascii 32),         ;; "dataset", "api", "stream", "model", "algorithm"
    classification: (string-ascii 64),          ;; Industry/domain category
    sample-url: (optional (string-utf8 256)),
    metadata-location: (string-utf8 256),
    example-data-url: (optional (string-utf8 256)),
    schema-url: (optional (string-utf8 256)),
    size-bytes: uint,
    hash-content: (buff 64),
    security-type: (string-ascii 32),   ;; "none", "symmetric", "asymmetric", "hybrid"
    refresh-frequency: (string-ascii 32),  ;; "static", "daily", "weekly", "monthly", "realtime"
    modified-at: uint,
    rating-score: (optional uint),       ;; 0-100 quality score
    validated: bool,
    enabled: bool,
    transaction-count: uint,
    earnings-total: uint,
    commission-percentage: uint              ;; Basis points (10000 = 100%)
  })

;; Data use licenses
(define-map agreement-types
  { agreement-id: uint }
  {
    title: (string-utf8 64),
    details: (string-utf8 512),
    author: principal,
    established-at: uint,
    business-use: bool,
    modified-works: bool,
    credit-required: bool,
    reciprocal: bool,
    cancelable: bool,
    region-restricted: bool,
    standard-identifier: (optional (string-ascii 16)),  ;; e.g., "CC-BY-4.0"
    agreement-url: (string-utf8 256),
    usage-restrictions: (string-utf8 512),
    responsibility-terms: (string-utf8 512),
    confidentiality-terms: (string-utf8 512),
    enabled: bool
  })

;; Asset marketplace listings
(define-map market-listings
  { offer-id: uint }
  {
    resource-id: uint,
    vendor: principal,
    established-at: uint,
    cost: uint,
    currency-type: (string-ascii 8),          ;; "STX" or "SIP010"
    currency-contract: (optional principal),
    agreement-id: uint,
    delivery-type: (string-ascii 16),        ;; "direct", "stream", "api", "compute"
    membership-period: (optional uint),   ;; In blocks, if subscription-based
    buyer-limit: (optional uint),            ;; Maximum number of buyers allowed, if limited
    location-restrictions: (list 10 (string-ascii 2)), ;; Country codes of restricted regions
    enabled: bool,
    highlighted: bool,
    min-purchaser-reputation: (optional uint),   ;; Minimum reputation required to purchase
    deposit-percentage: uint                  ;; Percentage of payment held in escrow
  })

;; Data purchases
(define-map transactions
  { transaction-id: uint }
  {
    offer-id: uint,
    purchaser: principal,
    completed-at: uint,
    payment-amount: uint,
    agreement-id: uint,
    key-hash: (buff 32),            ;; Hash of the access key
    secured-access-key: (buff 256),      ;; Encrypted access key for buyer
    expiration-at: (optional uint),
    state: (string-ascii 16),             ;; "active", "expired", "revoked", "disputed"
    accessed-at: (optional uint),
    access-count: uint,
    auto-renewal: (optional bool),
    cancellation-reason: (optional (string-utf8 256))
  })

;; Data access logs
(define-map usage-logs
  { transaction-id: uint, entry-id: uint }
  {
    purchaser: principal,
    logged-at: uint,
    entry-method: (string-ascii 16),      ;; "download", "api", "stream", "compute"
    search-parameters: (optional (string-utf8 256)),
    information-subset: (optional (string-utf8 256)),
    address-hash: (optional (buff 32)),
    operation-hash: (buff 32),
    completed: bool,
    failure-message: (optional (string-utf8 256))
  })

;; Reputation scores
(define-map credibility-scores
  { account: principal }
  {
    vendor-score: uint,                     ;; 0-100 seller reputation
    purchaser-score: uint,                      ;; 0-100 buyer reputation
    information-quality-score: uint,               ;; 0-100 data quality score
    conflicts-initiated: uint,
    conflicts-lost: uint,
    transaction-count: uint,
    acquisition-count: uint,
    mean-data-quality: uint,
    review-count: uint,
    identity-verified: bool
  })

;; Reviews
(define-map feedback
  { evaluator: principal, resource-id: uint }
  {
    score: uint,                           ;; 1-5 stars
    comment-text: (string-utf8 512),
    posted-at: uint,
    transaction-id: uint,
    information-quality-rating: uint,              ;; 1-5 stars
    precision-rating: uint,                  ;; 1-5 stars
    coverage-rating: uint,              ;; 1-5 stars
    utility-rating: uint,                ;; 1-5 stars
    purchase-verified: bool,
    positive-votes: uint,
    negative-votes: uint
  })

;; Data disputes
(define-map information-disputes
  { case-id: uint }
  {
    transaction-id: uint,
    claimant: principal,
    defendant: principal,
    filed-at: uint,
    justification: (string-utf8 512),
    proof-hash: (buff 32),
    state: (string-ascii 16),              ;; "open", "resolved", "cancelled"
    outcome: (optional (string-utf8 512)),
    settled-at: (optional uint),
    mediator: (optional principal),
    purchaser-refund-percentage: (optional uint),
    challenge-deadline: (optional uint),
    challenged: bool
  })

;; Escrow funds
(define-map held-funds
  { transaction-id: uint }
  {
    sum: uint,
    vendor: principal,
    purchaser: principal,
    unlock-conditions: (string-utf8 256),
    unlock-at: (optional uint),
    unlocked: bool,
    contested: bool
  })

;; Data validators
(define-map information-validators
  { inspector: principal }
  {
    title: (string-utf8 64),
    details: (string-utf8 512),
    expertise: (list 10 (string-ascii 32)),
    commission-percentage: uint,                   ;; Basis points
    assessments-completed: uint,
    mean-rating: uint,                   ;; 0-100 rating
    enrolled-at: uint,
    enabled: bool
  })

;; Validation reports
(define-map assessment-reports
  { resource-id: uint, inspector: principal }
  {
    document-hash: (buff 32),
    filed-at: uint,
    rating-score: uint,                    ;; 0-100 score
    precision-score: uint,                   ;; 0-100 score
    coverage-score: uint,               ;; 0-100 score
    reliability-score: uint,                ;; 0-100 score
    approach: (string-utf8 256),
    problems-found: (list 10 (string-utf8 128)),
    suggestions: (string-utf8 512),
    approval-level: (string-ascii 16), ;; "basic", "standard", "premium"
    approval-valid-until: (optional uint)
  })

;; Data categories
(define-map information-categories
  { classification-id: uint }
  {
    title: (string-ascii 64),
    details: (string-utf8 256),
    parent-classification: (optional uint),
    established-at: uint,
    resource-count: uint,
    interest-score: uint,                 ;; Calculated score based on activity
    popular: bool                          ;; Whether category is trending
  })

;; Next available IDs
(define-data-var next-resource-id uint u1)
(define-data-var next-agreement-id uint u1)
(define-data-var next-offer-id uint u1)
(define-data-var next-transaction-id uint u1)
(define-data-var next-case-id uint u1)
(define-data-var next-classification-id uint u1)
(define-map next-entry-id { transaction-id: uint } { id: uint })

;; Protocol configuration
(define-data-var service-fee-percentage uint u250)   ;; 2.5% platform fee
(define-data-var payment-recipient principal CONTRACT-OWNER)
(define-data-var conflict-resolution-fee uint u5000000)  ;; 5 STX
(define-data-var standard-deposit-period uint u1440)      ;; Default escrow period in blocks
(define-data-var min-credibility-for-listing uint u30)   ;; Minimum reputation to create listings

;; Input validation functions
(define-private (validate-string-length (str (string-utf8 1024)) (max-len uint))
  (if (<= (len str) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-ascii-length (str (string-ascii 64)) (max-len uint))
  (if (<= (len str) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-buffer-length (buf (buff 256)) (max-len uint))
  (if (<= (len buf) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-percentage (percentage uint))
  (if (<= percentage u10000)
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-rating (rating uint))
  (if (and (>= rating u1) (<= rating u5))
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-score (score uint))
  (if (<= score u100)
    (ok true)
    ERR-INVALID-PARAMS
  ))

;; Additional validation functions for input sanitization
(define-private (validate-uint-range (value uint) (min-val uint) (max-val uint))
  (if (and (>= value min-val) (<= value max-val))
    (ok true)
    ERR-INVALID-PARAMS
  ))

(define-private (validate-non-zero (value uint))
  (if (> value u0)
    (ok true)
    ERR-INVALID-PARAMS
  ))

;; Update reputation based on review
(define-private (update-reputation-from-review (vendor principal) (quality-rating uint))
  (let
    ((current-rep (default-to
                    {
                     vendor-score: u50,
                     purchaser-score: u50,
                     information-quality-score: u50,
                     conflicts-initiated: u0,
                     conflicts-lost: u0,
                     transaction-count: u0,
                     acquisition-count: u0,
                     mean-data-quality: u0,
                     review-count: u0,
                     identity-verified: false
                   }
                   (map-get? credibility-scores { account: vendor }))))
    
    ;; Calculate new average quality score
    (let
      ((review-count (+ (get review-count current-rep) u1))
       (new-avg-quality (if (> (get review-count current-rep) u0)
                          (/ (+ (* (get mean-data-quality current-rep) (get review-count current-rep))
                                (* quality-rating u20)) ;; Convert 1-5 to 0-100 scale
                             review-count)
                          (* quality-rating u20))))
      
      ;; Update reputation
      (map-set credibility-scores
        { account: vendor }
        (merge current-rep
          {
            mean-data-quality: new-avg-quality,
            review-count: review-count,
            information-quality-score: new-avg-quality
          }
        )
      )
      
      (ok true)
    )
  ))

;; Update reputations based on dispute outcome
(define-private (update-reputation-from-dispute
                (purchaser principal)
                (vendor principal)
                (purchaser-refund-percentage uint))
  (let
    ((purchaser-rep (default-to
                  {
                   vendor-score: u50,
                   purchaser-score: u50,
                   information-quality-score: u50,
                   conflicts-initiated: u0,
                   conflicts-lost: u0,
                   transaction-count: u0,
                   acquisition-count: u0,
                   mean-data-quality: u0,
                   review-count: u0,
                   identity-verified: false
                 }
                 (map-get? credibility-scores { account: purchaser })))
     (vendor-rep (default-to
                   {
                    vendor-score: u50,
                    purchaser-score: u50,
                    information-quality-score: u50,
                    conflicts-initiated: u0,
                    conflicts-lost: u0,
                    transaction-count: u0,
                    acquisition-count: u0,
                    mean-data-quality: u0,
                    review-count: u0,
                    identity-verified: false
                  }
                  (map-get? credibility-scores { account: vendor }))))
    
    ;; Update buyer reputation
    (map-set credibility-scores
      { account: purchaser }
      (merge purchaser-rep
        {
          conflicts-initiated: (+ (get conflicts-initiated purchaser-rep) u1),
          conflicts-lost: (if (< purchaser-refund-percentage u5000)
                           (+ (get conflicts-lost purchaser-rep) u1)
                          (get conflicts-lost purchaser-rep))
        }
      )
    )
    
    ;; Update seller reputation
    (map-set credibility-scores
      { account: vendor }
      (merge vendor-rep
        {
          conflicts-lost: (if (> purchaser-refund-percentage u5000)
                          (+ (get conflicts-lost vendor-rep) u1)
                          (get conflicts-lost vendor-rep))
        }
      )
    )
    
    (ok true)
  ))

;; Create an escrow for a purchase
(define-private (create-escrow
                (transaction-id uint)
                (vendor principal)
                (purchaser principal)
                (sum uint))
  (begin
    ;; Validate inputs
    (asserts! (> transaction-id u0) ERR-INVALID-PARAMS)
    (asserts! (> sum u0) ERR-INVALID-PARAMS)
    
    (map-set held-funds
      { transaction-id: transaction-id }
      {
        sum: sum,
        vendor: vendor,
        purchaser: purchaser,
        unlock-conditions: u"Automatic release after escrow period if no disputes",
        unlock-at: (some (+ block-height (var-get standard-deposit-period))),
        unlocked: false,
        contested: false
      }
    )
    
    (ok true)
  ))

;; Resolve escrow based on dispute resolution
(define-private (resolve-escrow (transaction-id uint) (purchaser-refund-percentage uint))
  (let
    ((escrow (unwrap! (map-get? held-funds { transaction-id: transaction-id }) ERR-NOT-FOUND)))
    
    ;; Validate inputs
    (asserts! (> transaction-id u0) ERR-INVALID-PARAMS)
    (asserts! (<= purchaser-refund-percentage u10000) ERR-INVALID-PARAMS)
    
    ;; Calculate amounts
    (let
      ((purchaser-amount (/ (* (get sum escrow) purchaser-refund-percentage) u10000))
       (vendor-amount (- (get sum escrow) purchaser-amount)))
      
      ;; Transfer to buyer if amount > 0
      (if (> purchaser-amount u0)
          (unwrap! (as-contract (stx-transfer? purchaser-amount tx-sender (get purchaser escrow))) ERR-INVALID-PARAMS)
          true
      )
      
      ;; Transfer to seller if amount > 0
      (if (> vendor-amount u0)
          (unwrap! (as-contract (stx-transfer? vendor-amount tx-sender (get vendor escrow))) ERR-INVALID-PARAMS)
          true
      )
      
      ;; Mark escrow as released
      (map-set held-funds
        { transaction-id: transaction-id }
        (merge escrow { unlocked: true })
      )
      
      (ok true)
    )
  ))

;; Register a new data asset
(define-public (register-data-asset
                (name (string-utf8 128))
                (details (string-utf8 1024))
                (information-type (string-ascii 32))
                (classification (string-ascii 64))
                (metadata-location (string-utf8 256))
                (sample-url (optional (string-utf8 256)))
                (example-data-url (optional (string-utf8 256)))
                (schema-url (optional (string-utf8 256)))
                (size-bytes uint)
                (hash-content (buff 64))
                (security-type (string-ascii 32))
                (refresh-frequency (string-ascii 32))
                (commission-percentage uint))
  (let
    ((resource-id (var-get next-resource-id))
     ;; Sanitize inputs by validating them first
     (validated-name (begin (try! (validate-string-length name u128)) name))
     (validated-details (begin (try! (validate-string-length details u1024)) details))
     (validated-information-type (begin (try! (validate-ascii-length information-type u32)) information-type))
     (validated-classification (begin (try! (validate-ascii-length classification u64)) classification))
     (validated-metadata-location (begin (try! (validate-string-length metadata-location u256)) metadata-location))
     (validated-hash-content (begin (try! (validate-buffer-length hash-content u64)) hash-content))
     (validated-security-type (begin (try! (validate-ascii-length security-type u32)) security-type))
     (validated-refresh-frequency (begin (try! (validate-ascii-length refresh-frequency u32)) refresh-frequency))
     (validated-commission-percentage (begin (try! (validate-uint-range commission-percentage u0 u3000)) commission-percentage))
     (validated-size-bytes (begin (try! (validate-non-zero size-bytes)) size-bytes)))
    
    ;; Additional validation
    (asserts! (is-valid-information-type validated-information-type) ERR-INVALID-PARAMS)
    (asserts! (is-valid-security-type validated-security-type) ERR-INVALID-PARAMS)
    (asserts! (is-valid-refresh-frequency validated-refresh-frequency) ERR-INVALID-PARAMS)
    
    ;; Validate optional URLs
    (match sample-url
      url (try! (validate-string-length url u256))
      true
    )
    (match example-data-url
      url (try! (validate-string-length url u256))
      true
    )
    (match schema-url
      url (try! (validate-string-length url u256))
      true
    )
    
    ;; Create the data asset using validated inputs
    (map-set information-assets
      { resource-id: resource-id }
      {
        name: validated-name,
        details: validated-details,
        holder: tx-sender,
        established-at: block-height,
        information-type: validated-information-type,
        classification: validated-classification,
        sample-url: sample-url,
        metadata-location: validated-metadata-location,
        example-data-url: example-data-url,
        schema-url: schema-url,
        size-bytes: validated-size-bytes,
        hash-content: validated-hash-content,
        security-type: validated-security-type,
        refresh-frequency: validated-refresh-frequency,
        modified-at: block-height,
        rating-score: none,
        validated: false,
        enabled: true,
        transaction-count: u0,
        earnings-total: u0,
        commission-percentage: validated-commission-percentage
      }
    )
    
    ;; Increment asset ID counter
    (var-set next-resource-id (+ resource-id u1))
    
    (ok resource-id)
  ))

;; Check if data type is valid
(define-private (is-valid-information-type (information-type (string-ascii 32)))
  (or (is-eq information-type "dataset")
      (or (is-eq information-type "api")
          (or (is-eq information-type "stream")
              (or (is-eq information-type "model")
                  (is-eq information-type "algorithm"))))))

;; Check if encryption type is valid
(define-private (is-valid-security-type (security-type (string-ascii 32)))
  (or (is-eq security-type "none")
      (or (is-eq security-type "symmetric")
          (or (is-eq security-type "asymmetric")
              (is-eq security-type "hybrid")))))

;; Check if update frequency is valid
(define-private (is-valid-refresh-frequency (refresh-frequency (string-ascii 32)))
  (or (is-eq refresh-frequency "static")
      (or (is-eq refresh-frequency "daily")
          (or (is-eq refresh-frequency "weekly")
              (or (is-eq refresh-frequency "monthly")
                  (is-eq refresh-frequency "realtime"))))))

;; Create a license type
(define-public (create-license-type
                (title (string-utf8 64))
                (details (string-utf8 512))
                (business-use bool)
                (modified-works bool)
                (credit-required bool)
                (reciprocal bool)
                (cancelable bool)
                (region-restricted bool)
                (standard-identifier (optional (string-ascii 16)))
                (agreement-url (string-utf8 256))
                (usage-restrictions (string-utf8 512))
                (responsibility-terms (string-utf8 512))
                (confidentiality-terms (string-utf8 512)))
  (let
    ((agreement-id (var-get next-agreement-id))
     ;; Sanitize inputs
     (validated-title (begin (try! (validate-string-length title u64)) title))
     (validated-details (begin (try! (validate-string-length details u512)) details))
     (validated-agreement-url (begin (try! (validate-string-length agreement-url u256)) agreement-url))
     (validated-usage-restrictions (begin (try! (validate-string-length usage-restrictions u512)) usage-restrictions))
     (validated-responsibility-terms (begin (try! (validate-string-length responsibility-terms u512)) responsibility-terms))
     (validated-confidentiality-terms (begin (try! (validate-string-length confidentiality-terms u512)) confidentiality-terms)))
    
    ;; Validate optional standard code
    (match standard-identifier
      code (try! (validate-ascii-length code u16))
      true
    )
    
    ;; Create the license using validated inputs
    (map-set agreement-types
      { agreement-id: agreement-id }
      {
        title: validated-title,
        details: validated-details,
        author: tx-sender,
        established-at: block-height,
        business-use: business-use,
        modified-works: modified-works,
        credit-required: credit-required,
        reciprocal: reciprocal,
        cancelable: cancelable,
        region-restricted: region-restricted,
        standard-identifier: standard-identifier,
        agreement-url: validated-agreement-url,
        usage-restrictions: validated-usage-restrictions,
        responsibility-terms: validated-responsibility-terms,
        confidentiality-terms: validated-confidentiality-terms,
        enabled: true
      }
    )
    
    ;; Increment license ID counter
    (var-set next-agreement-id (+ agreement-id u1))
    
    (ok agreement-id)
  ))

;; Create a marketplace listing
(define-public (create-listing
                (resource-id uint)
                (cost uint)
                (currency-type (string-ascii 8))
                (currency-contract (optional principal))
                (agreement-id uint)
                (delivery-type (string-ascii 16))
                (membership-period (optional uint))
                (buyer-limit (optional uint))
                (location-restrictions (list 10 (string-ascii 2)))
                (min-purchaser-reputation (optional uint))
                (deposit-percentage uint))
  (let
    ((asset (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND))
     (license (unwrap! (map-get? agreement-types { agreement-id: agreement-id }) ERR-NOT-FOUND))
     (offer-id (var-get next-offer-id))
     (vendor-reputation (get-vendor-reputation tx-sender))
     ;; Sanitize inputs
     (validated-resource-id (begin (try! (validate-non-zero resource-id)) resource-id))
     (validated-cost (begin (try! (validate-non-zero cost)) cost))
     (validated-agreement-id (begin (try! (validate-non-zero agreement-id)) agreement-id))
     (validated-deposit-percentage (begin (try! (validate-percentage deposit-percentage)) deposit-percentage)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get holder asset)) ERR-UNAUTHORIZED)
    (asserts! (get enabled asset) ERR-INACTIVE)
    (asserts! (get enabled license) ERR-INACTIVE)
    (asserts! (is-valid-currency-type currency-type) ERR-INVALID-PARAMS)
    (asserts! (or (is-eq currency-type "STX") (is-some currency-contract)) ERR-INVALID-PARAMS)
    (asserts! (is-valid-delivery-type delivery-type) ERR-INVALID-PARAMS)
    (asserts! (>= vendor-reputation (var-get min-credibility-for-listing)) ERR-UNAUTHORIZED)
    
    ;; Validate georestrictions list
    (asserts! (<= (len location-restrictions) u10) ERR-INVALID-PARAMS)
    
    ;; Create the listing using validated inputs
    (map-set market-listings
      { offer-id: offer-id }
      {
        resource-id: validated-resource-id,
        vendor: tx-sender,
        established-at: block-height,
        cost: validated-cost,
        currency-type: currency-type,
        currency-contract: currency-contract,
        agreement-id: validated-agreement-id,
        delivery-type: delivery-type,
        membership-period: membership-period,
        buyer-limit: buyer-limit,
        location-restrictions: location-restrictions,
        enabled: true,
        highlighted: false,
        min-purchaser-reputation: min-purchaser-reputation,
        deposit-percentage: validated-deposit-percentage
      }
    )
    
    ;; Increment listing ID counter
    (var-set next-offer-id (+ offer-id u1))
    
    (ok offer-id)
  ))

;; Get seller reputation score
(define-private (get-vendor-reputation (vendor principal))
  (default-to u0 (get vendor-score (map-get? credibility-scores { account: vendor }))))

;; Check if token type is valid
(define-private (is-valid-currency-type (currency-type (string-ascii 8)))
  (or (is-eq currency-type "STX")
      (is-eq currency-type "SIP010")))

;; Check if access type is valid
(define-private (is-valid-delivery-type (delivery-type (string-ascii 16)))
  (or (is-eq delivery-type "direct")
      (or (is-eq delivery-type "stream")
          (or (is-eq delivery-type "api")
              (is-eq delivery-type "compute")))))

;; Purchase a data asset with STX
(define-public (purchase-data-stx (offer-id uint) (key-hash (buff 32)))
  (let
    ((listing (unwrap! (map-get? market-listings { offer-id: offer-id }) ERR-NOT-FOUND))
     (asset (unwrap! (map-get? information-assets { resource-id: (get resource-id listing) }) ERR-NOT-FOUND))
     (license (unwrap! (map-get? agreement-types { agreement-id: (get agreement-id listing) }) ERR-NOT-FOUND))
     (transaction-id (var-get next-transaction-id))
     (cost (get cost listing))
     (purchaser-reputation (get-purchaser-reputation tx-sender))
     ;; Sanitize inputs
     (validated-offer-id (begin (try! (validate-non-zero offer-id)) offer-id))
     (validated-key-hash (begin (try! (validate-buffer-length key-hash u32)) key-hash)))
    
    ;; Validate
    (asserts! (get enabled listing) ERR-INACTIVE)
    (asserts! (get enabled asset) ERR-INACTIVE)
    (asserts! (is-eq (get currency-type listing) "STX") ERR-INVALID-PARAMS)
    (asserts! (not (is-eq tx-sender (get vendor listing))) ERR-UNAUTHORIZED)
    
    ;; Check buyer eligibility
    (match (get min-purchaser-reputation listing)
      min-rep (asserts! (>= purchaser-reputation min-rep) ERR-UNAUTHORIZED)
      true
    )
    
    ;; Calculate fees and amounts
    (let
      ((service-fee (/ (* cost (var-get service-fee-percentage)) u10000))
       (deposit-amount (/ (* cost (get deposit-percentage listing)) u10000))
       (immediate-release-amount (- (- cost service-fee) deposit-amount)))
      
      ;; Validate amounts
      (asserts! (>= cost (+ service-fee deposit-amount)) ERR-INSUFFICIENT-FUNDS)
      
      ;; Transfer STX from buyer
      (try! (stx-transfer? cost tx-sender (as-contract tx-sender)))
      
      ;; Transfer platform fee
      (try! (as-contract (stx-transfer? service-fee tx-sender (var-get payment-recipient))))
      
      ;; Calculate expiration if subscription-based
      (let
        ((expiration-at (match (get membership-period listing)
                      period (some (+ block-height period))
                      none)))
        
        ;; Create purchase record using validated inputs
        (map-set transactions
          { transaction-id: transaction-id }
          {
            offer-id: validated-offer-id,
            purchaser: tx-sender,
            completed-at: block-height,
            payment-amount: cost,
            agreement-id: (get agreement-id listing),
            key-hash: validated-key-hash,
            secured-access-key: 0x,
            expiration-at: expiration-at,
            state: "active",
            accessed-at: none,
            access-count: u0,
            auto-renewal: none,
            cancellation-reason: none
          }
        )
        
        ;; Set up escrow if needed and transfer immediate funds to seller
        (begin
          ;; Handle escrow creation
          (if (> deposit-amount u0)
              (unwrap! (create-escrow transaction-id (get vendor listing) tx-sender deposit-amount) ERR-INVALID-PARAMS)
              true
          )
          
          ;; Transfer immediate funds to seller
          (if (> immediate-release-amount u0)
              (unwrap! (as-contract (stx-transfer? immediate-release-amount tx-sender (get vendor listing))) ERR-INVALID-PARAMS)
              true
          )
          
          ;; Initialize access log counter
          (map-set next-entry-id { transaction-id: transaction-id } { id: u0 })
          
          ;; Update asset stats
          (map-set information-assets
            { resource-id: (get resource-id listing) }
            (merge asset 
              {
                transaction-count: (+ (get transaction-count asset) u1),
                earnings-total: (+ (get earnings-total asset) cost)
              }
            )
          )
          
          ;; Increment purchase ID counter
          (var-set next-transaction-id (+ transaction-id u1))
          
          (ok transaction-id)
        )
      )
    )
  ))

;; Get buyer reputation score
(define-private (get-purchaser-reputation (purchaser principal))
  (default-to u0 (get purchaser-score (map-get? credibility-scores { account: purchaser }))))

;; Provide access key for purchased data
(define-public (provide-access-key
                (transaction-id uint)
                (secured-access-key (buff 256)))
  (let
    ((purchase (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? market-listings { offer-id: (get offer-id purchase) }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-transaction-id (begin (try! (validate-non-zero transaction-id)) transaction-id))
     (validated-secured-access-key (begin (try! (validate-buffer-length secured-access-key u256)) secured-access-key)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get vendor listing)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get state purchase) "active") ERR-INVALID-PARAMS)
    
    ;; Update purchase with access key using validated inputs
    (map-set transactions
      { transaction-id: validated-transaction-id }
      (merge purchase { secured-access-key: validated-secured-access-key })
    )
    
    (ok true)
  ))

;; Log data access
(define-public (log-data-access
                (transaction-id uint)
                (entry-method (string-ascii 16))
                (search-parameters (optional (string-utf8 256)))
                (information-subset (optional (string-utf8 256)))
                (address-hash (optional (buff 32)))
                (operation-hash (buff 32))
                (completed bool)
                (failure-message (optional (string-utf8 256))))
  (let
    ((purchase (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? market-listings { offer-id: (get offer-id purchase) }) ERR-NOT-FOUND))
     (asset (unwrap! (map-get? information-assets { resource-id: (get resource-id listing) }) ERR-NOT-FOUND))
     (log-counter (unwrap! (map-get? next-entry-id { transaction-id: transaction-id }) ERR-NOT-FOUND))
     (entry-id (get id log-counter))
     ;; Sanitize inputs
     (validated-transaction-id (begin (try! (validate-non-zero transaction-id)) transaction-id))
     (validated-operation-hash (begin (try! (validate-buffer-length operation-hash u32)) operation-hash)))
    
    ;; Validate
    (asserts! (or (is-eq tx-sender (get purchaser purchase))
                 (is-eq tx-sender (get vendor listing))) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get state purchase) "active") ERR-INVALID-PARAMS)
    (asserts! (is-valid-entry-method entry-method) ERR-INVALID-PARAMS)
    
    ;; Validate optional parameters
    (match search-parameters
      params (try! (validate-string-length params u256))
      true
    )
    (match information-subset
      subset (try! (validate-string-length subset u256))
      true
    )
    (match address-hash
      hash (try! (validate-buffer-length hash u32))
      true
    )
    (match failure-message
      msg (try! (validate-string-length msg u256))
      true
    )
    
    ;; Check if expired for subscription
    (match (get expiration-at purchase)
      expiry (asserts! (< block-height expiry) ERR-EXPIRED)
      true
    )
    
    ;; Create access log using validated inputs
    (map-set usage-logs
      { transaction-id: validated-transaction-id, entry-id: entry-id }
      {
        purchaser: (get purchaser purchase),
        logged-at: block-height,
        entry-method: entry-method,
        search-parameters: search-parameters,
        information-subset: information-subset,
        address-hash: address-hash,
        operation-hash: validated-operation-hash,
        completed: completed,
        failure-message: failure-message
      }
    )
    
    ;; Update purchase usage stats
    (map-set transactions
      { transaction-id: validated-transaction-id }
      (merge purchase 
        {
          accessed-at: (some block-height),
          access-count: (+ (get access-count purchase) u1)
        }
      )
    )
    
    ;; Increment log counter
    (map-set next-entry-id
      { transaction-id: validated-transaction-id }
      { id: (+ entry-id u1) }
    )
    
    (ok entry-id)
  ))

;; Check if access method is valid
(define-private (is-valid-entry-method (entry-method (string-ascii 16)))
  (or (is-eq entry-method "download")
      (or (is-eq entry-method "api")
          (or (is-eq entry-method "stream")
              (is-eq entry-method "compute")))))

;; Submit a review for a data asset
(define-public (submit-review
                (resource-id uint)
                (score uint)
                (comment-text (string-utf8 512))
                (transaction-id uint)
                (information-quality-rating uint)
                (precision-rating uint)
                (coverage-rating uint)
                (utility-rating uint))
  (let
    ((asset (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND))
     (purchase (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-resource-id (begin (try! (validate-non-zero resource-id)) resource-id))
     (validated-score (begin (try! (validate-rating score)) score))
     (validated-comment-text (begin (try! (validate-string-length comment-text u512)) comment-text))
     (validated-transaction-id (begin (try! (validate-non-zero transaction-id)) transaction-id))
     (validated-information-quality-rating (begin (try! (validate-rating information-quality-rating)) information-quality-rating))
     (validated-precision-rating (begin (try! (validate-rating precision-rating)) precision-rating))
     (validated-coverage-rating (begin (try! (validate-rating coverage-rating)) coverage-rating))
     (validated-utility-rating (begin (try! (validate-rating utility-rating)) utility-rating)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get purchaser purchase)) ERR-UNAUTHORIZED)
    
    ;; Check if review already exists
    (asserts! (is-none (map-get? feedback { evaluator: tx-sender, resource-id: validated-resource-id })) ERR-ALREADY-EXISTS)
    
    ;; Create the review using validated inputs
    (map-set feedback
      { evaluator: tx-sender, resource-id: validated-resource-id }
      {
        score: validated-score,
        comment-text: validated-comment-text,
        posted-at: block-height,
        transaction-id: validated-transaction-id,
        information-quality-rating: validated-information-quality-rating,
        precision-rating: validated-precision-rating,
        coverage-rating: validated-coverage-rating,
        utility-rating: validated-utility-rating,
        purchase-verified: true,
        positive-votes: u0,
        negative-votes: u0
      }
    )
    
    ;; Update reputation scores using validated input
    (unwrap! (update-reputation-from-review (get holder asset) validated-information-quality-rating) ERR-INVALID-PARAMS)
    
    (ok true)
  ))

;; Register as a data validator
(define-public (register-validator
                (title (string-utf8 64))
                (details (string-utf8 512))
                (expertise (list 10 (string-ascii 32)))
                (commission-percentage uint))
  (let
    (;; Sanitize inputs
     (validated-title (begin (try! (validate-string-length title u64)) title))
     (validated-details (begin (try! (validate-string-length details u512)) details))
     (validated-commission-percentage (begin (try! (validate-uint-range commission-percentage u0 u3000)) commission-percentage)))
    
    ;; Validate parameters
    (asserts! (> (len expertise) u0) ERR-INVALID-PARAMS)
    (asserts! (<= (len expertise) u10) ERR-INVALID-PARAMS)
    
    ;; Check if already registered
    (asserts! (is-none (map-get? information-validators { inspector: tx-sender })) ERR-ALREADY-EXISTS)
    
    ;; Register the validator using validated inputs
    (map-set information-validators
      { inspector: tx-sender }
      {
        title: validated-title,
        details: validated-details,
        expertise: expertise,
        commission-percentage: validated-commission-percentage,
        assessments-completed: u0,
        mean-rating: u0,
        enrolled-at: block-height,
        enabled: true
      }
    )
    
    (ok true)
  ))

;; Submit validation report
(define-public (submit-validation-report
                (resource-id uint)
                (document-hash (buff 32))
                (rating-score uint)
                (precision-score uint)
                (coverage-score uint)
                (reliability-score uint)
                (approach (string-utf8 256))
                (problems-found (list 10 (string-utf8 128)))
                (suggestions (string-utf8 512))
                (approval-level (string-ascii 16))
                (approval-valid-until (optional uint)))
  (let
    ((asset (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND))
     (validator-data (unwrap! (map-get? information-validators { inspector: tx-sender }) ERR-UNAUTHORIZED))
     ;; Sanitize inputs
     (validated-resource-id (begin (try! (validate-non-zero resource-id)) resource-id))
     (validated-document-hash (begin (try! (validate-buffer-length document-hash u32)) document-hash))
     (validated-rating-score (begin (try! (validate-score rating-score)) rating-score))
     (validated-precision-score (begin (try! (validate-score precision-score)) precision-score))
     (validated-coverage-score (begin (try! (validate-score coverage-score)) coverage-score))
     (validated-reliability-score (begin (try! (validate-score reliability-score)) reliability-score))
     (validated-approach (begin (try! (validate-string-length approach u256)) approach))
     (validated-suggestions (begin (try! (validate-string-length suggestions u512)) suggestions)))
    
    ;; Validate
    (asserts! (get enabled validator-data) ERR-INACTIVE)
    (asserts! (is-valid-approval-level approval-level) ERR-INVALID-PARAMS)
    (asserts! (<= (len problems-found) u10) ERR-INVALID-PARAMS)
    
    ;; Create validation report using validated inputs
    (map-set assessment-reports
      { resource-id: validated-resource-id, inspector: tx-sender }
      {
        document-hash: validated-document-hash,
        filed-at: block-height,
        rating-score: validated-rating-score,
        precision-score: validated-precision-score,
        coverage-score: validated-coverage-score,
        reliability-score: validated-reliability-score,
        approach: validated-approach,
        problems-found: problems-found,
        suggestions: validated-suggestions,
        approval-level: approval-level,
        approval-valid-until: approval-valid-until
      }
    )
    
    ;; Update asset with quality score and verified status
    (map-set information-assets
      { resource-id: validated-resource-id }
      (merge asset 
        {
          rating-score: (some validated-rating-score),
          validated: true
        }
      )
    )
    
    ;; Update validator stats
    (map-set information-validators
      { inspector: tx-sender }
      (merge validator-data 
        { assessments-completed: (+ (get assessments-completed validator-data) u1) }
      )
    )
    
    (ok true)
  ))

;; Check if certification level is valid
(define-private (is-valid-approval-level (level (string-ascii 16)))
  (or (is-eq level "basic")
      (or (is-eq level "standard")
          (is-eq level "premium"))))

;; File a dispute for a data purchase
(define-public (file-dispute
                (transaction-id uint)
                (justification (string-utf8 512))
                (proof-hash (buff 32)))
  (let
    ((purchase (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? market-listings { offer-id: (get offer-id purchase) }) ERR-NOT-FOUND))
     (case-id (var-get next-case-id))
     (escrow (map-get? held-funds { transaction-id: transaction-id }))
     ;; Sanitize inputs
     (validated-transaction-id (begin (try! (validate-non-zero transaction-id)) transaction-id))
     (validated-justification (begin (try! (validate-string-length justification u512)) justification))
     (validated-proof-hash (begin (try! (validate-buffer-length proof-hash u32)) proof-hash)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get purchaser purchase)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get state purchase) "active") ERR-INVALID-PARAMS)
    
    ;; Pay dispute filing fee
    (try! (stx-transfer? (var-get conflict-resolution-fee) tx-sender (var-get payment-recipient)))
    
    ;; Create the dispute using validated inputs
    (map-set information-disputes
      { case-id: case-id }
      {
        transaction-id: validated-transaction-id,
        claimant: tx-sender,
        defendant: (get vendor listing),
        filed-at: block-height,
        justification: validated-justification,
        proof-hash: validated-proof-hash,
        state: "open",
        outcome: none,
        settled-at: none,
        mediator: none,
        purchaser-refund-percentage: none,
        challenge-deadline: none,
        challenged: false
      }
    )
    
    ;; Mark escrow as disputed if exists
    (match escrow
      escrow-data (map-set held-funds
                    { transaction-id: validated-transaction-id }
                    (merge escrow-data { contested: true })
                  )
      true
    )
    
    ;; Update purchase status
    (map-set transactions
      { transaction-id: validated-transaction-id }
      (merge purchase { state: "disputed" })
    )
    
    ;; Increment dispute ID counter
    (var-set next-case-id (+ case-id u1))
    
    (ok case-id)
  ))

;; Resolve a dispute (simplified arbitration)
(define-public (resolve-dispute
                (case-id uint)
                (outcome (string-utf8 512))
                (purchaser-refund-percentage uint))
  (let
    ((dispute (unwrap! (map-get? information-disputes { case-id: case-id }) ERR-NOT-FOUND))
     (transaction-id (get transaction-id dispute))
     (purchase (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND))
     (escrow (map-get? held-funds { transaction-id: transaction-id }))
     ;; Sanitize inputs
     (validated-case-id (begin (try! (validate-non-zero case-id)) case-id))
     (validated-outcome (begin (try! (validate-string-length outcome u512)) outcome))
     (validated-purchaser-refund-percentage (begin (try! (validate-percentage purchaser-refund-percentage)) purchaser-refund-percentage)))
    
    ;; Validate
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED) ;; Only contract owner can resolve disputes
    (asserts! (is-eq (get state dispute) "open") ERR-INVALID-PARAMS)
    
    ;; Update dispute using validated inputs
    (map-set information-disputes
      { case-id: validated-case-id }
      (merge dispute 
        {
          state: "resolved",
          outcome: (some validated-outcome),
          settled-at: (some block-height),
          mediator: (some tx-sender),
          purchaser-refund-percentage: (some validated-purchaser-refund-percentage),
          challenge-deadline: (some (+ block-height u1440))  ;; 10 days to appeal
        }
      )
    )
    
    ;; If escrow exists, resolve based on decision
    (match escrow
      escrow-data (unwrap! (resolve-escrow transaction-id validated-purchaser-refund-percentage) ERR-INVALID-PARAMS)
      true
    )
    
    ;; Update purchase status
    (map-set transactions
      { transaction-id: transaction-id }
      (merge purchase 
        { state: (if (is-eq validated-purchaser-refund-percentage u10000) "revoked" "active") }
      )
    )
    
    ;; Update reputation scores based on outcome using validated input
    (unwrap! (update-reputation-from-dispute
             (get claimant dispute)
             (get defendant dispute)
             validated-purchaser-refund-percentage) ERR-INVALID-PARAMS)
    
    (ok true)
  ))

;; Release escrow funds (after deadline if no disputes)
(define-public (release-escrow (transaction-id uint))
  (let
    ((escrow (unwrap! (map-get? held-funds { transaction-id: transaction-id }) ERR-NOT-FOUND))
     ;; Sanitize input
     (validated-transaction-id (begin (try! (validate-non-zero transaction-id)) transaction-id)))
    
    ;; Validate
    (asserts! (not (get unlocked escrow)) ERR-INVALID-PARAMS)
    (asserts! (not (get contested escrow)) ERR-DISPUTED)
    (asserts! (is-some (get unlock-at escrow)) ERR-INVALID-PARAMS)
    (asserts! (>= block-height (unwrap-panic (get unlock-at escrow))) ERR-INVALID-PARAMS)
    
    ;; Transfer full amount to seller
    (try! (as-contract (stx-transfer? (get sum escrow) tx-sender (get vendor escrow))))
    
    ;; Mark escrow as released using validated input
    (map-set held-funds
      { transaction-id: validated-transaction-id }
      (merge escrow { unlocked: true })
    )
    
    (ok true)
  ))

;; Update a data asset
(define-public (update-data-asset
                (resource-id uint)
                (name (string-utf8 128))
                (details (string-utf8 1024))
                (metadata-location (string-utf8 256))
                (hash-content (buff 64))
                (size-bytes uint))
  (let
    ((asset (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-resource-id (begin (try! (validate-non-zero resource-id)) resource-id))
     (validated-name (begin (try! (validate-string-length name u128)) name))
     (validated-details (begin (try! (validate-string-length details u1024)) details))
     (validated-metadata-location (begin (try! (validate-string-length metadata-location u256)) metadata-location))
     (validated-hash-content (begin (try! (validate-buffer-length hash-content u64)) hash-content))
     (validated-size-bytes (begin (try! (validate-non-zero size-bytes)) size-bytes)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get holder asset)) ERR-UNAUTHORIZED)
    (asserts! (get enabled asset) ERR-INACTIVE)
    
    ;; Update the asset using validated inputs
    (map-set information-assets
      { resource-id: validated-resource-id }
      (merge asset 
        {
          name: validated-name,
          details: validated-details,
          metadata-location: validated-metadata-location,
          hash-content: validated-hash-content,
          size-bytes: validated-size-bytes,
          modified-at: block-height,
          validated: false,  ;; Reset verification on update
          rating-score: none
        }
      )
    )
    
    (ok true)
  ))

;; Read-only functions

;; Get data asset details
(define-read-only (get-data-asset (resource-id uint))
  (ok (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND)))

;; Get license details
(define-read-only (get-license (agreement-id uint))
  (ok (unwrap! (map-get? agreement-types { agreement-id: agreement-id }) ERR-NOT-FOUND)))

;; Get marketplace listing
(define-read-only (get-listing (offer-id uint))
  (ok (unwrap! (map-get? market-listings { offer-id: offer-id }) ERR-NOT-FOUND)))

;; Get purchase details
(define-read-only (get-purchase (transaction-id uint))
  (ok (unwrap! (map-get? transactions { transaction-id: transaction-id }) ERR-NOT-FOUND)))

;; Get validation report
(define-read-only (get-validation-report (resource-id uint) (inspector principal))
  (ok (unwrap! (map-get? assessment-reports { resource-id: resource-id, inspector: inspector }) ERR-NOT-FOUND)))

;; Get user reputation
(define-read-only (get-reputation (account principal))
  (ok (default-to
        {
         vendor-score: u50,
         purchaser-score: u50,
         information-quality-score: u50,
         conflicts-initiated: u0,
         conflicts-lost: u0,
         transaction-count: u0,
         acquisition-count: u0,
         mean-data-quality: u0,
         review-count: u0,
         identity-verified: false
       }
       (map-get? credibility-scores { account: account })
     )
  ))

;; Get validator details
(define-read-only (get-validator (inspector principal))
  (ok (unwrap! (map-get? information-validators { inspector: inspector }) ERR-NOT-FOUND)))

;; Get dispute details
(define-read-only (get-dispute (case-id uint))
  (ok (unwrap! (map-get? information-disputes { case-id: case-id }) ERR-NOT-FOUND)))

;; Get escrow details
(define-read-only (get-escrow (transaction-id uint))
  (ok (unwrap! (map-get? held-funds { transaction-id: transaction-id }) ERR-NOT-FOUND)))

;; Get review details
(define-read-only (get-review (evaluator principal) (resource-id uint))
  (ok (unwrap! (map-get? feedback { evaluator: evaluator, resource-id: resource-id }) ERR-NOT-FOUND)))

;; Get access log
(define-read-only (get-access-log (transaction-id uint) (entry-id uint))
  (ok (unwrap! (map-get? usage-logs { transaction-id: transaction-id, entry-id: entry-id }) ERR-NOT-FOUND)))

;; Check if a user has access to a specific data asset
(define-read-only (has-data-access (account principal) (resource-id uint))
  ;; This would check for active purchases by the user for the asset
  ;; Simplified implementation
  (ok false))

;; Get platform configuration
(define-read-only (get-platform-config)
  (ok {
    service-fee-percentage: (var-get service-fee-percentage),
    payment-recipient: (var-get payment-recipient),
    conflict-resolution-fee: (var-get conflict-resolution-fee),
    standard-deposit-period: (var-get standard-deposit-period),
    min-credibility-for-listing: (var-get min-credibility-for-listing)
  }))

;; Admin functions (only contract owner)

;; Update platform fee
(define-public (set-platform-fee (new-fee uint))
  (let
    ((validated-new-fee (begin (try! (validate-uint-range new-fee u0 u1000)) new-fee)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set service-fee-percentage validated-new-fee)
    (ok true)
  ))

;; Update fee recipient
(define-public (set-fee-recipient (new-recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set payment-recipient new-recipient)
    (ok true)
  ))

;; Update dispute resolution fee
(define-public (set-dispute-fee (new-fee uint))
  (let
    ((validated-new-fee (begin (try! (validate-non-zero new-fee)) new-fee)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set conflict-resolution-fee validated-new-fee)
    (ok true)
  ))

;; Deactivate a data asset (emergency function)
(define-public (deactivate-asset (resource-id uint))
  (let
    ((asset (unwrap! (map-get? information-assets { resource-id: resource-id }) ERR-NOT-FOUND))
     (validated-resource-id (begin (try! (validate-non-zero resource-id)) resource-id)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    (map-set information-assets
      { resource-id: validated-resource-id }
      (merge asset { enabled: false })
    )
    
    (ok true)
  ))

;; Deactivate a validator (emergency function)
(define-public (deactivate-validator (inspector principal))
  (let
    ((validator-data (unwrap! (map-get? information-validators { inspector: inspector }) ERR-NOT-FOUND)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    (map-set information-validators
      { inspector: inspector }
      (merge validator-data { enabled: false })
    )
    
    (ok true)
  ))