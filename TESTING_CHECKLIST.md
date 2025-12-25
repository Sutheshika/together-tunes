# ✅ Testing Checklist - Together Tunes

## Pre-Launch Verification

### Backend Server Tests

#### Connection & Health
- [ ] Server starts without errors: `node sync_server.js`
- [ ] Server listens on port 3001
- [ ] Health endpoint responds: `curl http://localhost:3001/health`
- [ ] Health includes: status, timestamp, rooms count, users count

#### Authentication Tests
- [ ] Register new user: `POST /api/auth/register`
  - [ ] Email validation works
  - [ ] Password hashing works
  - [ ] Duplicate user prevented
- [ ] Login returns user data
- [ ] Wrong credentials rejected
- [ ] Session persists

#### Room Management
- [ ] Get all rooms: `GET /api/rooms`
  - [ ] Returns array of rooms
  - [ ] Each room has id, name, host, memberCount
- [ ] Create new room: `POST /api/rooms`
  - [ ] Room appears in list
  - [ ] Host is set correctly
  - [ ] Member list initialized

#### Socket.io Events
- [ ] Client connects successfully
- [ ] `join-room` event received
- [ ] `leave-room` event received
- [ ] Broadcasting works (message from one user reaches others)
- [ ] Room isolation (users in different rooms don't see each other's events)

---

### Frontend Tests

#### App Launch
- [ ] App starts without crashes
- [ ] Welcome screen displays
- [ ] Navigation bottom bar appears
- [ ] Theme applies correctly

#### Authentication Flow
- [ ] Welcome screen shows login/register options
- [ ] Register form validates input
  - [ ] Empty fields show errors
  - [ ] Password confirmation matches
- [ ] Register creates account and logs in
- [ ] Login with correct credentials works
- [ ] Login with wrong credentials shows error
- [ ] After login, user stays logged in

#### Navigation
- [ ] Bottom navigation tabs work
- [ ] Home screen loads without errors
- [ ] Rooms screen loads without errors
- [ ] Playlists screen loads without errors
- [ ] Profile screen loads without errors
- [ ] Tab switching is smooth

#### Rooms Screen
- [ ] Room list displays
- [ ] Each room shows: name, host, members, current song
- [ ] "Live" badge shows for active rooms
- [ ] Join button responsive
- [ ] Create room dialog opens
- [ ] Clicking join navigates to room player

---

### Music Player Tests

#### Player Display
- [ ] Album art displays correctly
- [ ] Song title and artist show
- [ ] Duration displays in MM:SS format
- [ ] Current position displays in MM:SS format
- [ ] Progress slider is visible

#### Basic Playback
- [ ] Play button toggles playback (host only)
- [ ] Pause button works (host only)
- [ ] Progress slider updates during playback
- [ ] Duration is correct
- [ ] Song continues playing while other actions occur

#### Seeking (Host Only)
- [ ] Slider is draggable for host
- [ ] Slider is disabled for guest
- [ ] Seeking changes position correctly
- [ ] Visual feedback during seek

#### Animations
- [ ] Album art rotates when playing
- [ ] Pulse animation works
- [ ] Animations stop when paused
- [ ] Smooth transitions

---

### Real-time Sync Tests

#### Two Users in Same Room

**Setup**: 
- Start backend server
- Device 1 (Host): Join room
- Device 2 (Guest): Join same room

**Test Sequence**:
- [ ] Guest sees room join notification
- [ ] Guest sees updated member list with host
- [ ] Member list shows host with "listening" status
- [ ] Member avatars display
- [ ] Member count is accurate

**Play Event**:
- [ ] Host clicks Play
- [ ] Guest sees playback start (NO manual action needed)
- [ ] Guest's progress slider starts moving
- [ ] Position stays synchronized (within 1 second)
- [ ] Both users hear audio (if device speakers on)

**Pause Event**:
- [ ] Host clicks Pause
- [ ] Guest's playback stops (automatically)
- [ ] Both positions freeze
- [ ] No manual action needed on guest device

**Seek Event**:
- [ ] Host drags progress slider to 30 seconds
- [ ] Guest's slider instantly jumps to ~30 seconds
- [ ] Playback continues from that position
- [ ] Audio on both devices aligned

**Resume Event**:
- [ ] (From paused state) Host clicks Play
- [ ] Guest's playback resumes from same position
- [ ] Position continues advancing together

**Multiple Pauses/Plays**:
- [ ] Repeat play/pause multiple times
- [ ] Sync remains stable
- [ ] No desynchronization over time

---

### Chat Tests

**In Room**:
- [ ] Chat input field is visible
- [ ] Send button responsive
- [ ] Typing shows message in input
- [ ] Pressing enter sends message
- [ ] Message appears instantly for all users
- [ ] Messages show sender name
- [ ] Sender's message shows on right (visually different)
- [ ] Others' messages show on left
- [ ] Messages scroll to newest automatically
- [ ] Chat scroll is smooth

**Chat Features**:
- [ ] Empty messages prevented
- [ ] Emoji support works
- [ ] Long messages wrap correctly
- [ ] Multiple messages show in order
- [ ] Message timestamps optional but available

---

### Member Management Tests

**Joining Room**:
- [ ] New member appears in member list
- [ ] Member count increases
- [ ] "User joined" notification appears
- [ ] Member avatar shows

**Leaving Room**:
- [ ] Leaving member disappears from list
- [ ] Member count decreases
- [ ] "User left" notification appears
- [ ] Other users not affected

**Status Indicators**:
- [ ] Green dot = online
- [ ] Accent color = listening/in room
- [ ] Tooltips show status on hover

