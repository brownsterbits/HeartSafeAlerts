# Care Circle Implementation Plan

**Last Updated:** 2025-12-08
**Status:** Planning Phase
**Target Version:** v2.1 (Care Circle MVP)
**Estimated Timeline:** 6-8 weeks

---

## Executive Summary

Care Circle is HeartSafeAlerts' premium subscription feature ($2.99/month or $19.99/year) that allows users to add trusted contacts who receive automatic alerts when heart rate issues occur. This is the core differentiator from Apple's built-in monitoring.

**Core Philosophy: Zero Friction**

The most critical design decision: **Circle members do NOT need to download the app.** They receive SMS alerts and can view status on a simple web page. This removes the biggest barrier to adoption.

---

## User Journeys

### Primary User (App Owner)

```
1. User has free HeartSafeAlerts installed, monitoring works
2. User sees Care Circle teaser in Settings
3. User taps "Care Circle" → Subscription paywall
4. User subscribes ($2.99/month or $19.99/year)
5. User taps "Add to Circle" → Contact picker
6. User selects mom's contact → Confirmation screen
7. User confirms → SMS invitation sent to mom
8. Mom replies YES → Mom is now in the circle
9. Later: User's heart rate spikes
10. Alert UI appears with 2-minute countdown
11. User doesn't respond in time
12. Mom receives SMS: "HeartSafe Alert: [Name]'s heart rate is high (142 BPM). Please check on them."
```

### Circle Member (No App Required)

```
1. Receives SMS: "[Name] added you to their HeartSafe Care Circle. Reply YES to accept."
2. Replies YES
3. Done - no app download, no account creation
4. Later: Receives alert SMS with link to status page
5. Taps link → Simple web page showing:
   - Current alert status
   - "I reached them" / "I couldn't reach them" buttons
   - Phone number to call
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        HeartSafeAlerts App                      │
├─────────────────────────────────────────────────────────────────┤
│  AlertManager.checkHeartRate()                                  │
│       │                                                         │
│       ▼                                                         │
│  EscalationManager.startEscalation()                           │
│       │                                                         │
│       ├──► Show AlertEscalationView (2-min countdown)          │
│       │         │                                               │
│       │         ├── [I'm Okay] → Cancel escalation             │
│       │         └── [I Need Help] → Immediate escalation       │
│       │                                                         │
│       └──► (2 min timeout) → Escalate to Care Circle           │
│                   │                                             │
│                   ▼                                             │
│            Firebase Cloud Function                              │
│                   │                                             │
│                   ▼                                             │
│            Twilio SMS to all active circle members              │
│                   │                                             │
│                   ▼                                             │
│            "HeartSafe Alert: [Name]'s HR is 142 BPM.           │
│             Status: heartsafe.io/s/abc123"                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technical Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Authentication | Sign in with Apple | No passwords, trusted, Apple requirement |
| Database | Firebase Firestore | Real-time sync, scales automatically |
| Cloud Functions | Firebase Functions | Serverless, integrates with Firestore |
| SMS | Twilio | Reliable, good API, reasonable pricing |
| Subscriptions | StoreKit 2 | Modern API, server-side validation |
| Status Page | Firebase Hosting | Free tier generous, simple deployment |

---

## Data Model (Firestore)

```
firestore/
├── users/{userId}
│   ├── appleUserId: string
│   ├── displayName: string
│   ├── email: string (optional, from Apple)
│   ├── phone: string (for caller ID on alerts)
│   ├── subscriptionStatus: "none" | "active" | "expired" | "grace_period"
│   ├── subscriptionProductId: string
│   ├── subscriptionExpiry: timestamp
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── circles/{circleId}
│   ├── ownerId: string (userId)
│   ├── ownerName: string (display name for SMS)
│   ├── ownerPhone: string (for circle members to call back)
│   ├── createdAt: timestamp
│   └── memberCount: number (denormalized for queries)
│
├── members/{memberId}
│   ├── circleId: string
│   ├── phone: string (E.164 format: +15551234567)
│   ├── name: string (from contacts)
│   ├── status: "pending" | "active" | "declined" | "removed"
│   ├── invitedAt: timestamp
│   ├── acceptedAt: timestamp (optional)
│   ├── declinedAt: timestamp (optional)
│   └── lastAlertSentAt: timestamp (optional)
│
└── alerts/{alertId}
    ├── circleId: string
    ├── userId: string
    ├── bpm: number
    ├── alertType: "high" | "low"
    ├── thresholdValue: number (the threshold that was exceeded)
    ├── triggeredAt: timestamp
    ├── status: "pending" | "acknowledged" | "escalated" | "resolved"
    ├── acknowledgedAt: timestamp (optional)
    ├── acknowledgedWith: "im_okay" | "need_help" (optional)
    ├── escalatedAt: timestamp (optional)
    ├── resolvedAt: timestamp (optional)
    ├── resolvedBy: "user" | "circle_member" | "timeout"
    └── notifiedMembers: [string] (member IDs who were notified)
