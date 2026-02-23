# 🏢 Oberoi Realty App

A high-end, feature-rich real estate application built with Flutter and Firebase. Designed to provide users with a premium "Midnight & Gold" aesthetic, this app seamlessly blends advanced property discovery tools with real-time communication.

---

## ✨ Core Features & Functionality

### 🗺️ Smart Interactive Map (`flutter_map_smart`)
*   **Property Markers**: View properties plotted accurately on an interactive map.
*   **Clustering**: Handles large datasets gracefully by grouping nearby properties when zoomed out.
*   **Location Awareness**: Integrates with device GPS to show properties near the user's current location.

### 🎙️ Intelligent Search & Discovery
*   **Voice-Activated Search**: Powered by `speech_to_text`, users can tap the microphone icon to dictate their search queries (e.g., "Show me villas in Mumbai").
*   **Animated UI**: Features a custom `RotatingSearchBar` that loops through suggested property types (Apartment, Villa, Office) to guide users, hiding seamlessly the moment typing or voice input begins.
*   **Animated Waveform**: A custom visualizer (`VoiceWave`) provides feedback while the app is actively listening.

### 📱 Story-Style Promotional Video Player
*   **Live Instagram Integration**: Connects to `https://avisaexperts.com/instaapi.php` to fetch live API tokens and dynamically pull the latest Instagram Reels.
*   **Sequential Playback**: Automatically advances through a playlist of videos, mimicking the Instagram Stories experience.
*   **Flicker-Free Transitions**: Utilizes a custom "Pre-load & Swap" strategy ensuring the video container remains visible and seamless during background initialization.
*   **Draggable & Magnetic**: A floating widget that users can drag across the screen, snapping to the left or right edges upon release.
*   **Dynamic Progress Bars**: Custom bottom progress indicators that reflect the current playlist state and playback progress.

### 💬 Real-Time Agent Chat
*   **Firestore Powered**: Instant messaging capabilities between property seekers and agents.
*   **Premium Custom UI**: Avoids standard chat clone layouts in favor of a clean, "Midnight & Deep Blue" squircle-based design for message bubbles.
*   **Unread Badges**: Real-time unread message counters integrated directly into the `MainNavigation` bottom bar.

### 🔔 Push & Local Notifications
*   **FCM Integration**: Fully configured for Firebase Cloud Messaging to receive background and foreground alerts.
*   **Local Rendering**: Uses `flutter_local_notifications` to display rich heads-up notifications when the app is active.

### 🔐 Secure Authentication Flow
*   **Google Sign-In**: Quick access using Google accounts.
*   **Guest Mode**: Optional "Continue as Guest" functionality.
*   **Global Navigation Key**: Ensures seamless redirection to the `LoginScreen` upon sign-out from anywhere in the app using BLoC listeners.

---

## 🛠️ Technology Stack & Architecture

### Frontend
*   **Framework**: Flutter (Dart)
*   **State Management**: 
    *   **BLoC (`flutter_bloc`)**: Used for complex, app-wide states like Authentication (`AuthBloc`) and Property Data (`PropertyBloc`).
    *   **Provider**: Used for injecting singleton services (like `FirebaseService`) into the widget tree.
*   **Media**: `chewie` & `video_player` for advanced video controls.
*   **UI/UX**: `flutter_animate` for micro-interactions and smooth transitions.

### Backend (Firebase BaaS)
*   **Authentication**: Firebase Auth (Google Provider).
*   **Database**: Cloud Firestore (Properties, Users, Chats, Feedback).
*   **Storage**: Firebase Cloud Storage (Property Images, User Avatars).
*   **Messaging**: Firebase Cloud Messaging (Node.js backend scripts handle trigger-based push notifications).

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version ^3.9.2 or higher)
*   Android Studio / VS Code
*   **Firebase Configuration**: You must generate a `google-services.json` file from your Firebase console and place it in the `android/app/` directory.

### Installation & Run

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd real_estate_owner_app
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app natively**:
    ```bash
    flutter run
    ```

---

## 🏗️ Project Structure Highlights
*   `lib/features/`: Modularized features.
    *   `/home`: Core discovery screen, rotating search bar, and property cards.
    *   `/map`: Integration with `flutter_map_smart`.
    *   `/chat`: Real-time messaging UI and Firebase listeners.
    *   `/promotion`: Advanced floating video player logic.
*   `lib/core/`: Application-wide services (`FirebaseService`, `NotificationService`, `AuthBloc`).
*   `lib/models/`: Strongly typed Dart data models matching Firestore schemas.

---

## 👨‍💻 Note on Customization
The app is currently branded as **Oberoi Realty**. Theme colors, API endpoints (like the Instagram fetcher), and Firebase configurations are deeply integrated but easily modifiable within `lib/main.dart` and the respective service files.
