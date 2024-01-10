/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const { logger } = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

// Function to generate random data
function generateRandomData() {
  const names = ["Alice", "Bob", "Charlie", "David", "Eva"];
  const randomName = names[Math.floor(Math.random() * names.length)];

  const ages = [21, 25, 30, 35, 40];
  const randomAge = ages[Math.floor(Math.random() * ages.length)];

  const emails = [
    "alice@example.com",
    "bob@example.com",
    "charlie@example.com",
  ];
  const randomEmail = emails[Math.floor(Math.random() * emails.length)];

  return {
    name: randomName,
    age: randomAge,
    email: randomEmail,
  };
}

// HTTP function to add random data to Firestore
exports.addRandomData = functions.https.onRequest(async (req, res) => {
  try {
    const randomData = generateRandomData();
    const docRef = await firestore.collection("users").add(randomData);

    // Respond with a simple HTML page
    res.status(200).send(`
        <html>
          <head>
            <title>Success</title>
          </head>
          <body>
            <h1>Data Added Successfully!</h1>
            <p>ID: ${docRef.id}</p>
          </body>
        </html>
      `);
  } catch (error) {
    console.error("Error adding random data:", error);

    // Respond with a simple HTML error page
    res.status(500).send(`
        <html>
          <head>
            <title>Error</title>
          </head>
          <body>
            <h1>Error Adding Data</h1>
            <p>There was an error adding data to Firestore.</p>
          </body>
        </html>
      `);
  }
});
