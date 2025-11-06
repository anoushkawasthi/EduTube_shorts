# Thapar EduTube MVP - Architecture Overview

## 🏛️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                          │
│  ┌─────────────────────────────────────────────────────────┤
│  │ HomePage: Course Discovery                               │
│  │ ├─ AppBar (Thapar EduTube branding)                     │
│  │ ├─ ListView (CourseCard widgets)                        │
│  │ └─ Navigation to PlayerPage on tap                      │
│  └─────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────┤
│  │ PlayerPage: Nested Swipe Interface                       │
│  │ ├─ Horizontal PageView (Topics)                         │
│  │ │  └─ Vertical PageView (Videos)                        │
│  │ │     └─ VideoPlayerItem widget                         │
│  │ ├─ Metadata Overlay (Topic, Progress)                   │
│  │ └─ Navigation Hints (Swipe indicators)                  │
│  └─────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────┤
│  │ VideoPlayerItem: Video Playback                          │
│  │ ├─ VideoPlayerController (video_player package)         │
│  │ ├─ Play/Pause toggle                                    │
│  │ ├─ Progress bar with timeline                           │
│  │ └─ Metadata: Title, current/total time                  │
│  └─────────────────────────────────────────────────────────┘
│
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│               Data Layer (Hard-coded MVP)                    │
│  ┌─────────────────────────────────────────────────────────┤
│  │ CourseData: Static course metadata                       │
│  │ ├─ 3 Courses (UCS101, UCS102, AL)                       │
│  │ ├─ 8 Topics total                                       │
│  │ └─ 20+ Videos with URLs (public CDN)                    │
│  └─────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────┤
│  │ Models: Data structures                                  │
│  │ ├─ Course (id, title, description, topics[])            │
│  │ ├─ Topic (id, title, videos[])                          │
│  │ └─ Video (id, title, url, duration, description)        │
│  └─────────────────────────────────────────────────────────┘
│
│  ┌─────────────────────────────────────────────────────────┤
│  │ VideoPreloader: Background pre-initialization            │
│  │ └─ Cache preloaded controllers for smooth swiping       │
│  └─────────────────────────────────────────────────────────┘
│
└─────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│              External Resources (CDN)                        │
│  ┌─────────────────────────────────────────────────────────┤
│  │ Google public video library (sample MP4 files)           │
│  │ URL: https://commondatastorage.googleapis.com/...       │
│  └─────────────────────────────────────────────────────────┘
│
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### User Journey: HomePage → PlayerPage → Video

```
1. App Starts
   ├─ main() → MyApp()
   ├─ MyApp → MaterialApp (theme: Thapar branding)
   └─ home: HomePage()

2. HomePage Loads
   ├─ CourseData.courses fetched (static)
   ├─ ListView.builder renders CourseCard widgets
   └─ Each card displays: title, description, topic count

3. User Taps Course Card
   ├─ onTap callback triggered
   ├─ Navigator.push(MaterialPageRoute)
   └─ PlayerPage(courseId: course.id)

4. PlayerPage Initializes
   ├─ _PlayerPageState.initState()
   ├─ CourseData.getCourseById(courseId) → Course object
   ├─ Create PageController (horizontal for topics)
   ├─ Create Map<topicIndex, PageController> (vertical for videos)
   └─ Pre-load first topic's videos

5. PlayerPage Renders
   ├─ Scaffold with AppBar (course title)
   ├─ PageView.builder (horizontal, topics)
   │  ├─ For each topic index:
   │  ├─ _buildTopicPage(topicIndex)
   │  │  ├─ GestureDetector (absorb gestures)
   │  │  ├─ Stack with:
   │  │  │  ├─ PageView.builder (vertical, videos)
   │  │  │  │  ├─ For each video in topic:
   │  │  │  │  ├─ _buildVideoPage(topic, videoIndex, controller)
   │  │  │  │  └─ VideoPlayerItem(video, isVisible)
   │  │  │  ├─ Metadata overlay (topic, progress)
   │  │  │  └─ Navigation hints
   │  │  └─ onPageChanged → _preloadNextTopicVideos()
   │  └─ When user swipes:
   │     ├─ Vertical: Inner PageView changes video
   │     ├─ Horizontal: Outer PageView changes topic
   │     └─ Pre-loader starts loading next topic's videos

6. Video Loads and Plays
   ├─ VideoPlayerItem.initState()
   ├─ VideoPlayerController.networkUrl(video.url)
   ├─ controller.initialize() (async)
   ├─ setState() → UI updates with video
   ├─ widget.isVisible=true → controller.play()
   └─ FutureBuilder shows loading → video → error handling

7. User Interacts
   ├─ Tap video: _togglePlayPause()
   ├─ Swipe up: VideoPageView changes page
   ├─ Swipe down: VideoPageView changes page (prev)
   ├─ Swipe left: TopicPageView changes page
   └─ Swipe right: TopicPageView changes page (prev)

8. Video State Management
   ├─ VideoPlayerItem.didUpdateWidget() watches isVisible
   ├─ Became visible: controller.play()
   ├─ Became hidden: controller.pause() (save resources)
   ├─ Video manager disposes controller.dispose()
   └─ Pre-loaded controller stays in cache until cleared
```

---

## 🧠 State Management

### HomePage State
- **Stateless Widget**: No state, just renders data from CourseData

### PlayerPage State
- **Stateful Widget** (_PlayerPageState)
- **State Variables**:
  - `course`: Course object from CourseData
  - `_horizontalController`: PageController for topics
  - `_verticalControllers`: Map<int, PageController> for videos per topic

### VideoPlayerItem State
- **Stateful Widget** (_VideoPlayerItemState)
- **State Variables**:
  - `_controller`: VideoPlayerController
  - `_initializeVideoPlayer`: Future for initialization

