Moving App Driver - Mobile Application

Description:
Developed the driver version of a mobile application for a moving company, designed to manage and fulfill service requests efficiently. 
The app is built to work seamlessly with the requester's version, ensuring that drivers can be promptly notified, respond to service requests, and update their location in real-time.

Key Features:

Automated Driver Assignment: The app listens for background triggers to receive notifications when the REST API identifies drivers in the area. Once a driver is assigned, they receive a notification with the request details and the user's coordinates.
Request Management: Drivers can accept or decline service requests. Upon acceptance, their details and location are shared with the user. If declined, the system automatically excludes them from further consideration for that request, updating the database accordingly.
Driver Registration: Includes a registration process where new drivers can sign up via a web app. After registration, their profile awaits approval by the company administrator. Approved drivers can then log in and start receiving service requests.
Real-Time Location Tracking: Integrated real-time tracking to allow drivers to update their location, which is visible to the requester.
Notification System: Utilizes push notifications to keep drivers updated on new requests, changes, and status updates for their profiles.

Technologies & Packages:

Real-Time Communication: Implemented with socket_io_client to enable instant, bidirectional communication with the backend, ensuring drivers receive notifications and updates promptly.
Google Maps Integration: Leveraged google_maps_flutter, flutter_polyline_points, and google_geocoding for accurate real-time map tracking and routing.
Location Services: Utilized the location package for continuous GPS tracking of drivers.
Push Notifications: Enabled through firebase_messaging and flutter_local_notifications to ensure drivers receive timely updates and alerts.
UI & UX Enhancements: Employed flutter_svg for scalable vector graphics, sliding_up_panel for smooth interactive elements, and url_launcher for redirecting drivers to web pages.
Backend Connectivity: Used http for interacting with REST APIs, with rxdart for reactive programming, ensuring a responsive and efficient application.
Note: This version of the app is specifically designed for drivers to manage and fulfill moving requests. It is tightly integrated with the requester's app, ensuring a seamless service experience.

Please also have a look in the 'media' folder for some screenshots of the app.

[![Video Title]((https://github.com/SouthPeace/Moving-App-Driver/tree/main/media/ConfirmOrder.png))](https://youtu.be/c-SMFXBvXJQ)
