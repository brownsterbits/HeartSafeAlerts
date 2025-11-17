# Getting Started with HeartSafeAlerts

Welcome to HeartSafeAlerts! This guide will help you get set up and monitoring your heart rate in just a few minutes.

---

## What You'll Need

Choose ONE of the following:

**Option 1: Bluetooth Heart Rate Monitor**
- Any Bluetooth LE heart rate monitor (Polar, Wahoo, Garmin, Scosche, etc.)
- Fresh battery installed
- Device manual handy (for pairing instructions)

**Option 2: Apple Watch**
- Apple Watch Series 4 or newer
- Paired with your iPhone
- watchOS up to date

---

## Quick Start (5 Minutes)

### Step 1: Install the App

1. Download HeartSafeAlerts from the App Store
2. Open the app
3. You'll see the main screen with a heart icon and "Tap to Reconnect" banner

### Step 2A: Connect Bluetooth Monitor

1. **Power on your heart rate monitor**
   - Install fresh battery if needed
   - Put device in pairing mode (check your device manual)
   - For chest straps: Wear it (many activate on skin contact)

2. **In HeartSafeAlerts:**
   - Tap the gray "Tap to Reconnect ↻" banner
   - Status will change to "Initializing..." (blue)
   - Then "Connected" (green) when successful

3. **You're monitoring!**
   - Heart rate will appear in large numbers
   - Heart icon will pulse
   - Session statistics will start tracking

**Troubleshooting:**
- Make sure Bluetooth is enabled (Settings → Bluetooth)
- Get close (within 10 feet for initial pairing)
- Check device manual for pairing mode instructions
- Try refreshing: Tap banner again

### Step 2B: Connect Apple Watch

1. **Grant HealthKit Permission:**
   - First time: App will prompt for HealthKit access
   - Tap "Allow" when prompted
   - Or: Settings → Privacy & Security → Health → HeartSafeAlerts → Turn on "Heart Rate"

2. **Select Apple Watch as Data Source:**
   - Tap settings icon (gear) at bottom of screen
   - Scroll to "Data Source" section
   - Select "Apple Watch" or "Automatic"

3. **Ensure Apple Watch is ready:**
   - Watch must be unlocked
   - Watch must be on your wrist
   - Wait 10-20 seconds for first reading

4. **You're monitoring!**
   - Heart rate will appear (may take 10-30 seconds initially)
   - Updates may be slower than Bluetooth (5-30 second intervals)

**Troubleshooting:**
- Check that Apple Watch is paired and unlocked
- Open Health app to verify heart rate data is being recorded
- Restart both iPhone and Apple Watch if needed

### Step 3: Configure Alerts

1. **Tap the settings icon** (gear at bottom of screen)

2. **Set Your Thresholds:**
   - **Minimum BPM:** Lowest acceptable heart rate (default: 60)
   - **Maximum BPM:** Highest acceptable heart rate (default: 100)
   - Adjust sliders to your needs

3. **Enable Alerts:**
   - Turn on "Enable Alerts"
   - Optional: Turn on "Sound Alerts" (plays sound when out of range)
   - Optional: Turn on "Vibration Alerts" (haptic feedback)
   - Optional: Turn on "Background Notifications" (alerts when app is closed)

4. **Grant Notification Permission:**
   - iOS will prompt: "HeartSafeAlerts Would Like to Send You Notifications"
   - Tap "Allow" for background alerts
   - Or: Settings → Notifications → HeartSafeAlerts → Allow Notifications

### Step 4: Start Monitoring!

You're all set! The app will now:
- ✅ Display your heart rate in real-time
- ✅ Track session statistics (min/max/avg, time in/out of range)
- ✅ Alert you when heart rate is outside your target range
- ✅ Continue monitoring in background (if notifications enabled)

---

## Understanding the Interface

### Main Screen

**Status Banner (Top 20% of screen):**
- **Gray "Tap to Reconnect ↻"** → Not connected (tap to connect)
- **Blue "Initializing..."** → Connecting to device
- **Green "Connected"** → Successfully monitoring
- **Orange "No Signal"** → Connected but no data (stale)
- **Red "Warning"** → Heart rate is out of range

**Heart Icon (Center):**
- Pulses when actively monitoring
- Black = normal range
- Red = out of range

**Heart Rate Display (Center):**
- Large number = current heart rate (BPM)
- "— BPM" = no data yet or stale
- Gray text below = your target range