```

---

## Implementation Phases

### Phase 1: Backend Foundation (Week 1-2)

**Goal:** Firebase project setup, authentication, subscription infrastructure

#### Tasks

- [ ] Create Firebase project: `heartsafe-alerts`
- [ ] Enable Authentication with Sign in with Apple
- [ ] Configure Firestore database with security rules
- [ ] Set up Firebase Functions project (TypeScript)
- [ ] Create Twilio account and configure SMS
- [ ] Implement StoreKit 2 subscription manager
- [ ] Create StoreKit configuration file for testing

#### Files to Create

```
HeartSafeAlerts/
├── Managers/
│   ├── FirebaseManager.swift      # Auth + Firestore wrapper
│   └── SubscriptionManager.swift  # StoreKit 2 implementation
├── GoogleService-Info.plist       # Firebase configuration
└── Configuration.storekit         # StoreKit testing config

firebase-functions/
├── src/
│   ├── index.ts                   # Function exports
│   └── subscriptions.ts           # App Store webhook handler
├── package.json
└── tsconfig.json
```

#### Subscription Products

| Product ID | Price | Description |
|------------|-------|-------------|
| `com.brownster.HeartSafeAlerts.carecircle.monthly` | $2.99/month | Care Circle Monthly |
| `com.brownster.HeartSafeAlerts.carecircle.annual` | $19.99/year | Care Circle Annual (save 44%) |

#### Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Circles: owner can read/write
    match /circles/{circleId} {
      allow read, write: if request.auth != null &&
        resource.data.ownerId == request.auth.uid;
      allow create: if request.auth != null;
    }

    // Members: circle owner can manage
    match /members/{memberId} {
      allow read, write: if request.auth != null &&
        get(/databases/$(database)/documents/circles/$(resource.data.circleId)).data.ownerId == request.auth.uid;
    }

    // Alerts: circle owner can read/write, cloud functions can write
    match /alerts/{alertId} {
      allow read: if request.auth != null &&
        resource.data.userId == request.auth.uid;
      allow write: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }
  }
}
```

---

### Phase 2: Circle Member Management (Week 3-4)

**Goal:** Add/remove circle members with SMS invitations

#### Tasks

- [ ] Create CareCircleManager for member CRUD operations
- [ ] Build CareCircleView (main circle management screen)
- [ ] Build AddMemberView with native contact picker
- [ ] Implement invitation Cloud Function (Twilio SMS)
- [ ] Implement webhook for inbound SMS replies
- [ ] Handle member acceptance/decline flow
- [ ] Build MemberRowView for member list display

#### Files to Create

```
HeartSafeAlerts/
├── Managers/
│   └── CareCircleManager.swift    # Member CRUD, invitation logic
├── Views/CareCircle/
│   ├── CareCircleView.swift       # Main circle management
│   ├── AddMemberView.swift        # Contact picker + confirmation
│   ├── MemberRowView.swift        # Individual member display
│   └── CareCirclePaywallView.swift # Subscription paywall
└── Models/
    └── CircleMember.swift         # Member data model

firebase-functions/
└── src/
    └── invitations.ts             # sendInviteSMS, processReply
```

#### SMS Templates

**Invitation (Outbound):**
```
Hi! [OwnerName] added you to their HeartSafe Care Circle.
You'll get text alerts if their heart rate needs attention.

Reply YES to accept or STOP to decline.
```

**Acceptance Confirmation (Outbound):**
```
You're now in [OwnerName]'s Care Circle. You'll receive
alerts if their heart rate goes outside their target range.

Reply STOP anytime to leave the circle.
```

**Decline Confirmation (Outbound):**
```
Got it. You won't receive alerts from [OwnerName]'s Care Circle.
```

#### UI Mockups

**Circle Management Screen:**
```
┌─────────────────────────────────────────┐
│  ←  Care Circle                    ⚙️   │
├─────────────────────────────────────────┤
│                                         │
│  Your circle members receive text       │
│  alerts when your heart rate needs      │
│  attention.                             │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  👤 Sara Johnson              ✓ Active  │
│     +1 (555) 123-4567                   │
│     Added Jan 15, 2025                  │
│                                    [⋮]  │
│                                         │
│  👤 Mike Brown               ⏳ Pending │
│     +1 (555) 987-6543                   │
│     Invited Jan 16, 2025               │
│                         [Resend] [⋮]    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     + Add Circle Member         │    │
│  └─────────────────────────────────┘    │
│                                         │
│  2 of 5 members                         │
│                                         │
└─────────────────────────────────────────┘
```

---

### Phase 3: Alert Escalation System (Week 5-6)

