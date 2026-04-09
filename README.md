# AI Fitness & Calorie Tracker (Flutter + Firebase)

A modern, AI-powered fitness and calorie tracking mobile application built using Flutter and Firebase. This app helps users monitor their daily nutrition, workouts, and progress while providing intelligent recommendations to improve their lifestyle.

----

## Features

### Authentication

* Google Sign-In using Firebase Authentication
* Secure and seamless login experience
* Automatic user profile creation

----

###  Calorie Tracking

* Log daily meals
* Track calories, protein, carbs, and fats
* View remaining vs consumed calories
* Daily nutrition summary

----

###  Workout Tracking

* Predefined workouts (gym, home, yoga)
* Custom workout creation
* Track sets, reps, duration, and calories burned
* Daily activity logs

----

###  AI-Powered Features

* Personalized diet recommendations
* AI-generated workout plans
* Smart insights based on user habits
* AI chat assistant for fitness queries

----

### Dashboard & Analytics

* Daily, weekly, and monthly statistics
* Calories intake vs burned charts
* Weight progress tracking
* Streak and consistency monitoring 🔥

----

###  Notifications & Engagement

* Meal reminders
* Workout reminders
* Water intake notifications
* Gamification (badges, streaks)

----

##  Tech Stack
-### Frontend

* Flutter (Dart)

### Backend (Firebase)

* Authentication (Firebase Auth)
* Database (Cloud Firestore)
* Cloud Functions (Serverless logic)
* Firebase Cloud Messaging (Push notifications)

### AI Integration

* OpenAI API (or similar)

----

##  App Architecture

Flutter App
-   ↓
-Firebase Services
-   ├── Authentication
-   ├── Firestore Database
-   ├── Cloud Functions
-   └── Push Notifications (FCM)
```
----

## Database Structure (Firestore)

```plaintext
users/{userId}
-  name
-  age
-  height
-  weight
-  goal
-
-meals/{userId}/{date}
-  totalCalories
-  protein
-  carbs
-  fats
-
-workouts/{userId}/{date}
-  exercises[]
-  duration
-  caloriesBurned
```

----

##  Key Functionalities

* BMR & TDEE calculation for personalized calorie goals
* Real-time data sync with Firestore
* AI-based recommendations using user behavior
* Background notifications using Firebase Cloud Messaging

----

##  UI/UX Highlights

* Clean and modern design
* Dark & Light mode support
* Smooth animations
* Interactive dashboards and charts

----

##  Monetization (Optional)

* Freemium model:

-  * Free: Basic tracking features
-  * Premium: AI coach, advanced analytics, personalized plans

----

##  Installation

```bash
# Clone the repository
-git clone https://github.com/your-username/fitness-app.git
-
-# Navigate to project directory
-cd fitness-app
-
-# Install dependencies
-flutter pub get
-
-# Run the app
-flutter run
```

----

##  Firebase Setup

1. Create a Firebase project
2. Enable Authentication (Phone / Google)
3. Set up Cloud Firestore
4. Enable Firebase Cloud Messaging
5. Add your `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
6. Configure Firebase in Flutter

----

##  Future Enhancements

* Image-based food recognition
* Wearable device integration (Google Fit / Apple Health)
* Voice input for meal logging
* Advanced analytics & insights
* Social features (share progress)

----

##  Contributing

Contributions are welcome! Feel free to fork this repository and submit a pull request.

----
