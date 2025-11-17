# HeartSafeAlerts Product Roadmap

**Last Updated:** 2025-01-16
**Vision:** Heart rate monitoring that keeps your loved ones in the loop

## Strategic Positioning

### What We're NOT
- NOT competing with Apple Watch's basic heart rate alerts
- NOT a medical device or diagnostic tool
- NOT a fitness/wellness dashboard with charts and trends (yet)

### What We ARE
- **Specialty Bluetooth device support** - Medical-grade sensors, athletic chest straps, devices Apple doesn't support natively
- **Care Circle** - The human connection layer Apple doesn't provide
- **Custom intelligence** - Personalized multi-signal patterns beyond Apple's generic alerts
- **Peace of mind for loved ones** - Solo monitoring is table stakes; connection is our differentiator

## Business Model Evolution

### Current State (v1.0)
- ❌ Premium features behind $4.99 one-time purchase
- ❌ Limited free tier
- ❌ Low conversion, high friction

### New Model (v1.1+)
- ✅ **Free Tier:** ALL basic features (alerts, Bluetooth, Apple Watch, custom thresholds)
- ✅ **Premium Tier ($2.99/month or $19.99/year):** Care Circle + advanced features
- ✅ **Goal:** Build user base first, convert 5-10% to premium for Care Circle

## Phase 1: Foundation & Free Tier (Weeks 1-4) ✅ COMPLETE

**Goal:** Get users, build trust, prove reliability

### Refactoring & Cleanup
- [x] Remove all premium gating from alerts
- [x] Enable dark mode (remove forced light mode)
- [x] Refactor HeartRateMonitor:
  - [x] Separate AlertManager from Bluetooth logic
  - [x] Better state management
  - [x] Cleaner separation of concerns
- [x] Improve UI components:
  - [x] Extract reusable views (SessionStatsView, CareCirclePreviewView)
  - [x] Better accessibility
  - [x] Session statistics display
- [x] Update Settings UI for free tier
- [x] Code quality improvements:
  - [x] Better error handling
  - [x] Improved organization
  - [x] Reduced duplication (66% reduction in HeartRateMonitor size)

### New Features
- [x] Add HealthKit integration:
  - [x] Read heart rate from Apple Watch
  - [x] Dual-source support (Bluetooth OR HealthKit)
  - [x] Auto-detect best source
  - [x] Settings picker for source preference (Bluetooth/Apple Watch/Automatic)
- [x] Session statistics:
  - [x] Min/Max/Average BPM for current session
  - [x] Time in target range
  - [x] Time out of range
  - [x] Session duration display
- [x] Care Circle preview in Settings (teaser for future premium)
- [ ] Improved onboarding:
  - [ ] Explain Bluetooth vs. Apple Watch
  - [ ] Device compatibility checker
  - [ ] Permission flow improvements

### Marketing & Store Presence
- [ ] Update App Store listing:
  - [ ] New positioning: "Keep loved ones in the loop"
  - [ ] Screenshots showing both Bluetooth and Apple Watch
  - [ ] Clear roadmap in description
- [ ] heartsafe.io updates:
  - [ ] Landing page
  - [ ] Privacy policy
  - [ ] Terms of service
  - [ ] Support contact
- [ ] Prepare for Care Circle launch announcement

**Success Metrics:**
- 1,000+ downloads in first month
- 4.0+ star rating
- 30%+ 7-day retention
- <5% crash rate

**Status:** ✅ Core refactoring and HealthKit integration COMPLETE (Jan 16, 2025)
**Deliverable:** App Store submission v1.1 with all features free - READY FOR SUBMISSION

---

## Phase 2: Care Circle v1 (Weeks 5-12) 💚

**Goal:** Launch subscription tier with compelling value

### Backend Infrastructure
- [ ] Choose backend (Firebase vs. CloudKit):
  - Firebase: Better for cross-platform future
  - CloudKit: Native, simpler for iOS-only
  - **Recommendation:** Firebase for flexibility
- [ ] Set up authentication (Firebase Auth or Sign in with Apple)
- [ ] Database schema:
  - Users
  - Care Circles
  - Circle Members
  - Alert Events
  - Notification Preferences
- [ ] Push notification service
- [ ] SMS integration for invites (Twilio)

### Core Care Circle Features
- [ ] **Invite System:**
  - Send invite via SMS/Email
  - Invite link opens app or web landing
  - Accept/decline flow
  - Manage up to 5 circle members (premium)

