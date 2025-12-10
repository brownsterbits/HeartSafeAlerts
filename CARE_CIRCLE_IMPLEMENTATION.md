# Care Circle Implementation Plan

**Last Updated:** 2025-12-08
**Status:** Planning Phase - Refined
**Target Version:** v3.0 (Care Circle MVP)
**Estimated Timeline:** 4-6 weeks

---

## Executive Summary

Care Circle is HeartSafeAlerts' premium subscription feature ($2.99/month or $19.99/year) that allows users to add trusted contacts who receive automatic SMS alerts when heart rate issues occur. This is the core differentiator from Apple's built-in monitoring.

### Core Philosophy

1. **Zero Friction** - Circle members do NOT need to download the app
2. **Just Works** - Minimal configuration, sensible defaults
3. **Ship Fast, Learn Fast** - Thin MVP first, iterate based on feedback

### Business Model (Simplified)

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | All monitoring features (Bluetooth, Apple Watch, alerts, thresholds) |
| Care Circle | $2.99/mo or $19.99/yr | SMS escalation to trusted contacts |

No "Pro" tier. Free is generous. Care Circle is the only premium feature.

---

## MVP Strategy: Two-Phase Approach

### v3.0a - "Outbound Only" (4 weeks) - SHIP THIS FIRST

The core value proposition:
> "If something's wrong and I don't respond, my loved one gets a text."

| Include | Exclude (defer to v3.0b) |
|---------|--------------------------|
| Sign in with Apple | Inbound SMS acceptance flow (YES/STOP) |
| StoreKit 2 subscription | Status web page |
| Add up to 3 circle members | Weekly summaries |
| Contact picker + phone/name storage | 5 member limit |
| Outbound SMS alerts only | Rich member management |
| 2-min escalation + "I'm Okay" / "I Need Help" | Alert history view |
| Basic paywall | |

**Members are "active" immediately when added** - no acceptance flow needed for MVP. They can reply STOP to any alert SMS to opt out (Twilio handles this automatically).

### v3.0b - "Full Experience" (2-3 weeks after v3.0a feedback)

- Inbound SMS acceptance flow (YES/STOP on invitation)
- Status web page with random public token
- Up to 5 members
- Member status tracking (pending/active/declined)
- Quiet hours (maybe)
- Weekly summaries (maybe)

---

## User Journey (v3.0a MVP)

### Primary User (App Owner)

```
1. User has free HeartSafeAlerts, monitoring works great
2. User sees Care Circle teaser in Settings
3. User taps "Care Circle" → Subscription paywall
4. User subscribes ($2.99/month or $19.99/year)
5. User taps "Add to Circle" → Contact picker
6. User selects contact → Sees phone number + name
7. User confirms → Member saved locally + Firestore
8. (No SMS sent yet - member is immediately "active")
9. Later: User's heart rate spikes, alert triggers
10. AlertEscalationView appears with 2-minute countdown
11. User doesn't respond in time (or taps "I Need Help")
12. SMS sent: "HeartSafe Alert: Chad's heart rate is 142 BPM (high).
    Please check on him. Call: (555) 123-4567"
```

### Circle Member (No App Required)

