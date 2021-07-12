/*eslint-disable */
const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document("chatrooms/{chatroomid}/messages/{messageId}")
    .onCreate((snap) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc['userId']
    const idTo = doc['receiverId']
    const contentMessage = doc['text']

    console.log(idTo)

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('userProfiles')
      .doc(idTo)
      .get()
      .then(userTo => {
          console.log(`Found user to: ${userTo.data()['userName']}`)
          if (userTo.data()['notificationToken']) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('userProfiles')
              .doc(idFrom)
              .get()
              .then(userFrom => {
                  console.log(`Found user from: ${userFrom.data()['userName']}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${userFrom.data()['userName']}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data()['notificationToken'], payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
    return null
  })