- [ ] **Alert Escalation:**
  ```
  User alert triggers
  ↓
  5-minute grace period (user can acknowledge)
  ↓
  No response → Notify Care Circle
  ↓
  Push notification to all circle members
  ↓
  Members can: Call, Text, or Request Check-in
  ```

- [ ] **Check-in Workflow:**
  - User side: "I'm Okay" / "Need Help" / "False Alarm"
  - Circle side: "Called them" / "Texted" / "They're OK"
  - Status updates to all parties

- [ ] **Weekly Digest:**
  - Plain-language summary to circle members
  - "This week: 2 alerts, both resolved quickly"
  - "Status: Stable" / "Needs attention"
  - Opt-in/opt-out per member

### UI/UX
- [ ] New "Care Circle" tab in app
- [ ] Circle member management screen
- [ ] Invitation flow
- [ ] Alert history with circle notifications
- [ ] Premium paywall for Care Circle features
- [ ] Subscription management (via StoreKit)

### Privacy & Security
- [ ] End-to-end encryption for sensitive data
- [ ] Granular permissions (what each member sees)
- [ ] Audit log (who was notified when)
- [ ] Easy revoke access
- [ ] GDPR/CCPA compliance
- [ ] Clear data retention policies

**Success Metrics:**
- 5-10% conversion to premium
- 80% subscriber retention after 3 months
- <2% refund rate
- NPS 40+

**Deliverable:** App Store update v1.2 with Care Circle subscription

---

## Phase 3: Apple Watch App (Weeks 13-20) ⌚

**Goal:** Make premium subscribers inseparable from the app

### watchOS Development
- [ ] Native watchOS app (not just extension)
- [ ] Real-time heart rate display
- [ ] Status indicator (OK / Warning / Alert)
- [ ] Haptic alert patterns:
  - Gentle: First notification
  - Persistent: Repeated out-of-range
  - Urgent: Care Circle about to be notified

### Complications
- [ ] Modular Small: Status icon
- [ ] Modular Large: HR + status
- [ ] Circular: HR gauge
- [ ] Graphic Corner: Mini chart
- [ ] Graphic Circular: Full status

### Watch-Specific Features
- [ ] **On-wrist acknowledgment:**
  - "I'm Okay" button
  - "Exercising" (pause alerts 30 min)
  - "Need Help" (immediately notify circle)

- [ ] **Care Circle integration:**
  - "We're about to notify Sara" → Quick response
  - "Circle notified" confirmation
  - See who was notified

- [ ] **Offline resilience:**
  - Track HR when away from iPhone
  - Queue alerts and decisions
  - Sync when back in range

- [ ] **Quick logging:**
  - "Feeling symptoms" log
  - Context tags (Exercise, Rest, Stress)
  - Sync to iPhone for circle summaries

### iPhone Integration
- [ ] Seamless handoff (watch → phone)
- [ ] Watch pairing detection
- [ ] Prefer watch data when available
- [ ] Settings sync via Watch Connectivity

**Success Metrics:**
- 40% of premium subscribers use watch app weekly
- 25% increase in daily active users
- 15% improvement in retention
- Watch app rating 4.5+

**Deliverable:** App Store update v1.3 with Apple Watch app

---

## Phase 4: Intelligence Layer (Weeks 21-26) 🧠

**Goal:** Reduce false alarms, increase trust through smart patterns

### Context Detection
- [ ] Workout detection (high HR is normal)
- [ ] Sleep detection (low HR is normal)
- [ ] Time-of-day patterns
- [ ] Activity correlation (movement sensors)

### Pattern Recognition
- [ ] Multi-signal logic:
  - Single spike vs. sustained elevation
  - Gradual increase vs. sudden jump
  - Recovery time analysis
- [ ] False alarm reduction:
  - Learn from user acknowledgments
  - "You usually dismiss alerts during this time"
  - Suggest threshold adjustments

### Personalization
- [ ] Adaptive thresholds:
  - Different limits for exercise vs. rest
  - Time-based rules (stricter at night)
  - Seasonal adjustments (if user patterns change)

- [ ] Smart escalation:
  - Don't notify circle during known exercise times
  - Escalate faster for concerning patterns
  - Quiet hours (e.g., no circle alerts 11pm-7am unless critical)

### Historical Insights (Premium)
- [ ] Trend charts (daily/weekly/monthly)
- [ ] Resting heart rate tracking
- [ ] Recovery metrics
- [ ] Export for doctor visits
- [ ] Pattern summaries in plain language

### Advanced Care Circle Features
- [ ] Per-member alert rules:
  - Spouse sees everything
  - Adult child only gets critical alerts
  - Friend only during specific times

