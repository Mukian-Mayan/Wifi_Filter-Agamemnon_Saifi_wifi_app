# Saifi

A cross platform WiFi management and security app built with Flutter. It scans the
networks around you, scores each one for speed, strength, safety, reliability,
usability and traffic, flags the risky ones, and remembers the networks you use
often so it can rate and recommend them over time.

## What is inside

- 13 screens, all wrapped in a SingleChildScrollView with no overflows.
- A futuristic dark first theme with a working light theme. Three accent colours
  (cyan, violet, coral) over a black and white base. Five colours in total.
- Live nearby scanning on Android. On iOS and other platforms it reads the
  connected network and falls back to sample data, always telling the user what
  it is showing.
- A fast.com style speed test with a live gauge and chart. Real download, upload
  and ping when online, a simulated run when offline.
- A heuristic risk engine that flags open networks, weak encryption, hidden
  names, possible evil twins and bait names, plus a VPN check.
- Auto rating, auto comment and auto recommendation for saved networks, stored
  locally with shared_preferences.
- Search, a full filter screen, an animated signal radar, analytics charts and a
  safety guide.

## Folders

- lib/main.dart sets up Provider, the themes and all named routes.
- lib/pages holds every screen.
- lib/components holds every reusable widget plus the theme, models, services and
  app state.

## Setup

1. Create a fresh Flutter project, then drop in the lib folder and pubspec.yaml.
2. Run flutter pub get.
3. Add the permissions below, then flutter run.

### Android (android/app/src/main/AndroidManifest.xml)

Add inside the manifest tag, above application:

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" android:usesPermissionFlags="neverForLocation"/>

Set minSdkVersion to at least 21 in android/app/build.gradle.

### iOS (ios/Runner/Info.plist)

Add:

    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Saifi uses location to read nearby WiFi details.</string>

To read the connected network name on iOS you also need the Access WiFi
Information capability turned on in Xcode for the Runner target.

## Honest limits

- Nearby network scanning is an Android only feature. Apple gives apps no public
  way to list surrounding networks, so on iOS Saifi shows the connected network
  plus sample data and says so.
- A router street address is not available from the operating system. Saifi can
  store your device GPS position at scan time, the encryption type, MAC, vendor
  guessed from the MAC, signal, band and channel.
- The risk engine scores and warns. It does not block an attacker. Treat it as a
  smart second opinion, not a firewall.

## Note

The code was written carefully by hand. If a plugin has shifted its API since
these versions, a small tweak on that one call may be needed. The pinned
versions in pubspec.yaml match the code as written.
