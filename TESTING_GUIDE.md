# Thapar EduTube MVP - Testing Guide

## 📋 Overview
This document provides comprehensive testing procedures for the Thapar EduTube MVP. It includes manual tests, beta testing protocols, and performance benchmarks.

---

## 🧪 Manual Testing Procedures

### Test Environment Setup
```
Device: Android 8.0+ or iOS 13.0+
Network: Stable WiFi (10+ Mbps)
Flutter: 3.24+
Video files: Accessible from Google CDN
```

### Test Session Duration
**Recommended**: 15-20 minutes per tester

---

## 🏠 HomePage Testing

### Test 1: Course Card Display
**Objective**: Verify all courses are displayed correctly

**Steps**:
1. Launch app
2. Verify 5-8 CourseCard widgets are visible
3. Scroll through list to see all cards

**Expected Results**:
- [ ] All courses display (Numerical Analysis, Data Structures, Algorithms)
- [ ] Course titles are readable and bold
- [ ] Course descriptions are truncated at 2 lines
- [ ] Topic count badge shows (e.g., "5 topics")
- [ ] Colored accent bar appears on each card
- [ ] No layout overflow or text clipping

**Pass Criteria**: All items visible and readable

---

### Test 2: Navigation to PlayerPage
**Objective**: Verify tap on course card opens PlayerPage

**Steps**:
1. From HomePage, tap on "Numerical Analysis" card
2. Wait for navigation animation
3. Verify PlayerPage loads

**Expected Results**:
- [ ] Navigation is smooth (no jank)
- [ ] Back button appears in AppBar
- [ ] Course title shown in AppBar ("Numerical Analysis")
- [ ] First topic's first video loads and displays

**Pass Criteria**: Navigation succeeds within 500ms

---

## 🎬 PlayerPage Testing

### Test 3: Initial Video Playback
**Objective**: Verify video player initializes and auto-plays

**Steps**:
1. On PlayerPage, wait 2 seconds for video to load
2. Observe play/pause icon overlay
3. Wait for video to auto-play

**Expected Results**:
- [ ] Video loads and displays in 1-2 seconds
- [ ] Play icon appears initially (if not auto-playing)
- [ ] Video auto-plays after initialization
- [ ] No error messages displayed

**Pass Criteria**: Video plays without errors

---

### Test 4: Vertical Swipe (Same Topic)
**Objective**: Test up/down swipe to change videos within a topic

**Steps**:
1. On PlayerPage, watch video playing
2. Swipe UP (drag finger up)
3. Wait for next video to load
4. Swipe DOWN (drag finger down)
5. Verify previous video plays again

**Expected Results**:
- [ ] Swipe UP shows next video title before transition
- [ ] Next video auto-plays smoothly
- [ ] Swipe DOWN returns to previous video
- [ ] No lag or stutter (60fps smooth)
- [ ] Metadata updates correctly (e.g., "2/3 videos")

**Pass Criteria**: Smooth transitions, no crashes

---

### Test 5: Horizontal Swipe (Topic Navigation)
**Objective**: Test left/right swipe to change topics

**Steps**:
1. On PlayerPage, watch video 1 of Topic 1
2. Swipe to the LAST video of Topic 1 (using vertical swipes)
3. Swipe LEFT (drag finger left)
4. Wait for Topic 2 to load
5. Verify Topic 2's first video appears
6. Swipe RIGHT to go back to Topic 1

**Expected Results**:
- [ ] Swipe LEFT transitions to next topic smoothly
- [ ] Metadata updates to show new topic (e.g., "Topic 2: Linear Systems")
- [ ] Swipe RIGHT returns to previous topic
- [ ] Only works from topic boundaries (first/last video)
- [ ] New topic's first video auto-plays

**Pass Criteria**: Smooth topic transitions, gesture conflict resolved

---

### Test 6: Play/Pause Toggle
**Objective**: Test tap on video to toggle play/pause

**Steps**:
1. Video is playing
2. Tap on the video (center area)
3. Video should pause
4. Tap again
5. Video should resume

**Expected Results**:
- [ ] Play icon appears when paused
- [ ] Play icon disappears when playing
- [ ] Tap response is immediate (< 100ms)
- [ ] No video jump or seek

