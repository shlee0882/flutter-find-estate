import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../provider/NotificationsProvider.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationChecklistScreen extends StatefulWidget {
  @override
  _NotificationChecklistScreenState createState() =>
      _NotificationChecklistScreenState();
}

class _NotificationChecklistScreenState
    extends State<NotificationChecklistScreen> {
  var _isLoading = false;
  bool _isSale = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  @override
  void initState() {
    super.initState();
    _runWhileAppIsTerminated();
    _createChannel();
    _requestNotificationPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid,);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    
    _registerNotification();
    _setupMessaging();
    _fetchNotifications();
  }

  void _createChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      '370043057221', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  void _runWhileAppIsTerminated() async {
    var details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload != null) {
        Navigator.pushNamed(context,'/main');
      }
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    Navigator.pushNamed(context,'/main');
  }

  void _registerNotification() async {
    // Get the token each time the application starts
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    // Save token here

    // Listen to token changes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("New FCM Token: $newToken");
      // Save new token here
    });
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '370043057221',
      'your channel name',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title, // Notification title
      message.notification?.body, // Notification body
      platformChannelSpecifics,
    );
  }

  void _requestNotificationPermissions() async {
    PermissionStatus permissionStatus = await Permission.notification.status;
    if (!permissionStatus.isGranted) {
      PermissionStatus permission = await Permission.notification.request();
      if (permission.isGranted) {
        // Do something with granted permission
      } else {
        // Show a dialog telling the user the permission was not granted.
      }
    }
  }

  // Call this method to update or create fcm token
  void _updateOrCreateFcmTocken(String? fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if device ID already exists
    String? deviceId = prefs.getString('deviceId');
    if (deviceId == null) {
      // Generate new device ID if it does not exist and save it
      var uuid = const Uuid();
      deviceId = uuid.v1();
      prefs.setString('deviceId', deviceId);
    }
    // Update or create fcm token
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).set({
      'token': fcmToken,
    });
  }

  Future<void> _setupMessaging() async {
    await Firebase.initializeApp();
    var token = await FirebaseMessaging.instance.getToken();
    print("Firebase Messaging Token: $token");
    _updateOrCreateFcmTocken(token);
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<NotificationsProvider>(context, listen: false)
          .fetchNotifications();
    } catch (error) {
      // Handle error, show an error message to the user
      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch notifications from Provider
    final notificationProvider = Provider.of<NotificationsProvider>(context);
    final notifications = notificationProvider.notifications;
    String prettyJsonResponse = JsonEncoder.withIndent('  ').convert(notifications);
    if(notifications['total'] != null && notifications['total'] > 0) {
      _isSale = true;
    } else {
      _isSale = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('매물 확인 결과'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              _fetchNotifications();
            },
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10,),
                if(_isSale) Text('${notifications['total']} 건의 매물이 존재합니다.', style: TextStyle(fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                if(!_isSale) Text('매물이 존재하지 않습니다.', style: TextStyle(fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),),
                SizedBox(height: 10,),
                Text(prettyJsonResponse,style: TextStyle(fontFamily: 'Courier', fontSize: 16),),
              ],
            ),
          ),
        ),
    );
  }
}
