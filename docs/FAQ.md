# Frequently Asked Questions (FAQ)

**HeartSafeAlerts - Common Questions Answered**

---

## General Questions

### What is HeartSafeAlerts?

HeartSafeAlerts is a free iOS app that monitors your heart rate in real-time and alerts you when it goes outside your target range. It works with Bluetooth heart rate monitors or Apple Watch.

### How much does it cost?

**Version 2.0 is completely FREE.** No subscriptions, no in-app purchases, no premium tiers. All features are free forever.

**Future:** Care Circle (coming Q2 2025) will be an optional $2.99/month premium subscription for family notifications and health sharing. But all current features remain free.

### Is this a medical device?

**No.** HeartSafeAlerts is a wellness app, not a medical device. It's not FDA-cleared or clinically validated. Do not use it for medical diagnosis, treatment, or emergencies. Always consult healthcare professionals for medical concerns.

### Why did you make everything free?

Because we realized heart rate monitoring isn't a luxury—it's a necessity. Athletes, seniors, and people with heart conditions need these tools regardless of their ability to pay. Version 2.0 reflects our commitment to accessibility over profit.

---

## Compatibility

### What devices does it work with?

**iPhones:**
- iPhone 8 or newer
- iOS 18.4 or later

**Heart Rate Monitors:**
- Any Bluetooth LE heart rate monitor (Polar, Wahoo, Garmin, Scosche, CooSpo, 4iiii, etc.)
- Must support standard Bluetooth Heart Rate Service (UUID 0x180D)

**Apple Watch:**
- Apple Watch Series 4 or newer
- watchOS compatible with iOS 18.4+

### Does it work with my Fitbit/Garmin watch?

If your device supports standard Bluetooth LE Heart Rate Service and can broadcast in "sensor mode," it should work. Check your device manual for Bluetooth heart rate broadcasting capabilities.

### Can I use it without any special equipment?

You need either:
- A Bluetooth heart rate monitor (chest strap or armband), OR
- An Apple Watch