**Goal:** When alerts fire, give user time to respond, then notify circle

#### Tasks

- [ ] Create EscalationManager for timer and state management
- [ ] Build AlertEscalationView (full-screen alert UI)
- [ ] Hook EscalationManager into AlertManager.checkHeartRate()
- [ ] Implement "I'm Okay" flow (cancel escalation, notify circle)
- [ ] Implement "I Need Help" flow (immediate escalation)
- [ ] Implement timeout escalation (2 minutes, no response)
- [ ] Create sendAlertToCircle Cloud Function
- [ ] Build status web page for circle members

#### Files to Create

```
HeartSafeAlerts/
├── Managers/
│   └── EscalationManager.swift    # Timer, Firebase sync, escalation logic
├── Views/CareCircle/
│   └── AlertEscalationView.swift  # Full-screen alert with countdown
└── Models/
    └── AlertEvent.swift           # Alert history model

firebase-functions/
└── src/
    └── alerts.ts                  # sendAlertToCircle

heartsafe-status/ (Firebase Hosting)
├── index.html                     # Landing page
├── status.html                    # Dynamic status page
├── css/
│   └── style.css
└── js/
    └── status.js                  # Firestore listener for real-time updates
```

#### Escalation Timing

| Event | Time | Action |
|-------|------|--------|
| Heart rate alert triggered | 0:00 | Show AlertEscalationView, start 2-min timer |
| User taps "I'm Okay" | Any | Cancel timer, update Firestore, SMS circle "All clear" |
| User taps "I Need Help" | Any | Immediate escalation, SMS circle "URGENT" |
| Timer expires | 2:00 | Escalate, SMS circle with concern |
| No further alerts | 30:00 | Auto-resolve if heart rate normalized |

#### Alert SMS Templates

**Standard Escalation (no response after 2 min):**
```
HeartSafe Alert: [OwnerName]'s heart rate is [BPM] BPM ([high/low]).
They haven't responded. Please check on them.

Call: [OwnerPhone]
Status: heartsafe.io/s/[alertId]
```

**Urgent Escalation (user pressed "I Need Help"):**
```
URGENT HeartSafe Alert: [OwnerName] pressed "I Need Help"
Heart rate: [BPM] BPM

Call immediately: [OwnerPhone]
Status: heartsafe.io/s/[alertId]
```

**All Clear (user pressed "I'm Okay"):**
```
HeartSafe Update: [OwnerName] responded "I'm okay"
to their heart rate alert. No action needed.
```