```
1. First contact: Receives alert SMS when something's wrong
2. SMS includes owner's phone number to call
3. Can reply STOP to any SMS to opt out (Twilio automatic)
4. That's it - no app, no account, no web page (for MVP)
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     HeartSafeAlerts App                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AlertManager.checkHeartRate()                                  │
│       │                                                         │
│       ▼                                                         │
│  EscalationManager.startEscalation()                           │
│       │                                                         │
│       ├──► Show AlertEscalationView (2-min countdown)          │
│       │         │                                               │
│       │         ├── [I'm Okay] → Cancel, notify circle "all ok" │
│       │         │                                               │
│       │         └── [I Need Help] → Confirm → Immediate SMS     │
│       │                  │                                      │
│       │                  └── (3-sec undo option)                │
│       │                                                         │
│       └──► (2 min timeout, no response) → Send SMS to circle   │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│  Firebase Cloud Function (sendAlertToCircle)                   │
│       │                                                         │
│       ▼                                                         │
│  Twilio SMS to all circle members                              │
│                                                                 │
│  "HeartSafe Alert: Chad's HR is 142 BPM (high).                │
│   Please check on him. Call: (555) 123-4567                    │
│   Reply STOP to opt out."                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technical Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Authentication | Sign in with Apple | No passwords, trusted, Apple requirement |
| Database | Firebase Firestore | Real-time sync, scales automatically |
| Cloud Functions | Firebase Functions (TypeScript) | Serverless, integrates with Firestore |
| SMS | Twilio | Reliable, handles STOP automatically, reasonable pricing |
| Subscriptions | StoreKit 2 | Modern API, server-side validation |
| Status Page | Firebase Hosting | v3.0b - deferred |

---

## Data Model (Firestore) - Nested Structure

Nesting under users simplifies security rules dramatically.

```
firestore/
└── users/{userId}
    ├── appleUserId: string
    ├── displayName: string
    ├── email: string (optional, from Apple)
    ├── phone: string (required for Care Circle - callback number)
    ├── subscriptionStatus: "none" | "active" | "expired" | "grace_period"
    ├── subscriptionProductId: string
    ├── subscriptionExpiry: timestamp
    ├── createdAt: timestamp
    ├── updatedAt: timestamp
    │
    ├── circle/ (subcollection)
    │   └── members/{memberId}
    │       ├── phone: string (E.164 format: +15551234567)
    │       ├── name: string (from contacts)
    │       ├── addedAt: timestamp
    │       └── lastAlertSentAt: timestamp (optional)
    │
    └── alerts/{alertId} (subcollection)
        ├── bpm: number
        ├── alertType: "high" | "low"
        ├── thresholdValue: number
        ├── triggeredAt: timestamp
        ├── status: "pending" | "acknowledged" | "escalated" | "resolved"
        ├── acknowledgedAt: timestamp (optional)
        ├── acknowledgedWith: "im_okay" | "need_help" (optional)
        ├── escalatedAt: timestamp (optional)
        ├── resolvedAt: timestamp (optional)
        ├── resolvedBy: "user" | "timeout" | "hr_normalized"
        ├── notifiedPhones: [string] (phones that received SMS)
        └── publicToken: string (random, for v3.0b status page)
```

---

## Security Rules (Firestore) - Simplified with Nesting

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Circle members - user owns all their members
      match /circle/members/{memberId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Alerts - user owns all their alerts
      match /alerts/{alertId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

Much simpler than the original flat structure - no `get()` calls needed.

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)

**Goal:** Firebase + Auth + Subscription infrastructure

#### Tasks

- [ ] Create Firebase project: `heartsafe-alerts`
- [ ] Add Firebase SDK via Swift Package Manager
- [ ] Enable Authentication with Sign in with Apple
- [ ] Configure Firestore with nested data model
- [ ] Deploy security rules
- [ ] Set up Firebase Functions project (TypeScript)
- [ ] Create Twilio account, get phone number
- [ ] Implement `SubscriptionManager.swift` (StoreKit 2)
- [ ] Create `Configuration.storekit` for testing
- [ ] Implement `FirebaseManager.swift` (Auth + Firestore)
- [ ] Add feature flag: `FeatureFlags.careCircleEnabled`

#### Files to Create

```
HeartSafeAlerts/
├── Managers/
│   ├── FirebaseManager.swift      # Auth + Firestore wrapper
│   └── SubscriptionManager.swift  # StoreKit 2 implementation
├── Utilities/
│   └── FeatureFlags.swift         # Feature flag enum
├── GoogleService-Info.plist       # Firebase config (from console)
└── Configuration.storekit         # StoreKit testing

