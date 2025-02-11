# app_with_tabs_2


## Getting Started

This project is a starting point to my Flutter journey.
It is designed for me to use multiple packages, work with permissions, create different UIs and integrate api keys for different google services such as Google Maps and Firebase.
I also work with SQLite in one of the features.

This app has multiple features such as:
- Authentication (Signup & Login) via Firebase
- Calculator
- Quiz app (more on this below)
- Contact list
- Google maps location + marker
- Personal info card where you can upload a profile picture
- Notification alerts regular users of newly added quizzes to the quiz game section

You can find an .apk file of the app to install on your android device for testing.

## Quiz App

This game is designed to have 2 types of users: Admins and Users.

The admin can:
- Create a quiz (that will be saved locally and on firestore db)
- Delete quizzes
- Update quizzes

The user can:
- Pick an available quiz and play
- Can leave a quiz and come back to it (saved progress)
- Check his scores and answer history
- Delete his scores to retake quizzes
