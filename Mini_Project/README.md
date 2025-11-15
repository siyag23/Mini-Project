# Mini Project: EduMock – Mock Test App

**Mini Project – Experiment 14**  
**Flutter | Firebase Authentication | Firestore | REST API (Open Trivia API)**

---

## 1. Aim
To design and develop a **functional, secure, and user-friendly Mock Test Application** using Flutter, integrating:

- Firebase Authentication
- Cloud Firestore
- REST API (Open Trivia API)
- Admin (Master) Control Panel
- Real-time result storing and premium-access management

EduMock allows students to attempt tests, track progress, and learn effectively.

---

## 2. Objective
The objective of this mini-project is to apply concepts learned in prior experiments to build a **real-world mobile app** that includes:

- Modern UI/UX
- Local & remote data handling
- Authentication
- REST API integration
- Admin panel
- Secure data storage
- Clean code structure

---

## 3. Scope
EduMock can be used by:

- Students preparing for tests and track progress
- Admins to manage premium access
- Educational institutions for practice tests


---

## 4. Technology Stack

**Frontend:**  
- Flutter  
- Dart  
- Material UI  

**Backend:**  
- Firebase Authentication  
- Firestore Database  

**API:**  
- Open Trivia REST API for quiz questions  

---

## 5. Features

### ✅ User Features (Updated with Tab Navigation)
1. **Authentication & Profile**
   - Login and Signup using Firebase Authentication
   - Edit profile details
   - Role-based navigation (`user` or `premium` access)

2. **Tab Navigation**
   - Smooth bottom tab navigation for quick access
   - Tabs include:
     - **Home** Overview, featured tests
     - **Explore:** Browse subjects and topics
     - **Progress:** View test history and analytics
     - **Profile:** Update profile and settings
   - Consistent UI across all tabs

3. **Test System**
   - Fetches test questions dynamically from Open Trivia API
   - Multiple-choice questions with 4 options
   - Timer per quiz with countdown and auto-submit
   - Track unanswered questions

4. **Result Tracking**
   - Detailed results: correct, wrong, total, unanswered
   - Time taken recorded per quiz
   - Store results under user in Firestore
   - View past quiz history

5. **Premium Features**
   - Premium quizzes unlocked vy buying monthly plan
   - Analytics for performance tracking
   - Deep subject mastery

6. **UI & UX**
   - Clean, intuitive interface
   - Smooth navigation across tabs
   - Responsive layout for all screen sizes


### ⭐ Admin Features (Master Admin Panel)
Two master admins are required:

| Role                | Email                                     | Password               |
| ------------------- | ----------------------------------------- | ---------------------- |
| Student Admin        | studentadmin@gmail.com                    | sa123#                   |
| Professor Admin      | vpg@gmail.com                             | 123456                   |

Admin Panel allows:
- Login using email + password
- Search user by email
- Toggle **premium true/false**
- View audit logs  

Whenever admin toggles premium, a log is stored:

```json
{
  "action": "toggled premium",
  "admin": "studentadmin@gmail.com",
  "targetUser": "sushri@gmail.com",
  "timestamp": "<server time>"
}
```
### 1. App Launch
1. **Splash Screen**
   - Displays app logo and animation while the app initializes
   - Loads Firebase configuration and checks network
2. **Welcome Screen**
   - Gives brief introduction to EduMock
   - Get Started Button to navigate to **Login** 

### 2. Authentication Flow
- **Login Screen**
  - Users enter email and password
  - Firebase Authentication validates credentials
  - AuthCheck redirects user based on login status
- **Signup Screen**
  - New users can register
  - Firestore document created under `/users/{userId}`
  - Default role: `user`, premium: `false`


### 3. Main Tab Navigation (After Login)
- **Home Tab**
  - Overview of app
  - Quick access to featured subjects
- **Explore Tab**
  - Browse all subjects
  - Start tests
- **Progress Tab**
  - **Standard users:** View past test results
  - **Premium users:** Access advanced analytics, charts, and progress graphs
    - Compare current scores with past performance
    - Visual graphs for performance by subjects and accuracy trend
- **Profile Tab**
  - Edit profile details
  - Check premium status

### 4. Quiz Flow
- User selects a subject in **Explore Tab**
- Questions fetched dynamically from **Open Trivia API**
- Timer starts for the quiz
- User answers questions
- Score calculated: correct, wrong, total, unanswered
- Results stored under `users/{userId}/results/{resultId}` in Firestore

### 5. Admin Actions
- Admin logs in via **Admin Screen**
- Can search user by email, toggle premium access
- Logs stored in `auditLogs` collection for transparency

## 7. Firestore Data Structure

Firestore is a **NoSQL document-based database**, storing data in **collections → documents → subcollections**.

### Users Collection Example


/users
/<userId>
name: "Siya Gaonkar"
email: "siya@example.com"
premium: false
role: "user"
createdAt: <timestamp>
updatedAt: <timestamp>
/results
/<resultId>
correct: 7
wrong: 3
total: 10
subject: "MATHEMATICS"
timeTakenSeconds: 120
timestamp: <timestamp>

## Conclusion

EduMock – Mock Test App successfully demonstrates the implementation of a **full-featured, secure, and user-friendly mobile application** using Flutter. The project highlights the following achievements:

- **Firebase Authentication**: Secure login, signup, and role-based access for users and admins.  
- **REST API Integration**: Dynamic quiz questions fetched from the Open Trivia API.  
- **Firestore Data Handling**: Efficient storage of user profiles, test results, and admin audit logs.  
- **Tab-based UI Navigation**: Smooth and intuitive navigation between Home, Explore, Progress, and Profile tabs.  
- **Premium Features**: Advanced analytics and progress graphs for premium users, enhancing learning experience.  
- **Admin Panel**: Ability to manage users, toggle premium access, and maintain audit logs for transparency.  
- **Scalable & Maintainable Architecture**: Clean code structure and modular project organization.

Overall, EduMock meets all requirements of a mini-project (Experiment 14) and demonstrates the capability to build a **real-world educational application** with modern UI/UX, secure backend, and dynamic functionality. This project showcases practical skills in **mobile app development, API integration, cloud database management, and user-centric design**.




