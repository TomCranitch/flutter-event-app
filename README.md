# Flutter Event App
This app provides event managers with the tools necessary to manage great events. It includes the ability to scan and distribute tickets, show attendee lists and manage a shared Spotify playlist.

## Features
* Range of event data, including guest lists, title, description and feature image
* All event and user information is manged from with the Firebase Cloud Firestore
* Manage entry though the distribution of eTickets. Also includes the ability for multiple devices to scan tickets, with entry managed and updated in real time with the Cloud Firestore
* Integrates with an NPM server running the Spotify Web Playback SDK to create a shared party playlist. This shared playlist includes the ability for guests to add new songs, vote on already added songs, and see what is queued and currently playing.
* Users can use their existing accounts to sign in through Firebase Auth

## Screenshots
Some of the features showed in the screenshots below include a list of all events that a user has access to; an events details page which displays event details including the title, description and unique entry QR code; the shared music playlist, including the ability to search for new songs and vote for existing ones; and, ticket scanning, which includes a variety of error messages.

<img src="/screenshots/event-list.png?raw=true" width="250" hspace="10"> <img src="/screenshots/event-display-page.png?raw=true" width="250" hspace="10"> <img src="/screenshots/music-voting.png?raw=true" width="250" hspace="10"> <img src="/screenshots/ticket-scanning.png?raw=true" width="250" hspace="10">

The screenshots below show the form used to add new events, which includes automatic validation of all fields and a custom date time picker.

<img src="/screenshots/add-event-form.png?raw=true" width="250" hspace="10"> <img src="/screenshots/add-event-form-validation.png?raw=true" width="250" hspace="10">



## Built With
* Flutter
* Firebase Firestore, Firebase Auth, Firebase Analytics and Firesbase Messaging
* Flutter Barcode Scan package which is a wrapper for dm77/barcodescanner on android and mikebuss/MTBBarcodeScanner on iOS
* Spotify Web API and Web Playback SDK
