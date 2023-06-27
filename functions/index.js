const functions = require("firebase-functions");
const axios = require('axios');
const express = require('express');
const app = express();
const port = 3000;

const { PubSub } = require('@google-cloud/pubsub');
const pubSubClient = new PubSub();

const admin = require("firebase-admin");
var serviceAccount = require("./flutter-find-estate-firebase-adminsdk-ece1z-947f602f6e.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

var db = admin.firestore();

exports.getEstateData = functions.https.onRequest(async (req, res) => {
  await msgPushData();
  res.status(200).send("Notification sent");
});

async function msgPushData() {
  const url = 'https://www.dabangapp.com/api/3/room/new-list/multi-room/complex?api_version=3.0.1&call_type=web&complex_id=58291f87dfb67973a081153e2288&filters=%7B%22multi_room_type%22%3A%5B2%5D%2C%22selling_type%22%3A%5B0%2C1%2C2%5D%2C%22deposit_range%22%3A%5B0%2C999999%5D%2C%22price_range%22%3A%5B0%2C999999%5D%2C%22trade_range%22%3A%5B0%2C999999%5D%2C%22maintenance_cost_range%22%3A%5B0%2C999999%5D%2C%22room_size%22%3A%5B0%2C999999%5D%2C%22supply_space_range%22%3A%5B0%2C999999%5D%2C%22room_floor_multi%22%3A%5B1%2C2%2C3%2C4%2C5%2C6%2C7%2C-1%2C0%5D%2C%22division%22%3Afalse%2C%22duplex%22%3Afalse%2C%22room_type%22%3A%5B1%2C2%5D%2C%22use_approval_date_range%22%3A%5B0%2C999999%5D%2C%22parking_average_range%22%3A%5B0%2C999999%5D%2C%22household_num_range%22%3A%5B0%2C999999%5D%2C%22parking%22%3Afalse%2C%22short_lease%22%3Afalse%2C%22full_option%22%3Afalse%2C%22elevator%22%3Afalse%2C%22balcony%22%3Afalse%2C%22safety%22%3Afalse%2C%22pano%22%3Afalse%2C%22is_contract%22%3Afalse%2C%22deal_type%22%3A%5B0%2C1%5D%7D&page=1&version=1&zoom=18';
  try {
    const response = await axios.get(url);
    console.log(response.data);
    let notifications = response.data;
    let totalCnt = 0;
    if(notifications['total'] != null && notifications['total'] > 0) {
        totalCnt = notifications['total'];
    } else {
        totalCnt = 0;
    }
    pushNotiMsg(totalCnt);
  } catch (error) {
      console.error(error);
      res.status(500).send(error.toString());
  }
}

exports.scheduledFunction = functions.pubsub.schedule('0 18 * * *').onRun(async (context) => {
  console.log('This function will run at 6:00 PM every day!');
  await msgPushData();
});

// HTTP Cloud Function.
exports.scheduledHttpFunction = functions.https.onRequest((req, res) => {
  res.send('This function was triggered by HTTP request, This will be run every 30 minutes!');
});

// 귀뚜라미 오피스텔
exports.getCricket = functions.https.onRequest(async (req, res) => {
    const url = 'https://www.dabangapp.com/api/3/room/new-list/multi-room/complex?api_version=3.0.1&call_type=web&complex_id=58291f87dfb67973a081153e2288&filters=%7B%22multi_room_type%22%3A%5B2%5D%2C%22selling_type%22%3A%5B0%2C1%2C2%5D%2C%22deposit_range%22%3A%5B0%2C999999%5D%2C%22price_range%22%3A%5B0%2C999999%5D%2C%22trade_range%22%3A%5B0%2C999999%5D%2C%22maintenance_cost_range%22%3A%5B0%2C999999%5D%2C%22room_size%22%3A%5B0%2C999999%5D%2C%22supply_space_range%22%3A%5B0%2C999999%5D%2C%22room_floor_multi%22%3A%5B1%2C2%2C3%2C4%2C5%2C6%2C7%2C-1%2C0%5D%2C%22division%22%3Afalse%2C%22duplex%22%3Afalse%2C%22room_type%22%3A%5B1%2C2%5D%2C%22use_approval_date_range%22%3A%5B0%2C999999%5D%2C%22parking_average_range%22%3A%5B0%2C999999%5D%2C%22household_num_range%22%3A%5B0%2C999999%5D%2C%22parking%22%3Afalse%2C%22short_lease%22%3Afalse%2C%22full_option%22%3Afalse%2C%22elevator%22%3Afalse%2C%22balcony%22%3Afalse%2C%22safety%22%3Afalse%2C%22pano%22%3Afalse%2C%22is_contract%22%3Afalse%2C%22deal_type%22%3A%5B0%2C1%5D%7D&page=1&version=1&zoom=18';
    try {
        const response = await axios.get(url);
        console.log(response.data);
        res.send(response.data);
    } catch (error) {
        console.error(error);
        res.status(500).send(error.toString());
    }
});

function pushNotiMsg(totalCnt) {
  const message = {
    notification: {
      title: `귀뚜라미홈시스텔`,
      body: `${totalCnt}건 매물`,
    },
    android: {
      notification: {
        channelId: '370043057221',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      }
    },
    apns: {
      payload: {
        aps: {
          contentAvailable: 1,
          mutableContent: 1
        }
      }
    }
  };
  console.log(message);
  // Get the device tokens from Firestore and send the notification
  db.collection('devices').get()
    .then((snapshot) => {
      snapshot.forEach((doc) => {
        console.log(doc.id, '=>', doc.data());
        let token = doc.data().token;
        message.token = token;

        admin.messaging().send(message)
          .then((response) => {
            console.log('Successfully sent message:', response);
          })
          .catch((error) => {
            console.log('Error sending message:', error);
          });
      });
    })
    .catch((err) => {
      console.log('Error getting documents', err);
    });
}