**Session Statistics (Below heart rate):**
- Appears automatically when you have data
- Shows min/max/avg BPM
- Shows time in/out of range
- Shows session duration

**Settings Icon (Bottom):**
- Tap to configure thresholds, alerts, and data source

---

## Settings Explained

### Heart Rate Thresholds

**Minimum BPM:** (Range: 40-100)
- Alert if heart rate drops below this
- Typical values:
  - Resting: 50-60 BPM
  - Light activity: 60-70 BPM
  - Seniors: 55-65 BPM

**Maximum BPM:** (Range: 100-200)
- Alert if heart rate goes above this
- Typical values:
  - Resting: 80-100 BPM
  - Light exercise: 100-130 BPM
  - Intense exercise: 140-170 BPM
  - Athletes: 170-185 BPM

**💡 Pro Tip:** Adjust thresholds based on your activity:
- Sleeping: 45-85 BPM
- Resting: 60-100 BPM
- Walking: 80-120 BPM
- Moderate exercise: 100-150 BPM
- Intense exercise: 130-180 BPM

### Data Source

**Bluetooth Monitor:**
- Connects to external heart rate devices
- Most accurate for exercise
- Real-time updates
- Best for: Workouts, training

**Apple Watch:**
- Reads from HealthKit
- Convenient (already wearing it)
- May have 5-30 second delays
- Best for: Daily monitoring, light activity

**Automatic:**
- App chooses best source
- Prefers Bluetooth if available
- Falls back to Apple Watch
- Best for: Most users

### Alerts

**Enable Alerts:**
- Master switch for all alerts
- Turn off to disable all notifications

**Sound Alerts:**
- Plays system sound when out of range
- Only when app is open
- 5-second cooldown between sounds

**Vibration Alerts:**
- Haptic feedback when out of range
- Only when app is open
- 5-second cooldown

**Background Notifications:**
- Push notifications when app is closed
- Requires iOS notification permission
- 60-second cooldown between notifications
- Recommended for continuous monitoring

---

## Best Practices

### For Workouts

1. **Connect before starting** - Don't wait until you're mid-exercise
2. **Adjust thresholds** - Set max higher for intense activities
3. **Keep iPhone nearby** - Bluetooth range is ~30 feet
4. **Use chest strap** - More accurate than wrist sensors during exercise

### For Daily Monitoring

1. **Use Apple Watch mode** - Convenient for all-day wear
2. **Enable background notifications** - Get alerts even when app is closed
3. **Set conservative thresholds** - Avoid false alarms
4. **Check battery** - Continuous monitoring uses battery

### For Sleep Monitoring

1. **Lower thresholds** - Heart rate drops during sleep (typical: 45-85 BPM)
2. **Use airplane mode** - Reduce interference if Bluetooth connected
3. **Keep iPhone charging** - All-night monitoring drains battery
4. **Place iPhone nearby** - Maintain Bluetooth connection

---

## Common Scenarios

### Scenario 1: I'm a Runner

**Setup:**
- Use Bluetooth chest strap (Polar H10 or Wahoo TICKR)
- Set thresholds: 70-170 BPM (adjust for your fitness level)
- Enable all alerts (sound, vibration, notifications)

**During Run:**
- Keep iPhone in armband or running belt
- Monitor heart rate to stay in training zones
- Alerts will warn if you're pushing too hard or slacking off

### Scenario 2: I Have a Heart Condition

**Setup:**
- Consult your doctor for appropriate thresholds
- Use most accurate monitoring method (Bluetooth chest strap)
- Enable background notifications for peace of mind
- Consider future Care Circle for family alerts (Q2 2025)

**Important:** This is NOT a medical device. Use only as supplemental monitoring, not as replacement for medical-grade equipment.

### Scenario 3: I'm a Senior Wanting Peace of Mind

**Setup:**
- Use Apple Watch (convenient, already wearing it)
- Set conservative thresholds (e.g., 55-95 BPM)
- Enable background notifications
- Keep iPhone charged and nearby

**Daily Use:**
- Wear Apple Watch as usual
- App monitors in background
- Alerts only when heart rate is concerning
- Future Care Circle will notify family automatically

### Scenario 4: I'm Tracking Fitness Progress

**Setup:**
- Use any heart rate monitor (Bluetooth or Apple Watch)
- Set thresholds based on target training zones
- Monitor session statistics

**After Workout:**
- Review session stats (min/max/avg)
- Check time in target zone
- Adjust thresholds for next session