firebase-functions/
├── src/
│   ├── index.ts                   # Function exports
│   └── config.ts                  # Twilio credentials (from env)
├── package.json
├── tsconfig.json
└── .env.example                   # Environment template
```

#### Subscription Products

| Product ID | Price | Description |
|------------|-------|-------------|
| `com.brownster.HeartSafeAlerts.carecircle.monthly` | $2.99/month | Care Circle Monthly |
| `com.brownster.HeartSafeAlerts.carecircle.annual` | $19.99/year | Care Circle Annual (save 44%) |

---

### Phase 2: Circle Management + Escalation (Week 3-4)

**Goal:** Add members, build escalation UI, send SMS alerts

#### Tasks

- [ ] Create `CareCircleManager.swift` for member CRUD
- [ ] Build `CareCircleView.swift` (main screen)
- [ ] Build `AddMemberView.swift` with contact picker
- [ ] Build `MemberRowView.swift` for list display
- [ ] Build `CareCirclePaywallView.swift`
- [ ] Create `EscalationManager.swift` (timer + state)
- [ ] Build `AlertEscalationView.swift` (full-screen alert)
- [ ] Add "I Need Help" confirmation (3-sec undo)
- [ ] Hook escalation into `AlertManager.checkHeartRate()`
- [ ] Implement `sendAlertToCircle` Cloud Function (Twilio)
- [ ] Add escalation cooldown (no SMS spam)
- [ ] Add auto-cancel if HR normalizes during countdown
- [ ] Add "Not 911" disclaimer to UI

#### Files to Create

```
HeartSafeAlerts/
├── Managers/
│   ├── CareCircleManager.swift    # Member CRUD
│   └── EscalationManager.swift    # Timer, escalation logic
├── Views/CareCircle/
│   ├── CareCircleView.swift       # Main circle screen
│   ├── AddMemberView.swift        # Contact picker
│   ├── MemberRowView.swift        # Member list item
│   ├── AlertEscalationView.swift  # Full-screen alert
│   └── CareCirclePaywallView.swift # Subscription paywall
└── Models/
    ├── CircleMember.swift         # Member model
    └── AlertEvent.swift           # Alert model

firebase-functions/
└── src/
    └── alerts.ts                  # sendAlertToCircle
```

#### SMS Templates

**Alert Escalation (no response after 2 min):**
```
HeartSafe Alert: [Name]'s heart rate is [BPM] BPM ([high/low]).
They haven't responded. Please check on them.

Call: [Phone]
Reply STOP to opt out.
```

**Urgent (user pressed "I Need Help"):**
```
URGENT: [Name] pressed "I Need Help" in HeartSafe.
Heart rate: [BPM] BPM