**Pass Criteria**: Consistent play/pause behavior

---

### Test 7: Progress Bar Display
**Objective**: Verify progress bar shows current/total time

**Steps**:
1. Video is playing
2. Observe progress bar at bottom
3. Watch for 5+ seconds
4. Verify time updates in real-time

**Expected Results**:
- [ ] Progress bar width increases as video plays
- [ ] Current time shows (e.g., "00:05")
- [ ] Total time shows (e.g., "08:45")
- [ ] Time updates every 1 second or more frequently
- [ ] Format is MM:SS

**Pass Criteria**: Accurate time tracking

---

### Test 8: Metadata Overlay
**Objective**: Verify video title and progress metadata

**Steps**:
1. On PlayerPage, observe bottom overlay
2. Note video title
3. Swipe to next video
4. Note new title and progress

**Expected Results**:
- [ ] Video title is visible and readable
- [ ] Title doesn't overlap with progress bar
- [ ] Title updates when swiping to new video
- [ ] Topic progress shows (e.g., "Topic 1/3")
- [ ] Video progress shows (e.g., "3/5 videos")

**Pass Criteria**: All metadata visible and accurate

---

### Test 9: Error Handling
**Objective**: Test app response to invalid/missing videos

**Steps**:
1. If network unavailable, try to load video
2. Observe error message

**Expected Results**:
- [ ] Error message appears with "Failed to load video"
- [ ] Error doesn't crash app
- [ ] Error shows network details
- [ ] Can navigate back or retry

**Pass Criteria**: Graceful error handling

---

## 📊 Performance Testing

### Test 10: 60fps Smoothness
**Objective**: Verify smooth 60fps on mid-range devices

**Equipment**:
- Mid-range Android: Snapdragon 665, 4GB RAM (e.g., Redmi Note 8)
- iOS: iPhone 11 or newer

**Steps**:
1. Enable Performance Monitor (Dev Tools)
2. Perform 10 vertical swipes rapidly
3. Perform 5 horizontal swipes
4. Observe frame rate in performance overlay

**Expected Results**:
- [ ] Frame rate stays at 60fps during swipes
- [ ] No dropped frames (< 2% frame drops)
- [ ] No visible stutter or jank
- [ ] Animations are smooth

**Pass Criteria**: 60fps maintained for 95% of swipes

---

### Test 11: Memory Stability
**Objective**: Verify app doesn't crash or memory leak over 30+ swipes

**Steps**:
1. Open Memory Monitor (Android Studio / Xcode)
2. Note initial memory usage
3. Perform 30 consecutive swipes (mix of vertical and horizontal)
4. Note memory usage after

**Expected Results**:
- [ ] No crashes during swipes
- [ ] Memory usage increases < 50MB
- [ ] No memory spikes or leaks
- [ ] App responds normally after 30 swipes
- [ ] Garbage collection works properly

**Pass Criteria**: No crashes, memory stable

---

### Test 12: Video Pre-loading
**Objective**: Verify background pre-loading reduces perceived lag

**Steps**:
1. Swipe to Topic 2's first video
2. Time how long until video appears
3. Compare with first load time

**Expected Results**:
- [ ] Second swipe feels faster than first swipe
- [ ] Next topic's video appears within 500ms of swipe
- [ ] No blocking/freezing during pre-load
- [ ] Pre-load happens silently in background

**Pass Criteria**: < 1 second load time for pre-loaded video

---

### Test 13: Network Performance
**Objective**: Verify playback quality over different networks

**Steps**:
1. Test over WiFi (10+ Mbps)
2. Test over 4G LTE
3. Test with throttled connection (5 Mbps simulated)

**Expected Results**:
- [ ] Video plays smoothly on WiFi (no buffering)
- [ ] Video plays on 4G (buffering < 2 seconds)
- [ ] 5 Mbps throttle: video starts in 2-3 seconds
- [ ] No crashes on network changes

**Pass Criteria**: Smooth playback on all networks

---

## 👥 Beta Testing Protocol

### Pre-Test Brief (5 minutes)
```
"This is an educational video player. Swipe UP/DOWN to watch next/prev video 
in the same topic. Swipe LEFT/RIGHT to explore new topics. Tap video to pause. 
Try for 10+ minutes and tell us what you like and what confuses you."
```