---

## Tips & Tricks

### Accuracy Tips

**For Bluetooth Chest Straps:**
- Moisten electrodes before wearing (improves contact)
- Wear snugly but not too tight
- Position just below chest muscles
- Check battery regularly (replace yearly)

**For Apple Watch:**
- Wear snugly on wrist (1-2 finger gap from wrist bone)
- Clean sensor regularly (sweat/dirt reduces accuracy)
- Optical sensors work best for steady-state activities
- Less accurate during high-intensity intervals

### Battery Saving Tips

- Dim screen brightness
- Use Low Power Mode (Settings → Battery)
- Disable unnecessary alerts
- Close other background apps
- Only monitor when needed (not 24/7)

### Connection Tips

- Stay within 30 feet of Bluetooth device
- Avoid interference (microwaves, Wi-Fi routers)
- Update iOS regularly for Bluetooth improvements
- Restart iPhone if persistent connection issues

---

## Troubleshooting

### "Can't connect to my Bluetooth monitor"

**Check:**
- ✅ Monitor is powered on and in pairing mode
- ✅ Monitor has fresh battery
- ✅ Bluetooth is enabled on iPhone
- ✅ You're within 10 feet
- ✅ Monitor isn't connected to another app

**Try:**
- Tap "Tap to Reconnect" banner
- Restart the app
- Restart your iPhone
- Consult monitor's manual for pairing instructions

### "Not getting Apple Watch heart rate"

**Check:**
- ✅ HealthKit permission granted (Settings → Privacy → Health)
- ✅ Apple Watch is unlocked and on wrist
- ✅ Watch OS is up to date
- ✅ Health app shows recent heart rate data

**Try:**
- Wait 30 seconds (HealthKit has delays)
- Restart both iPhone and Apple Watch
- Re-grant HealthKit permission

### "Not receiving alerts"

**Check:**
- ✅ "Enable Alerts" is ON in app Settings
- ✅ Notification permission granted (Settings → Notifications → HeartSafeAlerts)
- ✅ Your heart rate is actually outside thresholds
- ✅ Not in grace period (first 5 seconds after connection)

**Try:**
- Test with extreme thresholds (e.g., min: 70, max: 80)
- Check Focus mode isn't silencing alerts
- Restart the app

---

## What's Next?

### Monitor Regularly

Use HeartSafeAlerts during:
- Workouts and training sessions
- Daily activities (with Apple Watch)
- Sleep (if concerned about night-time heart rate)
- Recovery periods after exercise

### Adjust as Needed

- Fine-tune thresholds based on experience
- Experiment with different alert combinations
- Switch between Bluetooth and Apple Watch as needed

### Stay Updated

- Watch GitHub for updates: https://github.com/brownsterbits/HeartSafeAlerts
- Check for app updates in App Store
- Join the community (GitHub Discussions)

### Coming Soon: Care Circle

**Q2 2025** - Optional premium feature ($2.99/month):
- Alert your loved ones when heart rate is concerning
- Family check-in workflows
- Weekly health summaries
- Historical data and trends

All current features stay FREE forever.

---

## Need More Help?

- ❓ **[FAQ](FAQ.md)** - Common questions answered
- 🛠️ **[Support](SUPPORT.md)** - Detailed troubleshooting
- 🐛 **[GitHub Issues](https://github.com/brownsterbits/HeartSafeAlerts/issues)** - Bug reports and feature requests
- 📧 **[Email](mailto:bits@brownster.com)** - Direct support

---

## Safety Reminders

⚠️ **HeartSafeAlerts is NOT a medical device**
⚠️ **Do not use for diagnosis or treatment**
⚠️ **Not for emergency situations**
⚠️ **Always consult healthcare professionals**

**In an emergency: CALL 911 (US) or your local emergency number**

---

**Welcome to HeartSafeAlerts!**

We're glad you're here. Our mission is to make heart rate monitoring accessible, reliable, and free for everyone who needs it.

Questions? Ideas? Feedback? We want to hear from you.

**Email:** bits@brownster.com
**GitHub:** https://github.com/brownsterbits/HeartSafeAlerts

Happy monitoring! ❤️

---

**HeartSafeAlerts**
Developed by Chad Brown
Open Source: https://github.com/brownsterbits/HeartSafeAlerts

*Making heart rate monitoring accessible to everyone.*

Last Updated: January 16, 2025