### Lifecycle
```
AppStart
  ↓
HomePage (init widgets)
  ├─ CourseCard tapped
  ↓
PlayerPage (create PageControllers)
  ├─ Topic page changed
  ├─ Pre-load next topic
  ↓
VideoPlayerItem (init controller)
  ├─ Video loaded
  ├─ Auto-play or show play button
  ├─ User taps or swipes
  ├─ Page changes (Visibility change)
  ├─ didUpdateWidget: play/pause based on isVisible
  ↓
Dispose (when leaving app)
  └─ All controllers disposed
```

---

## 🎮 Gesture Handling Strategy

### Problem: Gesture Conflict
When nested PageViews (horizontal + vertical) both respond to gestures, it's unclear which should win.

**Solution: Vertical Priority**
```dart
// Outer PageView (Horizontal Topics)
PageView(scrollDirection: Axis.horizontal)

// Inner PageView (Vertical Videos) has priority
PageView(scrollDirection: Axis.vertical, physics: PageScrollPhysics())

// GestureDetector wraps inner to absorb and prioritize
GestureDetector(
  onVerticalDragDown: (_) => {},  // Prioritize vertical
  child: Stack(
    children: [
      // Inner PageView here
    ]
  )
)
```

**Result**:
- User swipe up/down: **Always** affects vertical PageView (videos)
- User swipe left/right: **Only** affects horizontal PageView when at topic boundary
- No ambiguity or conflicting gestures

---

## ⚡ Performance Optimizations

### 1. Pre-loading Strategy
```dart
// When user swipes to new topic:
_preloadNextTopicVideos(topicIndex) {
  // Pre-load first video of next topic
  if (topicIndex + 1 < topics.length) {
    VideoPreloader.preloadVideo(topics[topicIndex + 1].videos[0])
  }
  // Pre-load first video of prev topic
  if (topicIndex - 1 >= 0) {
    VideoPreloader.preloadVideo(topics[topicIndex - 1].videos[0])
  }
}
```

**Benefit**: Next swipe feels instant (controller already initialized)

### 2. Visibility-Driven Lifecycle
```dart
didUpdateWidget(VideoPlayerItem oldWidget) {
  // Became visible: resume playback
  if (widget.isVisible && !oldWidget.isVisible) {
    _controller.play()
  }
  // Became hidden: pause to save battery + CPU
  else if (!widget.isVisible && oldWidget.isVisible) {
    _controller.pause()
  }
}
```

**Benefit**: Only visible video plays, saves battery and CPU

### 3. ValueKey for Video Tracking
```dart
VideoPlayerItem(
  key: ValueKey('${topic.id}_${video.id}'),  // Unique per video
  video: video,
  isVisible: isVisible,
)
```

**Benefit**: Flutter can track which video is playing even after swipes

---

## 📦 Package Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  video_player: ^2.9.3  # Core video playback

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Why video_player?
- ✅ Official Flutter package (well-maintained)
- ✅ Supports NetworkUrl (cloud videos)
- ✅ Handles platform differences (Android/iOS)
- ✅ Good performance for streaming
- ✅ Extensive API (play, pause, seek, listen to events)

---

## 🔐 Security Notes (MVP)

### Current State
- ❌ No authentication (hard-coded data only)
- ❌ No authorization checks
- ❌ Videos served from public Google CDN (no access control)
- ❌ No content protection

### Future (Phase 2)
- ✅ Firebase Auth with custom tokens
- ✅ Firebase App Check (prevent script access)
- ✅ Firestore security rules (write: false)
- ✅ Cloud Functions for admin tasks
- ✅ Signed URLs for video access control

---

## 🧩 Component Diagram

```
┌────────────────────────────────────────────────────────────┐
│                      MyApp (Root)                           │
├────────────────────────────────────────────────────────────┤
│  - Configures MaterialApp with Thapar theme               │
│  - home: HomePage()                                        │
└──────────┬───────────────────────────────────────────────┘
           │
           ├─→ HomePage
           │   ├─ Scaffold
           │   ├─ AppBar (Thapar EduTube)
           │   └─ ListView.builder
           │       └─ CourseCard × N
           │           └─ onTap → Navigator.push(PlayerPage)
           │
           └─→ PlayerPage
               ├─ Scaffold
               ├─ AppBar (Course title)
               └─ PageView.builder (horizontal)
                   └─ _buildTopicPage × Topics
                       ├─ Stack
                       ├─ PageView.builder (vertical)
                       │   └─ _buildVideoPage × Videos
                       │       └─ VideoPlayerItem
                       │           ├─ VideoPlayer
                       │           ├─ Play/Pause overlay
                       │           └─ Progress bar
                       ├─ TopicMetadata overlay
                       └─ NavigationHint
```

---

## 🔄 Future Integration Points

### Phase 2: Backend Integration
```
Current: CourseData.courses (static)
Future: Firestore.collection('courses').get()

Current: Hard-coded video URLs
Future: Cloud Storage signed URLs from Firestore references

Current: No upload
Future: Cloud Functions + Cloud Storage + FFmpeg processing
```

---

## 📝 Code Quality

- **Null Safety**: Full null safety enabled
- **Linting**: flutter_lints enabled
- **Code Organization**: Separated by feature (pages, widgets, models, data)
- **Error Handling**: Try-catch in video initialization, error UI fallback
- **Accessibility**: Text labels for widgets (to be enhanced in Phase 2)

---

## 🚀 Deployment

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build IPA (iOS)
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### App Size
- **APK**: ~50-70MB (with video_player native binaries)
- **IPA**: ~80-100MB
- **Download**: 15-30MB over network (compressed)

---

**Version**: 1.0 MVP
**Last Updated**: November 6, 2025
