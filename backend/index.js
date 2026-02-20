const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// Initialize Firebase Admin SDK
// On Render, we'll store the service account JSON in an environment variable
// named FIREBASE_SERVICE_ACCOUNT
let serviceAccount;
try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    } else {
        // Fallback for local development if you have the file
        serviceAccount = require('./serviceAccountKey.json');
    }

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
    console.log('Firebase Admin Initialized');
} catch (error) {
    console.error('Failed to initialize Firebase Admin:', error.message);
}

const db = admin.firestore();

// API Endpoint to send notification
app.post('/send-notification', async (req, res) => {
    const { userId, title, body, imageUrl, data } = req.body;

    if (!userId || !title || !body) {
        return res.status(400).send('Missing userId, title, or body');
    }

    try {
        // 1. Get the user's FCM token from Firestore
        console.log(`Fetching token for user: ${userId}`);
        const userDoc = await db.collection('users').doc(userId).get();

        if (!userDoc.exists) {
            console.log('User not found');
            return res.status(404).send('User not found');
        }

        const userData = userDoc.data();
        const token = userData.fcmToken;

        if (!token) {
            console.log('FCM Token not found for user');
            return res.status(404).send('FCM Token not found for user');
        }

        // 2. Construct the message
        // NOTE: For images to appear in the Android system tray, they must be
        // set in android.notification.imageUrl (not just notification.imageUrl).
        const message = {
            notification: {
                title: title,
                body: body,
                ...(imageUrl && { imageUrl: imageUrl }), // top-level (some clients use this)
            },
            android: {
                notification: {
                    imageUrl: imageUrl || undefined, // Android system tray image
                },
            },
            apns: imageUrl ? {
                payload: {
                    aps: {
                        'mutable-content': 1,
                    },
                },
                fcmOptions: {
                    imageUrl: imageUrl,
                },
            } : undefined,
            data: {
                ...(data || {}),
                ...(imageUrl && { imageUrl: imageUrl }), // also pass in data for foreground handler
            },
            token: token,
        };

        console.log('Sending FCM message with imageUrl:', imageUrl || 'none');

        // 3. Send the message
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);

        res.status(200).json({ success: true, messageId: response });
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).send('Error sending notification: ' + error.message);
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
