# 📦 Inventory Management App

A fully functional **Inventory Management App** built with **Flutter** and **Firebase Firestore** that allows users to perform Create, Read, Update, and Delete (CRUD) operations on inventory items with real-time data synchronization.

## 🎯 Project Overview

This app was developed as part of **In-Class Activity #15** for the Mobile Application Development course. It demonstrates proficiency in Flutter development, Firebase integration, and implementing complex UI/UX patterns.

## ✨ Core Features

### Basic CRUD Operations
- ✅ **Create**: Add new inventory items with name, quantity, price, and category
- ✅ **Read**: View all inventory items in real-time with automatic updates
- ✅ **Update**: Edit existing item details
- ✅ **Delete**: Remove items individually or in bulk

### Enhanced Features Implemented

**Note**: We implemented the **two features specifically recommended by the professor** for their practicality and learning value!

#### 1. Advanced Search & Filtering (Professor Recommended ⭐)
- **Search Bar**: Real-time search functionality to filter items by name
- **Category Filters**: Filter chips to view items by specific categories
- **Smart Filtering**: Automatically updates results as you type

#### 2. Data Insights Dashboard (Professor Recommended ⭐)
- **Total Items Count**: Display the total number of unique items
- **Total Inventory Value**: Calculate and show sum of (quantity × price) for all items
- **Out of Stock Alerts**: List all items with zero quantity
- **Low Stock Warnings**: Highlight items with quantity < 10
- **Category Breakdown**: Show item count and value per category
- **Top 5 Most Valuable Items**: Ranked list by total value

#### 3. Bulk Operations (Bonus Feature! 🎁)
- **Multi-Select Mode**: Long-press any item to enter selection mode
- **Bulk Delete**: Select multiple items and delete them all at once
- **Visual Feedback**: Checkboxes appear in selection mode for easy selection

## 🏗️ App Architecture

```
lib/
├── main.dart                           # App entry point with Firebase initialization
├── models/
│   └── item.dart                       # Item data model with toMap/fromMap
├── services/
│   └── firestore_service.dart          # All Firebase/Firestore operations
└── screens/
    ├── inventory_home_page.dart        # Main screen with item list
    ├── add_edit_item_screen.dart       # Form for adding/editing items
    └── dashboard_screen.dart           # Analytics and insights screen
```

## 📱 Screenshots & Features

### Home Screen
- Real-time item list with StreamBuilder
- Search bar for instant filtering
- Category filter chips
- Color-coded stock status indicators (Green: In Stock, Orange: Low Stock, Red: Out of Stock)
- Swipe-to-delete with undo option
- Floating action button to add new items

### Add/Edit Screen
- Form validation for all fields
- Category picker with predefined options
- Real-time total value calculation
- Update or delete existing items

### Dashboard Screen
- Summary cards with key metrics
- Category breakdown with counts and values
- Top 5 most valuable items
- Out of stock items list
- Low stock items list

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- FlutterFire CLI

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <your-repo-url>
   cd inclass15
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Go to [Firebase Console](https://console.firebase.google.com/)
   
   b. Create a new project named `inventory-app-yourname`
   
   c. Enable Firestore Database in **test mode**:
      - Go to Firestore Database
      - Click "Create database"
      - Select "Start in test mode"
      - Choose a location
   
   d. Install FlutterFire CLI:
      ```bash
      dart pub global activate flutterfire_cli
      ```
   
   e. Configure Firebase for your Flutter app:
      ```bash
      flutterfire configure
      ```
      - Select your Firebase project
      - Select platforms (Android, iOS, Web)
      - This generates `firebase_options.dart`

4. **Run the App**
   ```bash
   flutter run
   ```

### Building Release APK

To build a release APK for submission:

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## 🔥 Firebase Configuration

### Firestore Rules (For Production)

Update your Firestore security rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /items/{itemId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Firestore Structure

```
items (collection)
  └── {itemId} (document)
        ├── name: string
        ├── quantity: number
        ├── price: number
        ├── category: string
        └── createdAt: timestamp
```

## 📋 Feature Checklist

### Core Requirements
- [x] Create new items
- [x] Read/Display all items with real-time updates
- [x] Update existing items
- [x] Delete items
- [x] Firebase Firestore integration
- [x] StreamBuilder for real-time data
- [x] Proper data model with toMap/fromMap
- [x] Service layer for database operations

### Enhanced Features (2 Required)
- [x] **Advanced Search & Filtering**
  - [x] Search bar with real-time filtering
  - [x] Category filter chips
  - [x] Multiple filter options
  
- [x] **Data Insights Dashboard**
  - [x] Total items count
  - [x] Total inventory value
  - [x] Out of stock items list
  - [x] Low stock warnings
  - [x] Category breakdown
  - [x] Top valuable items

- [x] **Bulk Operations**
  - [x] Multi-select mode
  - [x] Bulk delete functionality
  - [x] Visual selection indicators

### UI/UX Features
- [x] Material Design components
- [x] Form validation
- [x] Loading states
- [x] Error handling
- [x] Empty state messages
- [x] Confirmation dialogs
- [x] Snackbar notifications
- [x] Swipe to delete with undo
- [x] Color-coded stock status
- [x] Responsive layout

## 🧪 Testing Checklist

### Basic Functionality
- [ ] App launches without errors
- [ ] Firebase connection successful
- [ ] Can add new item
- [ ] Can view all items
- [ ] Can edit existing item
- [ ] Can delete item via swipe
- [ ] Can delete item via edit screen
- [ ] Real-time updates work

### Search & Filter
- [ ] Search returns correct results
- [ ] Category filter works
- [ ] Clear search button works
- [ ] Switching filters updates list

### Dashboard
- [ ] Statistics calculate correctly
- [ ] Out of stock items display
- [ ] Low stock items display
- [ ] Category breakdown accurate
- [ ] Top items ranked correctly

### Bulk Operations
- [ ] Long-press enters selection mode
- [ ] Can select multiple items
- [ ] Bulk delete works
- [ ] Can cancel selection mode

### Edge Cases
- [ ] Empty inventory state displays
- [ ] Search with no results shows message
- [ ] Form validation prevents invalid data
- [ ] Delete confirmation prevents accidents
- [ ] Network error handling works

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0      # Firebase core functionality
  cloud_firestore: ^4.9.5      # Firestore database
  cupertino_icons: ^1.0.2      # iOS style icons
```

## 🎨 Color Scheme

- **Primary**: Blue
- **Success/In Stock**: Green
- **Warning/Low Stock**: Orange
- **Error/Out of Stock**: Red
- **Background**: Grey[100]

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web

## 🐛 Known Issues

None at this time.

## 🔮 Future Enhancements

- User authentication (Firebase Auth)
- Barcode scanning for quick item addition
- Export data to CSV/PDF
- Push notifications for low stock
- Image upload for items
- Multi-language support
- Dark mode theme

## 👨‍💻 Developer

**Aryan Sahu**
- Course: Mobile Application Development
- Assignment: In-Class Activity #15
- Date: November 7, 2025

## 📄 License

This project is created for educational purposes as part of a university course assignment.

## 🙏 Acknowledgments

- Flutter Documentation
- Firebase Documentation
- FlutterFire Documentation
- Course Instructor and TAs

---

**Note**: This project demonstrates proficiency in Flutter development, Firebase integration, state management, and modern mobile app development practices.