The app cannot measure heart rate using only your iPhone (iPhones don't have heart rate sensors).

---

## Features & Functionality

### What's the difference between Bluetooth and Apple Watch modes?

**Bluetooth Mode:**
- Connects to external heart rate monitors (chest straps, armbands)
- More accurate during high-intensity exercise
- Real-time updates (minimal delay)
- Longer battery life (chest straps last months)
- Best for: Athletes, serious training, workouts

**Apple Watch Mode:**
- Uses your Apple Watch via HealthKit
- Convenient (already wearing it)
- May have 5-30 second update delays
- Optical wrist sensor (less accurate during intense exercise)
- Best for: Daily monitoring, light-moderate activity, convenience

**Automatic Mode:**
- App chooses best available source
- Prefers Bluetooth if connected, falls back to Apple Watch
- Best for: Most users

### Does it work in the background?

**Yes!** Enable "Background Notifications" in Settings. You'll receive push notifications even when the app is closed.

**Note:** Background Bluetooth monitoring is limited by iOS. For best results, keep the app open during active monitoring sessions.

### How accurate is it?

**Accuracy depends on your heart rate sensor:**
- **Chest straps (Polar H10, Wahoo TICKR):** Very accurate (±1-2 BPM), medical-grade sensors
- **Armband optical sensors:** Good accuracy (±2-5 BPM) for most activities
- **Apple Watch wrist sensor:** Good for daily monitoring, less accurate during intense exercise or poor fit

**HeartSafeAlerts displays data directly from your sensor.** We don't modify or "smooth" the readings. If your sensor is accurate, the app is accurate.

### Can I set different thresholds for different activities?

Currently, the app has one set of thresholds (min/max BPM). You can adjust them anytime in Settings.

**Tip:** Adjust before activities:
- Resting/sleeping: Lower thresholds (e.g., 50-90 BPM)
- Exercise: Higher thresholds (e.g., 70-170 BPM)

**Future:** Multiple threshold profiles may be added based on user feedback.

### What are session statistics?

Session stats show:
- **Minimum BPM:** Lowest heart rate during session
- **Average BPM:** Mean heart rate during session
- **Maximum BPM:** Highest heart rate during session
- **Time in Range:** How long you stayed within target
- **Time Out of Range:** How long you were outside target
- **Session Duration:** Total monitoring time

Stats reset when you start a new session (reconnect or tap refresh).

---

## Privacy & Data

### What data do you collect?

**None.** We don't collect, store, or transmit your heart rate data. Everything stays on your iPhone.

**No analytics.** No tracking. No cloud storage. No servers.

### Where is my data stored?

**On your iPhone only.** Session statistics are calculated in real-time and displayed during your session. User preferences (thresholds, alert settings) are stored locally in iOS UserDefaults.

**No health data is permanently stored** by HeartSafeAlerts.

### Can I export my data?

Currently, session statistics are not exportable (they're temporary and reset each session).

**Future Care Circle users** will have historical data and export capabilities.

### Is it open source?

**Yes!** The entire app is open source on GitHub: https://github.com/brownsterbits/HeartSafeAlerts

You can inspect the code to verify our privacy claims. We believe in transparency.

---

## Alerts

### How do alerts work?

When your heart rate goes **outside** your target range (below min or above max), the app can:
1. **Sound Alert:** Play a sound (if app is open)
2. **Vibration Alert:** Haptic feedback (if app is open)
3. **Push Notification:** Background notification (if app is closed)

**Cooldown periods prevent spam:**
- Sound/vibration: 5 seconds between alerts
- Notifications: 60 seconds between alerts

### Why am I not getting alerts?

**Check these:**
1. **Alerts enabled:** Settings → Enable Alerts (should be ON)
2. **iOS permissions:** Settings (iOS) → Notifications → HeartSafeAlerts → Allow Notifications
3. **Focus mode:** Check that HeartSafeAlerts isn't silenced in Focus settings
4. **Threshold values:** Make sure your heart rate is actually outside the range
5. **Grace period:** First 5 seconds after connection are grace period (no alerts)
6. **Stale data:** If no updates for 5+ seconds, alerts are paused

### Can I customize alert sounds?

Currently, the app uses iOS system sound (ID 1304). Custom sounds may be added in future updates based on user feedback.

### Do alerts work during workouts?

Yes! Alerts work regardless of your activity. You may want to adjust thresholds before high-intensity workouts to avoid false alarms.

**Tip:** Exercise typically raises heart rate significantly. Adjust your max threshold accordingly (e.g., 170 BPM instead of 100 BPM).

---

## Connection Issues

### My Bluetooth monitor won't connect. Help!

**Troubleshooting steps:**
1. ✅ Power on your heart rate monitor
2. ✅ Put it in pairing mode (check device manual)
3. ✅ Wear the monitor (some activate on skin contact)
4. ✅ Enable Bluetooth on iPhone (Settings → Bluetooth)
5. ✅ Tap "Tap to Reconnect" banner in app
6. ✅ Get close (within 10 feet initially)
7. ✅ Replace battery if old
8. ✅ Restart iPhone if necessary

**Still not working?**
- Unpair from other apps (some monitors connect to only one app at a time)
- Check manufacturer's app to verify monitor is working
- Try with a different device to rule out hardware issues

### Connection keeps dropping. Why?

**Common causes:**
- **Distance:** Keep iPhone within 30 feet of monitor
- **Interference:** Microwaves, Wi-Fi routers, other Bluetooth devices can interfere
- **Low battery:** Replace monitor battery
- **Poor contact:** Chest straps need good skin contact (moisture helps)
- **Movement:** Some monitors lose connection during intense movement

### Apple Watch data is delayed. Normal?

**Yes, this is expected.** HealthKit updates are controlled by Apple Watch and may have 5-30 second delays depending on:
- Watch activity level
- Battery saving mode
- Watch OS power management

For real-time monitoring, use Bluetooth mode with a chest strap.

---

## Battery & Performance

### Does it drain battery?

**Yes, continuous monitoring uses battery.** This is normal for any heart rate app.

**Typical drain:**
- Bluetooth monitoring: 5-10% per hour
- Apple Watch monitoring: 3-5% per hour
- Background mode: Minimal drain

**To reduce battery usage:**
- Use Low Power Mode
- Dim screen brightness
- Close other apps
- Only monitor when needed

### Can I use it all day?

Technically yes, but it will drain your iPhone battery significantly. HeartSafeAlerts is designed for:
- Workout monitoring (30-90 minutes)
- Activity sessions (1-3 hours)
- Periodic checks (not 24/7 monitoring)

**Future Apple Watch app** (roadmap) will enable all-day monitoring without draining iPhone battery.

---

## Care Circle (Future Premium)

### What is Care Circle?

Care Circle (launching Q2 2025) is an **optional** premium feature that adds family notifications:
- Alert your trusted contacts when heart rate is concerning
- "I'm Okay" check-in workflow
- Weekly health summaries for your circle
- Historical data and trends
- Up to 5 circle members

Think "Life360 for heart health."

### How much will Care Circle cost?

**$2.99/month** or **$19.99/year**

**All current free features remain free.** You only pay if you want the family notification layer.

### When is it launching?

**Q2 2025** (April-June timeframe). We're building it carefully to ensure privacy, reliability, and a great user experience.

### Will I have to pay for current features?

**No.** Everything in Version 2.0 stays free forever. Care Circle is an optional add-on for those who want family connectivity.

### Can I sign up for Care Circle early access?

Not yet. We'll announce beta testing opportunities on GitHub and via email list (coming soon).

**Want to be notified?** Watch our GitHub repo or email bits@brownster.com to join the waitlist.

---

## Technical Questions

### What iOS version do I need?

**iOS 18.4 or later**

Why? HeartSafeAlerts uses modern Swift 6 features and the latest HealthKit APIs for reliability and security.

### Does it work on iPad?

The app is iPhone-only currently. iPad support may be added in the future if there's demand.

### Does it work on older iPhones?

**iPhone 8 or newer** is recommended. Older models may experience:
- Slower performance
- Higher battery drain
- Bluetooth connection issues

### What programming language is it written in?

**Swift 6** with SwiftUI for the interface. We use:
- CoreBluetooth for Bluetooth
- HealthKit for Apple Watch
- Combine for reactive data flow
- UserNotifications for alerts

**It's open source!** See the code: https://github.com/brownsterbits/HeartSafeAlerts

---

## Comparison Questions

### How is this different from Apple Watch alerts?

**Apple Watch has basic alerts** for high/low heart rate, but:
- Only works with Apple Watch (no Bluetooth monitor support)
- Limited customization
- No session statistics
- No family notifications (even with Family Setup)

**HeartSafeAlerts adds:**
- Support for ANY Bluetooth heart rate monitor
- Customizable thresholds
- Session statistics
- Multiple alert types (sound, vibration, notifications)
- Future Care Circle for family notifications

**Use both!** Apple Watch alerts are a good backup. HeartSafeAlerts adds flexibility and features.

### How is this different from Cardiogram/HeartWatch/other apps?

**HeartSafeAlerts is unique:**
1. **Completely free** (no feature locks, no time limits)
2. **Supports both Bluetooth monitors AND Apple Watch** (others are Apple Watch only)
3. **Privacy-first** (no cloud storage, no analytics)
4. **Open source** (inspect the code)
5. **Simple focus** (real-time monitoring and alerts, not a fitness dashboard)

**Other apps are great for:**
- Long-term trend analysis
- Fitness/wellness tracking
- Integration with other health apps

**HeartSafeAlerts is best for:**
- Real-time monitoring during activities
- Custom alert thresholds
- Bluetooth device support
- Privacy and transparency

---

## Troubleshooting

### App crashed. What do I do?

1. Force quit the app (swipe up from app switcher)
2. Restart the app
3. If it crashes again, restart your iPhone
4. Update to latest iOS version
5. Reinstall the app if necessary

**Still crashing?** [Report a bug on GitHub](https://github.com/brownsterbits/HeartSafeAlerts/issues) with:
- iOS version
- iPhone model
- Steps to reproduce

### Session statistics aren't updating

**Check:**
- Is your heart rate monitor connected?
- Is heart rate data actually changing?
- Try refreshing connection (tap "Tap to Reconnect" banner)

Session stats only update when actively receiving heart rate data.

### Dark mode doesn't work

HeartSafeAlerts follows your iOS system setting:
- Settings → Display & Brightness → Appearance → Light/Dark/Automatic

There's no in-app toggle (this follows Apple's design guidelines).

---

## Feature Requests & Feedback

### Can you add [feature]?

Maybe! We prioritize based on:
- User demand (how many people want it)
- Technical feasibility
- Alignment with app mission (accessibility + simplicity)

**[Submit feature requests on GitHub](https://github.com/brownsterbits/HeartSafeAlerts/issues)**

**Popular requests we're considering:**
- Multiple threshold profiles (rest/exercise/sleep)
- Apple Watch app (on roadmap)
- Historical data export (Care Circle will have this)
- Custom alert sounds
- Integration with other fitness apps

### How can I contribute?

**Ways to help:**
1. **Report bugs:** https://github.com/brownsterbits/HeartSafeAlerts/issues
2. **Request features:** Tell us what you need
3. **Write code:** Submit pull requests (open source!)
4. **Spread the word:** Share with friends who need heart monitoring
5. **Leave a review:** App Store reviews help others discover the app

### Can I donate or support the project?

Currently, no. The app is free and will remain free.

**When Care Circle launches,** subscribing will support continued development.

**Other ways to support:**
- Star the GitHub repo ⭐
- Share the app with others
- Contribute code or documentation
- Leave an App Store review

---

## Contact & Support

### How do I get help?

**For technical support:**
- 📖 [Read the Getting Started Guide](HELP.md)
- ❓ Check this FAQ first
- 🐛 [Search GitHub Issues](https://github.com/brownsterbits/HeartSafeAlerts/issues)
- 📧 Email: bits@brownster.com

**Response time:** 24-72 hours

### Where can I report bugs?

**GitHub Issues:** https://github.com/brownsterbits/HeartSafeAlerts/issues

Please include:
- iOS version
- iPhone model
- App version
- Heart rate monitor model (if applicable)
- Steps to reproduce

### How can I contact the developer?

**Email:** bits@brownster.com
**GitHub:** @brownsterbits

**Response time:** Usually 48 hours, up to 72 hours for complex issues.

---

## Emergency Disclaimer

**⚠️ IMPORTANT: HeartSafeAlerts is NOT for emergencies.**

**If you experience:**
- Chest pain
- Severe shortness of breath
- Dizziness or fainting
- Irregular heartbeat
- Symptoms of heart attack or stroke

**CALL EMERGENCY SERVICES IMMEDIATELY (911 in US)**

**Do not wait for app alerts. This is not a medical device. Always seek professional medical help for health emergencies.**

---

## Still Have Questions?

**Didn't find your answer?**

📧 **Email us:** bits@brownster.com
🐛 **GitHub Issues:** https://github.com/brownsterbits/HeartSafeAlerts/issues
📖 **Getting Started:** [HELP.md](HELP.md)
🛠️ **Support:** [SUPPORT.md](SUPPORT.md)

We're here to help!

---

**HeartSafeAlerts**
Developed by Chad Brown
Open Source: https://github.com/brownsterbits/HeartSafeAlerts
Contact: bits@brownster.com

*Making heart rate monitoring accessible to everyone.*

Last Updated: January 16, 2025