Call immediately: [Phone]
Reply STOP to opt out.
```

**All Clear (user pressed "I'm Okay"):**
```
HeartSafe: [Name] responded "I'm okay" to their heart rate alert.
No action needed.
```

#### Escalation Logic

| Event | Action |
|-------|--------|
| HR out of range | Show AlertEscalationView, start 2-min timer |
| User taps "I'm Okay" | Cancel timer, SMS "all clear" to circle |
| User taps "I Need Help" | Show 3-sec undo, then immediate SMS |
| Timer expires (2 min) | SMS to circle |
| HR normalizes during countdown | Auto-cancel, show "HR back to normal" |
| Second alert within 10 min | Don't re-escalate (cooldown) |

---

### Phase 3: Polish & Ship (Week 5-6)

**Goal:** TestFlight, edge cases, App Store submission

#### Tasks

- [ ] Implement subscription restore flow
- [ ] Handle subscription expiry gracefully (disable Care Circle, keep members)
- [ ] Add "Manage Subscription" link
- [ ] Graceful degradation if Firebase/Twilio fails
- [ ] Update Privacy Policy (data collection disclosure)
- [ ] Update Terms of Service (subscription terms)
- [ ] Add "Not a medical device / Not 911" disclaimers throughout
- [ ] TestFlight beta testing
- [ ] Fix bugs from testing
- [ ] App Store submission (v3.0)

#### Disclaimer Text (use consistently)

```
Care Circle is not a substitute for emergency services.
If you believe you're experiencing a medical emergency, call 911.
```

Place in:
- AlertEscalationView (near "I Need Help" button)
- CareCircleView (footer)
- Settings → About
- App Store description

---

## UI Mockups

### Care Circle Management (v3.0a - simplified)

```
┌─────────────────────────────────────────┐
│  ←  Care Circle                         │
├─────────────────────────────────────────┤
│                                         │
│  Your circle members receive text       │
│  alerts when your heart rate needs      │
│  attention and you don't respond.       │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  👤 Sara Johnson                        │
│     +1 (555) 123-4567                   │
│                              [Remove]   │
│                                         │
│  👤 Mike Brown                          │
│     +1 (555) 987-6543                   │
│                              [Remove]   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     + Add Circle Member         │    │
│  └─────────────────────────────────┘    │
│                                         │
│  2 of 3 members                         │
│                                         │
│  ─────────────────────────────────────  │
│  ⚠️ Care Circle is not a substitute     │
│  for emergency services. If you're      │
│  having an emergency, call 911.         │
│                                         │
└─────────────────────────────────────────┘
```

### Alert Escalation View

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│              ❤️  142                    │
│                BPM                      │
│                                         │
│         Heart rate is HIGH              │
│       (above 100 BPM threshold)         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│     Your Care Circle will be            │
│     notified in 1:45                    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │          I'M OKAY               │    │
│  │       (Dismiss Alert)           │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │         I NEED HELP             │    │
│  │     (Notify Circle Now)         │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ⚠️ This is not 911. If you're having   │
│  an emergency, call emergency services. │
│                                         │
└─────────────────────────────────────────┘
```

### Paywall

```
┌─────────────────────────────────────────┐
│                                    ✕    │
│                                         │
│        👨‍👩‍👧‍👦                            │
│                                         │
│         Care Circle                     │
│                                         │
│   Keep your loved ones in the loop      │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ✓ Add up to 3 trusted contacts         │
│                                         │
│  ✓ Automatic SMS alert escalation       │
│                                         │
│  ✓ "I'm okay" check-in workflow         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  $19.99/year                    │    │
│  │  Best Value - Save 44%     ⭐   │    │
│  │  Just $1.67/month               │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  $2.99/month                    │    │
│  │  Cancel anytime                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [Restore Purchases]                    │
│                                         │
│  Billed through Apple. Cancel anytime   │
│  in Settings → Subscriptions.           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Cost Estimates

| Service | Free Tier | Est. Monthly Cost (1,000 users) |
|---------|-----------|--------------------------------|
| Firebase Auth | 50K MAU | $0 |
| Firebase Firestore | 1GB, 50K reads/day | ~$5-10 |
| Firebase Functions | 2M invocations | ~$0-5 |
| Twilio SMS | - | ~$20-40 (@ $0.0079/SMS) |
| **Total** | - | **~$25-55/month** |

**Break-even:** ~17-22 premium subscribers at $2.99/month

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| SMS costs spike | Rate limit: max 10 escalations/day, 10-min cooldown between alerts |
| Twilio delivery fails | Retry logic, log failures, show user "SMS may not have sent" |
| Accidental "I Need Help" | 3-second undo snackbar before sending |
| Circle member annoyed | STOP in every SMS (Twilio handles automatically) |
| HR normalizes during countdown | Auto-cancel escalation, notify user |
| Firebase offline | Graceful degradation - local alerts still work |
| Apple rejects | Clear disclaimers, follow guidelines, no medical claims |

---

## Feature Flags

```swift
enum FeatureFlags {
    /// Enable/disable Care Circle feature entirely
    static let careCircleEnabled = true

    /// Maximum circle members (increase in v3.0b)
    static let maxCircleMembers = 3

    /// Escalation countdown duration in seconds
    static let escalationCountdown: TimeInterval = 120

