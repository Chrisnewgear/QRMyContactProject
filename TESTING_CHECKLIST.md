# QR Phone App - Testing Checklist

## ✅ Pre-Flight Check

- [ ] Project builds without errors (⌘B)
- [ ] iPhone connected via USB
- [ ] iPhone selected as build destination
- [ ] Clean build folder (⇧⌘K)

---

## 📋 Test Scenarios

### Scenario 1: Generate QR Code
- [ ] Open app on Device A
- [ ] Fill in form:
  - [ ] First Name: "Juan"
  - [ ] Last Name: "Pérez"
  - [ ] Phone: "+525512345678"
  - [ ] Email: "juan@example.com" (optional)
- [ ] Tap "Guardar y generar QR"
- [ ] QR code displays on screen
- [ ] QR code is visible and clear

### Scenario 2: Scan QR Code (Basic)
- [ ] Open app on Device B
- [ ] Tap "Escanear QR"
- [ ] Grant camera permission when prompted
- [ ] Point camera at Device A's QR code
- [ ] Device vibrates (haptic feedback)
- [ ] iOS Contacts screen appears
- [ ] Grant contacts permission when prompted
- [ ] Verify pre-filled data:
  - [ ] First Name: "Juan"
  - [ ] Last Name: "Pérez"  
  - [ ] Phone: "+525512345678"
  - [ ] Email: "juan@example.com"
- [ ] Tap "Done" to save
- [ ] Contact saved successfully
- [ ] Scanner closes

### Scenario 3: Scan Without Email
- [ ] Device A: Create QR without email
- [ ] Device B: Scan the QR
- [ ] Contact form shows first name, last name, phone only
- [ ] Save contact successfully

### Scenario 4: Edit and Update
- [ ] Device A: Tap "Editar información"
- [ ] Change phone number
- [ ] Save again
- [ ] New QR code generated with updated info
- [ ] Device B: Scan new QR
- [ ] Verify updated phone number appears

### Scenario 5: Delete Data
- [ ] Tap "Eliminar datos"
- [ ] Confirm deletion
- [ ] Form appears empty
- [ ] Fill form again
- [ ] Generate new QR code

---

## 🐛 Debug Console Checks

When scanning, console should show:
```
🔍 Scanned QR Code: Juan\nPérez\n+525512345678\njuan@example.com
📦 Components count: 4
📦 Components: ["Juan", "Pérez", "+525512345678", "juan@example.com"]
👤 Creating contact: Juan Pérez, Phone: +525512345678, Email: juan@example.com
✅ Contact created, showing contact view controller
```

---

## ⚠️ Common Issues

### Camera doesn't activate
- **Check:** Settings → QRPhone → Camera = ON
- **Fix:** Reinstall app and allow permission

### Contact screen doesn't appear
- **Check:** Console logs for errors
- **Check:** Settings → QRPhone → Contacts = ON
- **Fix:** Reinstall app and allow permission

### QR code can't be scanned
- **Check:** Good lighting
- **Check:** QR code is large enough
- **Try:** Adjust distance from camera

### Wrong data in contact
- **Check:** Console logs - see what was scanned
- **Fix:** Make sure QR was generated with latest code changes

---

## ✨ Success Criteria

- ✅ QR code generated with all user data
- ✅ Camera scans QR successfully
- ✅ Haptic feedback on scan
- ✅ Contacts app opens automatically
- ✅ All fields pre-filled correctly
- ✅ Contact saves to iPhone contacts
- ✅ No crashes or errors

---

## 📸 Screenshots to Capture

1. Form filled with data
2. Generated QR code
3. Scanner view with camera active
4. iOS Contacts screen with pre-filled data
5. Saved contact in iPhone Contacts app

---

*Ready to test? Connect your iPhone and press ⌘R!*