**Multiple Members**:
- [ ] 3+ users in room works
- [ ] All see all others
- [ ] Sync works with multiple guests
- [ ] Chat broadcasts to all

---

### Performance Tests

**Audio Quality**:
- [ ] Audio sounds clear without distortion
- [ ] Volume control works (0-100%)
- [ ] No audio stuttering during playback
- [ ] No audio lag between devices (<500ms)

**Memory Usage**:
- [ ] App doesn't leak memory
- [ ] Leave room frees resources
- [ ] Multiple room switches don't cause crashes
- [ ] Chat history doesn't cause slowdown

**CPU Usage**:
- [ ] Idle CPU <5%
- [ ] During playback CPU <15%
- [ ] Smooth animations without jank
- [ ] No frame drops visible

**Network**:
- [ ] Works on WiFi
- [ ] Works on cellular (with delay)
- [ ] Reconnects after network interruption
- [ ] Handles momentary lag gracefully

---

### Edge Case Tests

**Network Issues**:
- [ ] App handles server disconnect gracefully
- [ ] Auto-reconnect after network recovery
- [ ] Shows loading state during reconnection
- [ ] No data loss on reconnect

**Multiple Rooms**:
- [ ] Create 2 rooms
- [ ] Have users in both simultaneously
- [ ] Events don't leak between rooms
- [ ] Leave one room, stay in other

**Rapid Interactions**:
- [ ] Rapid play/pause works
- [ ] Rapid seeking works
- [ ] Rapid messages send correctly
- [ ] No race conditions or conflicts

**Long Duration**:
- [ ] Keep app open for 30+ minutes
- [ ] Music plays without stopping
- [ ] Sync remains stable
- [ ] No memory leaks
- [ ] Chat continues working

---

### UI/UX Tests

**Visual Design**:
- [ ] Glass-morphism effects visible
- [ ] Gradient backgrounds render properly
- [ ] Colors are visually appealing
- [ ] Text is readable on all backgrounds
- [ ] Icons are clear and intuitive

**Responsiveness**:
- [ ] Phone portrait mode works
- [ ] Phone landscape mode works (if supported)
- [ ] Tablet layout works
- [ ] Text doesn't overflow
- [ ] Buttons are tappable (>44x44 pts)

**Animations**:
- [ ] Smooth page transitions
- [ ] No jank during animations
- [ ] Loading spinners animate correctly
- [ ] Fade-in effects are smooth

**Accessibility**:
- [ ] Text contrast is sufficient
- [ ] Buttons have sufficient size
- [ ] Touch targets are adequate
- [ ] Loading states are clear

---

### Device Compatibility Tests

- [ ] Android 8.0+ works
- [ ] iOS 12.0+ works
- [ ] Physical device works
- [ ] Emulator works
- [ ] Multiple screen sizes work
- [ ] Different device orientations work

---

### Security Tests

**Authentication**:
- [ ] Passwords hashed in backend
- [ ] Plain text password never logged
- [ ] Session persists securely
- [ ] Logout clears session

**Permissions**:
- [ ] Host can control playback
- [ ] Guest cannot control playback
- [ ] Only room members can access room
- [ ] Users can't access other rooms' state

**Input Validation**:
- [ ] Empty inputs rejected
- [ ] Malicious input handled safely
- [ ] XSS prevention in chat
- [ ] No SQL injection possible

---

### Documentation Tests

- [ ] QUICK_START.md instructions work exactly as written
- [ ] DEVELOPER_GUIDE.md code examples run
- [ ] API endpoints documented and working
- [ ] Error codes documented
- [ ] Examples are current and correct

---

## Test Execution Order

### Phase 1: Backend (30 minutes)
1. Start server and verify health
2. Test all API endpoints
3. Test Socket.io connections
4. Test room creation and joining

### Phase 2: Frontend (45 minutes)
1. Launch app and verify no crashes
2. Test authentication flow
3. Test navigation
4. Test music player UI

### Phase 3: Real-time Sync (60 minutes)
1. Single device: play/pause/seek
2. Two devices: join same room
3. Two devices: full sync test
4. Three+ devices: stress test

### Phase 4: Chat & Members (30 minutes)
1. Chat message delivery
2. Member list accuracy
3. Join/leave notifications
4. Multiple members handling

### Phase 5: Performance & Edge Cases (30 minutes)
1. Performance metrics
2. Network interruptions
3. Rapid interactions
4. Long-duration stability

### Phase 6: Polish (20 minutes)
1. Visual design verification
2. Responsiveness check
3. Accessibility audit
4. Final smoke tests

**Total Time**: ~3-4 hours for complete testing

---

## Test Results Template

```markdown
### Test: [Test Name]
- **Device**: [iPhone 13 / Pixel 5 / Emulator]
- **Build**: [Debug / Release]
- **Date**: [Date]
- **Tester**: [Name]

**Result**: ✅ PASS / ⚠️ WARN / ❌ FAIL

**Details**:
[Description of what happened]

**Screenshots/Logs**:
[Attach if needed]

**Notes**:
[Any additional observations]
```

---

## Known Limitations

- ❌ Web version not fully tested (Flutter web support varies)
- ❌ Audio doesn't work on some Android devices (audio permissions)
- ❌ Seeking to future doesn't download (streaming only)
- ⚠️ Sync accuracy depends on network latency
- ⚠️ Works best on WiFi (cellular has delays)

---

## Success Criteria

For launch readiness, need:
- ✅ 95%+ tests passing
- ✅ No crashes during 30-minute session
- ✅ Sync latency <500ms
- ✅ All documentation accurate
- ✅ Performance metrics acceptable
- ✅ Security checks passed
- ✅ Visual design polished

---

**Ready to test? Let's go! 🚀**