    /// Cooldown between escalations (prevent spam)
    static let escalationCooldown: TimeInterval = 600 // 10 minutes
}
```

---

## SMS Compliance Notes

1. **Every SMS includes "Reply STOP to opt out"** - Twilio handles opt-out automatically
2. **Flexible reply matching** - Handle `yes`, `Yes`, `Y`, `OK` (for v3.0b acceptance flow)
3. **A2P 10DLC** - May need brand registration for US SMS at scale; Twilio toll-free works initially
4. **HELP response** - Consider adding in v3.0b

---

## Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Phone number required? | Yes - required for Care Circle setup (callback number) |
| Quiet hours? | Defer to v3.1 |
| Weekly summaries? | Defer to v3.1 |
| Multiple circles? | Yes - a person can be in multiple people's circles |
| International SMS? | Yes - Twilio handles, costs more |
| Invitation acceptance flow? | Defer to v3.0b - MVP has immediate activation |
| Status web page? | Defer to v3.0b |

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Free → Premium conversion | 5-10% |
| Alert acknowledgment < 2 min | 80%+ |
| 90-day subscriber retention | 70%+ |
| Refund rate | <3% |
| App Store rating | Maintain 4.5+ |

---

## Testing Plan

### Unit Tests
- [ ] SubscriptionManager purchase/restore flow
- [ ] CareCircleManager member CRUD
- [ ] EscalationManager timer and state transitions
- [ ] Feature flag behavior

### Integration Tests
- [ ] Sign in with Apple → Firestore user creation
- [ ] Add member → Firestore write
- [ ] Alert → Timer → Escalation → Cloud Function → SMS

### Manual Testing (TestFlight)
- [ ] Full flow: Subscribe → Add member → Trigger alert → Escalate
- [ ] Edge cases: Airplane mode, app killed, subscription expired
- [ ] "I Need Help" with undo
- [ ] HR normalizes during countdown
- [ ] Circle member receives SMS, can call back

### Device Testing
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 16 (standard)
- [ ] iPhone 16 Pro Max (largest)
- [ ] Dark mode
- [ ] Dynamic Type (accessibility)

---

## Dependencies

### External Services
- [ ] Firebase project (free tier) - create at console.firebase.google.com
- [ ] Twilio account (pay-as-you-go) - get phone number
- [ ] Apple Developer (already have)

### App Store Requirements
- [ ] Privacy Policy update (data collection for Care Circle)
- [ ] Terms of Service update (subscription terms)
- [ ] App Store description update
- [ ] New screenshots showing Care Circle

---

## File Summary

### New Swift Files (v3.0a)

| File | Purpose |
|------|---------|
| `FeatureFlags.swift` | Feature flags and constants |
| `FirebaseManager.swift` | Auth + Firestore operations |
| `SubscriptionManager.swift` | StoreKit 2 subscriptions |
| `CareCircleManager.swift` | Circle member CRUD |
| `EscalationManager.swift` | Alert escalation timer/logic |
| `CareCircleView.swift` | Main circle management |
| `AddMemberView.swift` | Contact picker + confirmation |
| `MemberRowView.swift` | Circle member list item |
| `AlertEscalationView.swift` | Full-screen alert with countdown |
| `CareCirclePaywallView.swift` | Subscription paywall |
| `CircleMember.swift` | Member data model |
| `AlertEvent.swift` | Alert event data model |

### Firebase Cloud Functions (v3.0a)

| Function | Trigger | Purpose |
|----------|---------|---------|
| `sendAlertToCircle` | HTTP (called from app) | Send SMS via Twilio |

### Deferred to v3.0b

| Component | Notes |
|-----------|-------|
| `processInviteReply` function | Inbound SMS webhook |
| `sendInviteSMS` function | Invitation SMS |
| Status web page | Firebase Hosting |
| Member acceptance flow | YES/STOP handling |

---

## Next Steps

1. ✅ Review and refine this plan
2. Set up Firebase project and Twilio account
3. Begin Phase 1 implementation

---

**Document Owner:** Chad Brown
**Last Review:** 2025-12-08
**Version:** 3.0 Planning