#### Alert Escalation UI

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
│                                         │
└─────────────────────────────────────────┘
```

#### Status Web Page

**URL:** `heartsafe.io/s/{alertId}`

```html
┌─────────────────────────────────────────┐
│         HeartSafe Alert Status          │
├─────────────────────────────────────────┤
│                                         │
│  👤 Mom                                 │
│                                         │
│  ❤️ Heart rate: 142 BPM                 │
│     Status: HIGH (above 100 BPM)        │
│                                         │
│  🕐 Alert: 3 minutes ago                │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Current Status:                        │
│  ⚠️ AWAITING RESPONSE                   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  📞 Call Mom: +1 (555) 123-4567         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Update status:                         │
│                                         │
│  [I reached them - they're OK]          │
│                                         │
│  [I couldn't reach them]                │
│                                         │
└─────────────────────────────────────────┘
```

---

### Phase 4: Subscription Paywall & Polish (Week 7-8)

**Goal:** Convert free users to premium, polish the experience

#### Tasks

- [ ] Build CareCirclePaywallView with both pricing options
- [ ] Implement paywall trigger points (Settings, Add Member)
- [ ] Add subscription status to Settings UI
- [ ] Implement restore purchases flow
- [ ] Add "Manage Subscription" link to Apple settings
- [ ] Handle subscription expiry gracefully
- [ ] Add alert history view (optional, time permitting)
- [ ] TestFlight testing with real users
- [ ] App Store submission preparation

#### Paywall Design

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
│  ✓ Add up to 5 trusted contacts         │
│                                         │
│  ✓ Automatic SMS alert escalation       │
│                                         │
│  ✓ "I'm okay" check-in workflow         │
│                                         │
│  ✓ Real-time status page for family     │
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
│  Subscriptions are billed through       │
│  Apple and can be cancelled anytime     │
│  in Settings → Subscriptions.           │
│                                         │
└─────────────────────────────────────────┘
```

---

## Cost Estimates

| Service | Free Tier | Estimated Monthly Cost (1,000 users) |
|---------|-----------|-------------------------------------|
| Firebase Authentication | 50K MAU | $0 |
| Firebase Firestore | 1GB storage, 50K reads/day | ~$5-10 |
| Firebase Functions | 2M invocations/month | ~$0-5 |
| Firebase Hosting | 10GB/month | $0 |
| Twilio SMS | - | ~$25-50 (@ $0.0079/SMS, ~5 SMS/user/mo) |
| **Total** | - | **~$30-65/month** |

**Break-even:** ~22 premium subscribers at $2.99/month

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SMS costs spike from alert spam | Medium | High | Rate limit: max 10 escalations/day per user |
| Twilio delivery failures | Low | High | Retry logic, show delivery status in app |
| Circle member annoyed by alerts | Medium | Medium | Easy opt-out (reply STOP), quiet hours |
| User forgets to dismiss alerts | High | Low | Auto-resolve after 30 min if HR normalized |
| Subscription churn | Medium | Medium | Annual discount (44%), valuable feature |
| Apple rejects subscription | Low | High | Follow guidelines, clear value proposition |

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Free → Premium conversion | 5-10% | (Premium users / Total users) |
| Circle member acceptance rate | 70%+ | (Accepted / Invited) |
| Alert acknowledgment < 2 min | 80%+ | (Acknowledged / Total alerts) |
| 90-day subscriber retention | 70%+ | Cohort analysis |
| Refund rate | <3% | App Store Connect |
| App Store rating | 4.5+ | Maintain or improve |

---

## Testing Plan

### Unit Tests
- [ ] SubscriptionManager purchase flow
- [ ] CareCircleManager member CRUD
- [ ] EscalationManager timer logic
- [ ] Alert status state machine

### Integration Tests
- [ ] Sign in with Apple → Firestore user creation
- [ ] Add member → SMS sent → Reply processed → Member active
- [ ] Alert triggered → Timer → Escalation → SMS sent

### Manual Testing (TestFlight)
- [ ] Full flow: Subscribe → Add member → Trigger alert → Escalate
- [ ] Edge cases: Airplane mode, app killed, subscription expired
- [ ] Circle member experience: SMS clarity, status page usability

### Device Testing
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 16 (standard)
- [ ] iPhone 16 Pro Max (largest)
- [ ] Dark mode
- [ ] Dynamic Type (accessibility)

---

## Open Questions

1. **Phone number for user:** Do we require the user to provide their phone number so circle members can call them back? (Recommendation: Yes, required for Care Circle setup)

2. **Quiet hours:** Should circle members be able to set quiet hours (no alerts 11pm-7am)? (Recommendation: v2.2 feature, not MVP)

3. **Weekly summaries:** Include in MVP or defer? (Recommendation: Defer to v2.2)

4. **Multiple circles:** Can a user be in multiple people's circles? (Recommendation: Yes, no limit for circle members)

5. **International SMS:** Support international phone numbers? (Recommendation: Yes, Twilio handles this, just costs more)

---

## Dependencies

### External Services (Need Accounts)
- [ ] Firebase project (free tier)
- [ ] Twilio account (pay-as-you-go)
- [ ] Apple Developer (already have)

### App Store Requirements
- [ ] Privacy Policy update (data collection for Care Circle)
- [ ] Terms of Service update (subscription terms)
- [ ] App Store description update
- [ ] New screenshots showing Care Circle

---

## File Summary

### New Swift Files

| File | Purpose |
|------|---------|
| `FirebaseManager.swift` | Authentication and Firestore operations |
| `SubscriptionManager.swift` | StoreKit 2 subscription handling |
| `CareCircleManager.swift` | Circle member CRUD and invitations |
| `EscalationManager.swift` | Alert escalation timer and logic |
| `CareCircleView.swift` | Main circle management screen |
| `AddMemberView.swift` | Contact picker and confirmation |
| `MemberRowView.swift` | Circle member list item |
| `AlertEscalationView.swift` | Full-screen alert with countdown |
| `CareCirclePaywallView.swift` | Subscription purchase screen |
| `CircleMember.swift` | Circle member data model |
| `AlertEvent.swift` | Alert event data model |

### Firebase Cloud Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `sendInviteSMS` | Firestore onCreate (members) | Send SMS invitation via Twilio |
| `processInviteReply` | HTTP (Twilio webhook) | Handle YES/STOP replies |
| `sendAlertToCircle` | Firestore onCreate (alerts with status=escalated) | Send alert SMS to all members |
| `handleSubscriptionWebhook` | HTTP (App Store) | Process subscription events |

### Web Files (Firebase Hosting)

| File | Purpose |
|------|---------|
| `index.html` | Landing page |
| `status.html` | Alert status page (dynamic) |
| `js/status.js` | Firestore real-time listener |
| `css/style.css` | Styling |

---

## Next Steps

1. Review this plan and identify any concerns or modifications
2. Set up Firebase project and Twilio account
3. Begin Phase 1 implementation (backend foundation)

---

**Document Owner:** Chad Brown
**Last Review:** 2025-12-08