### Test Scenario (10-15 minutes)
1. Start on HomePage
2. Tap "Numerical Analysis" course
3. Watch 1-2 videos
4. Swipe to next video (up)
5. Swipe to previous video (down)
6. Swipe to next topic (left)
7. Swipe back to previous topic (right)
8. Try pausing/resuming
9. Switch to another course

### Post-Test Survey (5 minutes)
```
1. Did you understand the swipe gestures without explanation?
   [ ] Yes, immediately  [ ] After 1 swipe  [ ] Needed explanation  [ ] Confused

2. How smooth were the animations?
   [ ] Very smooth  [ ] Smooth  [ ] Some stuttering  [ ] Very choppy

3. Did the videos play without issues?
   [ ] Yes, always  [ ] Mostly  [ ] Some failed  [ ] Many failed

4. What did you like most?
   _________________________________________________________________

5. What was most confusing?
   _________________________________________________________________

6. What would you like to see next?
   _________________________________________________________________
```

### Success Metrics
- [ ] **Gesture Understanding**: 80%+ understood swipes without explanation
- [ ] **Smoothness**: 75%+ rated as "smooth" or better
- [ ] **Reliability**: 95%+ video playback success rate
- [ ] **Overall Satisfaction**: 7+/10 average rating

---

## 🔍 Edge Cases to Test

### Test 14: Single Video Topic
**Steps**:
1. Find topic with only 1 video
2. Try to swipe up/down

**Expected**: No transition, stays on same video

---

### Test 15: Rapid Consecutive Swipes
**Steps**:
1. Swipe up/down rapidly (5 swipes in 2 seconds)
2. Observe response

**Expected**: App handles rapid swipes smoothly, no crashes

---

### Test 16: Orientation Change
**Steps**:
1. Rotate device while video playing
2. Observe app response

**Expected**: Video resizes, maintains playback, no crash

---

### Test 17: App Resume from Background
**Steps**:
1. Start playing video
2. Press home button (minimize app)
3. Wait 10 seconds
4. Reopen app

**Expected**: Video paused, can resume, no crash

---

### Test 18: Low Battery
**Steps**:
1. With low battery mode on (< 20%)
2. Use app normally

**Expected**: App works, may have reduced quality/60fps

---

## 📝 Test Results Template

```
Tester Name: ________________________
Device: ________________________
OS Version: ________________________
Network: WiFi / 4G / 5G
Session Duration: ________________________

Test Results:
[ ] Homepage displays correctly
[ ] Navigation to PlayerPage works
[ ] Video playback starts
[ ] Vertical swipes work
[ ] Horizontal swipes work
[ ] Play/pause toggle works
[ ] Progress bar visible
[ ] Metadata visible
[ ] 60fps smooth (observed)
[ ] No crashes during 30 swipes
[ ] Error handling graceful

Issues Found:
_________________________________________________________________
_________________________________________________________________

Feedback:
_________________________________________________________________
_________________________________________________________________

Overall Rating: ___/10
```

---

## 🚀 Performance Benchmarks

**Target Metrics**:
| Metric | Target | Acceptable | Warning |
|--------|--------|-----------|---------|
| First Video Load | < 1s | < 2s | > 2s ❌ |
| Swipe to Next Video | < 500ms | < 800ms | > 800ms ❌ |
| Frame Rate | 60fps | > 55fps avg | < 50fps ❌ |
| Memory Usage | < 150MB | < 200MB | > 250MB ❌ |
| Crash Rate | 0% | < 1% | > 1% ❌ |
| Video Play Success | 100% | > 95% | < 95% ❌ |

---

## ✅ Sign-Off Checklist

- [ ] All manual tests passed
- [ ] Performance benchmarks met
- [ ] Beta testers (5+) tested successfully
- [ ] 80%+ understood gestures
- [ ] Zero crashes in 15-minute session
- [ ] All metadata displays correctly
- [ ] No major bugs identified

**Ready for Production**: YES / NO

**Sign-Off Date**: ________________________

---

**Version**: 1.0 MVP
**Last Updated**: November 6, 2025
