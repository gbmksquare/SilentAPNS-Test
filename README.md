# Silent APNS-Test

This is a sample application and script to test APNS silent notifications.

To receive remote notifications, configure certificates and provisioning profiles in project settings.

## Sending Notifications

1. Setup bundle identifier, certificates, and provisioning profiles.

2. Export APNS certificates from the keychain in `.p12` format.

3. Drag and drop certificates to project navigator.

4. Add the certificates in `Build Phases` -> `Copy Bundle Resources`.

5. Fill in certificate names and password in function `createPusher` in `MainViewController`.