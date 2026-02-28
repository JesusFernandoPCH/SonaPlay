# SonaPlay: Premium Mobile Audio Experience 🎵

SonaPlay is a high-performance, modern music player for Android, engineered with **Flutter** to deliver a fluid and visually stunning experience. The project focuses on handling large local music libraries (+1,000 files) with zero latency, utilizing a custom reactive architecture and premium design principles.

---

<p>
Descarga el Demo totalmente seguro desde <a href="https://www.mediafire.com/file/b0u8i79c52h4i9f/SonaPlay.apk/file">SonaPlay.apk</a>
</p>

## ✨ Key Features

### 🎨 Visual Excellence
- **Glassmorphism UI**: A sophisticated design language using real-time blurs, vibrant radial gradients, and semi-transparent elements for a premium "Apple-style" aesthetic.
- **Dynamic Micro-animations**: Smooth transitions and interactive feedback that make the app feel alive and responsive.
- **Context-Aware Styling**: Visual elements that adapt to artwork colors for a cohesive experience.

### 🎧 Intelligent Playback
- **High-Fidelity Player**: Full control over playback with support for high-quality audio formats.
- **Playback Persistence**: State matching that remembers your shuffle settings, repeat modes, and last-played song even after app restarts.
- **Smart Shuffle**: An optimized algorithm that ensures a fresh listening experience every time you start a new playlist.

### 📂 Advanced Library Management
- **Folder Browsing**: Direct access to internal storage structures, allowing users to browse and play music exactly how it's organized on their device.
- **Metadata Editor**: In-app editing for song titles, artists, albums, and custom artwork selection from the gallery.
- **Safety Features**: "Recently Deleted" and "Hidden Files" recovery systems to protect and manage your music library without accidental data loss.
- **Multi-Select Workflow**: Bulk actions for playlist management, favoriting, and organization.

---

## 🚀 Technical Excellence

### 1. Hybrid Reactive Architecture
The app implements a "First-Paint Fast" strategy using a custom **Streaming + Persistence** layer:
- **Instant Emissions**: Cached metadata is emitted immediately from **Hive** for a sub-100ms startup feeling.
- **Background Sync**: Real-time file system watchers update the library dynamically without blocking the main UI thread.

### 2. Multi-threaded Performance
To maintain 60/120 FPS during heavy library operations:
- **Isolates**: Metadata extraction and complex object mapping are offloaded to background threads (Dart Isolates).
- **Repaint Boundaries**: Optimized widget tree to minimize pixel-painting overhead in complex glassmorphism views.

### 3. State Management & Persistence
- **Riverpod**: Modular and testable state management following unidirectional data flow.
- **Hive**: Ultra-fast NoSQL local database (pure Dart) for millisecond-level metadata access, significantly outperforming traditional SQLite implementations for audio metadata.

---

## 🛠 Tech Stack

- **Frontend**: Flutter / Dart
- **State Management**: Riverpod 2.0
- **Audio Engine**: Just Audio / Audio Service
- **Persistence**: Hive (NoSQL) / Shared Preferences
- **Icons & Fonts**: Google Fonts (Inter/Outfit) / Material Icons

---

## 📐 Intellectual Property & Privacy

This project is part of a professional portfolio focused on **Mobile Architecture** and **Modern UX**. It adheres to high standards of clean code, SOLID principles, and modular design. 

*Developed with a focus on extreme performance and visual perfection.*
