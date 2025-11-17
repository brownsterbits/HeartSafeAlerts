# Support

**HeartSafeAlerts Support**

Need help? You're in the right place.

---

## Quick Links

- 📖 **[Getting Started Guide](HELP.md)** - First time using the app?
- ❓ **[Frequently Asked Questions](FAQ.md)** - Common questions answered
- 🐛 **[Report a Bug](https://github.com/brownsterbits/HeartSafeAlerts/issues)** - Found something broken?
- 💡 **[Request a Feature](https://github.com/brownsterbits/HeartSafeAlerts/issues)** - Have an idea?
- 📧 **[Email Support](mailto:bits@brownster.com)** - Still need help?

---

## Support Channels

### GitHub Issues (Recommended)

**Best for:**
- Bug reports
- Feature requests
- Technical questions
- Open source contributions

**GitHub Issues:** https://github.com/brownsterbits/HeartSafeAlerts/issues

**Why GitHub?**
- Public responses help other users
- Easier to attach screenshots and logs
- Track progress on fixes
- Community can contribute solutions

**Response time:** Usually within 48 hours

---

### Email Support

**Best for:**
- Private issues
- Account questions (future Care Circle)
- Billing inquiries (future Care Circle)
- Sensitive information

**Email:** bits@brownster.com

**Response time:** Within 48-72 hours

**What to include:**
1. iOS version (Settings → General → About → Software Version)
2. iPhone model (Settings → General → About → Model Name)
3. App version (Settings → HeartSafeAlerts → Version)
4. Heart rate monitor model (if using Bluetooth)
5. Description of the problem
6. Screenshots if applicable

---

## Common Issues

### Bluetooth Connection Problems

**"Can't find my heart rate monitor"**

✅ **Try these steps:**
1. Make sure your heart rate monitor is powered on
2. Check that it's in pairing mode (consult device manual)
3. Wear the monitor (some activate only when worn)
4. Ensure Bluetooth is enabled on iPhone (Settings → Bluetooth)
5. Try refreshing: Tap status banner when disconnected
6. Restart your iPhone
7. Replace monitor battery if old

**"Connection keeps dropping"**

✅ **Try these steps:**
1. Keep iPhone within 30 feet of heart rate monitor
2. Avoid interference (microwaves, Wi-Fi routers, other Bluetooth devices)
3. Check monitor battery level
4. Ensure monitor is positioned correctly (chest straps need skin contact)
5. Update to latest iOS version
6. Restart Bluetooth: Settings → Bluetooth → Toggle off/on

**Compatible Devices:**
- Any Bluetooth LE heart rate monitor using standard Heart Rate Service (UUID 0x180D)
- Popular brands: Polar, Wahoo, Garmin, Scosche, CooSpo, 4iiii

**Not sure if your device is compatible?** Check the manufacturer's specifications for "Bluetooth LE" or "Bluetooth 4.0+" support.

---

### Apple Watch / HealthKit Issues

**"Can't access Apple Watch heart rate"**

✅ **Try these steps:**
1. Grant HealthKit permission: Settings → Privacy & Security → Health → HeartSafeAlerts → Turn on "Heart Rate"
2. Ensure Apple Watch is paired and unlocked
3. Make sure Apple Watch is on your wrist (optical sensor requires skin contact)
4. Check that Watch OS is up to date
5. Open Health app on iPhone to verify heart rate data is being recorded
6. Restart both iPhone and Apple Watch

**"Apple Watch data seems delayed"**

⚠️ **This is normal.** HealthKit updates are controlled by Apple Watch and may have delays of 5-30 seconds depending on:
- Watch activity (actively recording workout = faster updates)
- Battery level (low battery = less frequent updates)
- Watch OS power management

💡 **For real-time monitoring, use Bluetooth mode with a chest strap instead.**

---

### Alert Issues

**"Not receiving alerts"**

✅ **Check these settings:**

1. **In HeartSafeAlerts:**
   - Settings → Enable Alerts (should be ON)
   - Settings → Sound Alerts (optional)
   - Settings → Vibration Alerts (optional)
   - Settings → Background Notifications (for alerts when app is closed)

2. **In iOS Settings:**
   - Settings → Notifications → HeartSafeAlerts → Allow Notifications (should be ON)
   - Settings → Notifications → HeartSafeAlerts → Check "Lock Screen", "Notification Center", "Banners"
   - Settings → Focus → Check that HeartSafeAlerts is not silenced

3. **Check your thresholds:**
   - Settings → Heart Rate Thresholds
   - Make sure min/max values make sense for your activity
   - Default: 60-100 BPM (adjust based on your needs)

**"Getting too many alerts"**

✅ **Adjust these:**
- Increase threshold range (e.g., 50-120 instead of 60-100)
- Alerts have 5-second cooldown for sounds/vibration
- Notifications have 60-second cooldown
- Consider adjusting thresholds for exercise vs. rest periods

---

### Data Source Selection

**"Which should I use: Bluetooth or Apple Watch?"**

**Use Bluetooth if:**
- You have a chest strap (more accurate for exercise)
- You need real-time updates
- You're doing high-intensity workouts
- Battery life is a concern (chest straps last months)

**Use Apple Watch if:**
- You don't have a Bluetooth monitor
- You prefer wrist-based monitoring
- You're doing light-moderate activity
- You want convenience (already wearing Watch)

**Use Automatic if:**
- You want the app to decide for you
- Priority: Bluetooth > Apple Watch
- Automatic fallback if Bluetooth disconnects

💡 **Pro tip:** Chest straps (like Polar H10) are more accurate than wrist-based sensors during high-intensity exercise.

---

### App Performance

**"App is draining battery"**

⚠️ **This is expected behavior.** Continuous heart rate monitoring uses:
- Bluetooth connection (moderate drain)
- Screen-on time (high drain if watching continuously)
- Background notifications (minimal drain)

✅ **To reduce battery usage:**
- Use Low Power Mode (Settings → Battery → Low Power Mode)
- Dim screen brightness
- Close other apps
- Disable unnecessary alerts

**Typical battery impact:**
- Bluetooth monitoring: 5-10% per hour
- Apple Watch monitoring: 3-5% per hour
- Background mode: Minimal drain

**"App crashes or freezes"**

✅ **Try these steps:**
1. Force quit the app (swipe up from app switcher)
2. Restart the app
3. Restart your iPhone
4. Update to latest iOS version
5. Reinstall the app (Settings → General → iPhone Storage → HeartSafeAlerts → Delete App)

If crashes persist, **[report a bug](https://github.com/brownsterbits/HeartSafeAlerts/issues)** with:
- iOS version
- iPhone model
- Steps to reproduce the crash

---

### Dark Mode

**"Want to use light mode"**

HeartSafeAlerts follows your system appearance:
- Settings → Display & Brightness → Light/Dark/Automatic
- The app will match your system setting

There's no in-app toggle (this follows Apple's design guidelines).

---

## Feature Requests

Have an idea to make HeartSafeAlerts better?

**We want to hear it!**

**[Submit a feature request on GitHub](https://github.com/brownsterbits/HeartSafeAlerts/issues)**

**What to include:**
1. **Problem:** What are you trying to accomplish?
2. **Solution:** How would you solve it?
3. **Use case:** Why is this important to you?
4. **Priority:** Is this a must-have or nice-to-have?

Popular requests shape our roadmap. Care Circle (coming Q2 2025) was influenced by user feedback!

---

## Bug Reports

Found a bug? Help us fix it!

**[Report on GitHub](https://github.com/brownsterbits/HeartSafeAlerts/issues)**

**What to include:**
1. **Expected behavior:** What should happen?
2. **Actual behavior:** What actually happens?
3. **Steps to reproduce:** How can we trigger the bug?
4. **Environment:**
   - iOS version
   - iPhone model
   - App version
   - Heart rate monitor model (if applicable)
5. **Screenshots/videos:** Show us what's wrong

**Security bugs:** Please email bits@brownster.com instead of posting publicly.

---

## Open Source Contributions

HeartSafeAlerts is open source! Want to contribute?

**GitHub Repository:** https://github.com/brownsterbits/HeartSafeAlerts

**How to contribute:**
1. Read [CLAUDE.md](../CLAUDE.md) for development guide
2. Fork the repository
3. Make your changes
4. Submit a pull request
5. We'll review and merge if appropriate

**Types of contributions we welcome:**
- Bug fixes
- Performance improvements
- Documentation updates
- Translations (future)
- UI/UX enhancements
- Test coverage improvements

---

## Frequently Asked Questions

See our **[FAQ page](FAQ.md)** for answers to common questions:
- Is this a medical device?
- How accurate is it?
- Does it work in the background?
- What's the difference between Bluetooth and Apple Watch?
- When is Care Circle launching?
- And more...

---

## Future: Care Circle Support

When Care Circle launches (Q2 2025), subscribers will have additional support channels:
- In-app help for Care Circle features
- Circle member management support
- Notification troubleshooting
- Billing support for subscriptions

All current free features will continue to be supported through GitHub and email.

---

## Emergency Situations

**⚠️ IMPORTANT: HeartSafeAlerts is NOT for emergencies.**

**If you are experiencing:**
- Chest pain or pressure
- Severe shortness of breath
- Dizziness or fainting
- Irregular heartbeat
- Symptoms of heart attack or stroke

**CALL EMERGENCY SERVICES IMMEDIATELY**
- 🇺🇸 United States: 911
- 🇬🇧 United Kingdom: 999
- 🇪🇺 European Union: 112
- 🇦🇺 Australia: 000
- 🇨🇦 Canada: 911

**Do not wait for app alerts. Seek immediate medical attention.**

---

## Response Times

We're a small team (solo developer + community), but we're committed to helping:

- **GitHub Issues:** Usually 24-48 hours
- **Email Support:** 48-72 hours
- **Critical bugs:** Within 24 hours
- **Feature requests:** Added to roadmap, no timeline guarantee

**We prioritize:**
1. Security issues
2. Crash bugs
3. Data accuracy problems
4. Connection issues
5. Feature requests

---

## Community

Connect with other HeartSafeAlerts users:

**GitHub Discussions:** https://github.com/brownsterbits/HeartSafeAlerts/discussions
- Share tips and tricks
- Ask questions
- Help other users
- Discuss features

**Reddit:** r/HeartRateMonitoring (unofficial)
**Twitter:** @HeartSafeAlerts (coming soon)

---

## Version Information

**Current Version:** 2.0
**Release Date:** January 16, 2025
**Minimum iOS:** 18.4
**Supported Devices:** iPhone 8 or newer, Apple Watch Series 4 or newer

**What's New in 2.0:**
- Completely rebuilt from scratch
- Everything free (no premium tiers)
- Apple Watch support via HealthKit
- Dual data source management
- Session statistics
- Dark mode support
- 66% code complexity reduction

---

## Still Need Help?

We're here to help!

**📧 Email:** bits@brownster.com
**🐛 GitHub Issues:** https://github.com/brownsterbits/HeartSafeAlerts/issues

**Include:**
- iOS version
- iPhone model
- App version
- Heart rate monitor model
- Description of problem
- Screenshots

**Response time:** 24-72 hours

---

**HeartSafeAlerts**
Developed by Chad Brown
Open Source: https://github.com/brownsterbits/HeartSafeAlerts
Contact: bits@brownster.com

*Making heart rate monitoring accessible to everyone.*
