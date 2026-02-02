# Guage

Guage is a simple iOS application designed to help you keep track of your car's maintenance and mileage. It acts as a digital logbook, ensuring you always know when your last service was and when the next one is due.

## What it does

**Keeps track of your car**
The app displays your vehicle's make, model, and current mileage right on the home screen. It gives you a quick snapshot of your car's status every time you open the app.

(Insert image of the main dashboard)

**Logs your maintenance**
You can record every oil change, tire rotation, or repair. For each item, you can see a history of when it was done and at what mileage. This helps you stay on top of regular service intervals.

(Insert image of adding a maintenance item)

**Cloud Sync**
All your data is securely stored in the cloud using AWS. This means if you switch phones or reinstall the app, your maintenance history is safe and will be restored automatically.

## How to run this project

To run Guage on your own machine:

1.  Open the project file `Guage.xcodeproj` in Xcode.
2.  Ensure you have a valid developer signing certificate selected.
3.  **Important**: This app requires a `Secrets.swift` file for AWS configuration, which is not included in the public repository for security reasons. You will need to add your own AWS Cognito and DynamoDB credentials to build the app successfully.

## User Actions

**Updating Mileage**
Keeping your mileage current is key to accurate tracking.

1.  Tap the speedometer icon on the home screen.
2.  Enter your new odometer reading.
3.  Tap "Save Entry".
    _Note: The app will calculate your average daily driving distance based on these updates._

**Adding Maintenance Items**
When you get work done on your car, log it here:

1.  Tap the "Plus" icon on the home screen.
2.  **Title**: What did you do? (e.g., "Oil Change", "New Tires").
3.  **Details**: Enter the current mileage and date.
4.  **Interval**: If this needs to be done regularly (like every 5,000 miles), enter that number here.
5.  Tap "Save Entry".

**Cloud Sync & Settings**
To change your car details or units (Miles vs. Km):

1.  Tap the "Gear" icon in the top right.
2.  Here you can update your vehicle info or reset your data.
3.  **Sync**: The app automatically syncs with the cloud whenever you open it or save an item.

## System Design

For those interested in how Guage works under the hood:

**Architecture**
The app is built using **SwiftUI** in an **MVVM** (Model-View-ViewModel) pattern.

- **Views**: The screens you see (like `HomeView`).
- **ViewModel**: `CarDataStore` is the brain. It holds all the data and logic, and the Views watch it for changes.

**Data Storage (Cloud + Local)**
We use a "Cloud First" approach with local caching.

1.  **AWS Cloud**: Your data lives in **DynamoDB**, a fast NoSQL database. This allows your data to follow you to any device.
2.  **Security**: We use **AWS Cognito** to ensure only _you_ can access your data.
3.  **Local Cache**: We save a copy of your history on your phone (`UserDefaults`) so the app opens instantly, even if your internet is slow.

**Offline Mode**
If you don't have internet, don't worry. You can still view your last known data. The app will try to reconnect and sync your latest changes the next time you go online.