- [ ] Caregiver dashboard:
  - Web view for non-iPhone users
  - Monitor multiple loved ones
  - Aggregated health status

- [ ] Predictive alerts:
  - "Pattern suggests possible concern"
  - Suggest medical consultation
  - Never diagnose, always recommend professional care

**Success Metrics:**
- 30% reduction in false alerts
- 20% increase in user satisfaction (NPS 50+)
- 50% of users enable advanced features
- <1% disable alerts due to annoyance

**Deliverable:** App Store update v1.4 with intelligence features

---

## Phase 5: Ecosystem Expansion (Months 7-12) 🌐

### Multi-Device Support
- [ ] Connect multiple Bluetooth devices
- [ ] Switch between devices seamlessly
- [ ] Device profiles (chest strap for workouts, watch for daily)
- [ ] Historical data per device

### Extended Signals
- [ ] Blood pressure monitoring (if devices available)
- [ ] SpO₂ tracking
- [ ] HRV (Heart Rate Variability)
- [ ] Multi-signal correlations

### Platform Expansion
- [ ] iPad app (optimized layout)
- [ ] Mac app (for caregivers)
- [ ] Web dashboard (caregiver view)
- [ ] Android version (for cross-platform Care Circles)

### Professional Features
- [ ] Healthcare provider portal
- [ ] HIPAA compliance path
- [ ] Clinic/enterprise licensing
- [ ] Integration with medical records systems

### Community & Content
- [ ] In-app health tips
- [ ] User stories (with permission)
- [ ] Blog at heartsafe.io
- [ ] Community forums for caregivers

**Success Metrics:**
- 10,000+ active users
- 1,000+ premium subscribers
- $3,000+ MRR (Monthly Recurring Revenue)
- Featured in App Store Health category
- Media coverage or awards

**Deliverable:** Mature product with defensible moat

---

## Long-Term Vision (Year 2+)

- FDA clearance path (if pursuing medical device status)
- Insurance partnerships (reimbursement for monitoring)
- B2B offerings (senior living facilities, home health agencies)
- International expansion (localization, regional partnerships)
- Strategic acquisition potential (health tech companies, insurers)

---

## Risk Mitigation

### Technical Risks
- **Battery drain from background monitoring**
  - Mitigation: Optimize BLE/HealthKit polling, user education
- **Bluetooth reliability issues**
  - Mitigation: Robust reconnection, clear status indicators
- **Backend scaling for Care Circle**
  - Mitigation: Start with Firebase, plan for dedicated infra at scale

### Business Risks
- **Low conversion to premium**
  - Mitigation: Generous free tier builds trust, Care Circle has clear value
- **Competition from Apple**
  - Mitigation: Focus on connection/specialty devices, not solo monitoring
- **Privacy concerns**
  - Mitigation: Transparent policies, granular controls, encryption

### Regulatory Risks
- **FDA oversight**
  - Mitigation: Clear disclaimers (not medical device), avoid diagnostic claims
- **HIPAA compliance**
  - Mitigation: Follow best practices even if not legally required

---

## Key Principles

1. **Privacy First:** User controls who sees what, always
2. **Reliability Above All:** Alerts must work 99.9% of the time
3. **Human Connection:** Technology serves relationships, not replaces them
4. **Accessibility:** Support all users (elderly, disabled, tech-challenged)
5. **Transparent Value:** Never trick users, clear pricing, honest capabilities
6. **Conservative Medical Claims:** We notify, we don't diagnose

---

## Next Steps

1. **✅ Week 1-2 (Jan 8-16):** Complete Phase 1 refactoring → DONE
   - Removed premium gates, enabled dark mode
   - Refactored to clean architecture (AlertManager, BluetoothManager, SessionStatistics)
   - Added HealthKit integration for Apple Watch support
   - Created UI components (SessionStatsView, CareCirclePreviewView)
2. **This Week (Jan 16-20):** App Store Submission Prep
   - [ ] Update App Store screenshots
   - [ ] Write new app description emphasizing free tier + future Care Circle
   - [ ] Submit v1.1 to App Store Review
3. **Week 4-5:** Begin Phase 2 (Care Circle backend planning)
   - Research Firebase vs CloudKit decision
   - Design Care Circle data schema
   - Plan alert escalation flow

---

**Document Owner:** Chad Brown
**Review Cadence:** Weekly during active development, monthly thereafter
**Last Major Revision:** 2025-01-16 (Strategic pivot to free tier + Care Circle)
