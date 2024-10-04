## DangerMap
  **Danger Map** is a safety app that alerts users to nearby dangers by displaying them on a map. Users can create an account, view   hazards in real-time, and receive notifications when entering dangerous areas, ensuring they stay informed and safe.

<img src="https://github.com/user-attachments/assets/b12383a9-32b7-4333-9308-43eb77f53d1b" alt="app_logo" width="200">

## Features

- **Real-Time Danger Mapping**: View an interactive map that displays current dangers in your vicinity, helping you stay aware of potential threats.
- **Notifications for Nearby Dangers**: Receive notifications when you enter or approach areas with reported dangers, keeping you informed as quick as possible.
- **Toggle Notification Service**: Start or stop danger notifications at any time with a simple toggle, allowing you to control you level or alerts.
- **Authorized-Submitted Danger Reports**: Only authorized users can contribute to community safety by reporting new dangers or incidents.

## Implementation overview  

- **Technologies used**: This app uses **Dart** for both frontend and backend. Also it uses **Geolocator**, for retreiving the current user's location and calculate the distance between user and dangers around him. **Geocoding** is used for decoding the geolocation as location name (current user's city name for example). 
- **Data Storage and Management**: User data, artwork information and other relevant data are stored in **Firebase**, a database hosted by Google.
- **User authentication and authorization**: This is handled by **Firebase Authentication**. It requires each user to input an email and a strong password, in order to create an account.

## Installation 

  In order to install **DangerMap** on your phone, you need to get all the files on your machine, that has **Android Studio** or **Visual Studio Code**, because using this tool, you can build the APK.

- **Step1**: Download all the files, either manually, or in your git bash use `git clone https://github.com/omuletzu/DangerMap`
- **Step2**: You have to open all this files as a project in **Android Studio** or **Visual Studio Code** and build the APK, and after this, using an USB cable get the APK on your phone and run the APK

## USAGE 

- **Sign in or create an account**: First of all you must login into your account or create one.
- **Explore**: While moving on map you can press on dangers to check for more details.
- **Add dangers**: As an authorized person you can add dangers, and select details for them, such as description, danger level and danger type.

## Credits

- Flutter, Google Maps API
