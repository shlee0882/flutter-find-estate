import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/NotificationModel.dart';
import 'package:http/http.dart' as http;

class NotificationsProvider with ChangeNotifier {
  dynamic _notifications = {};

  dynamic get notifications {
    return _notifications; // Returns a copy of _notifications list
  }

  Future<void> fetchNotifications() async {
    try {
      final url = 'https://www.dabangapp.com/api/3/room/new-list/multi-room/complex?api_version=3.0.1&call_type=web&complex_id=58291f87dfb67973a081153e2288&filters=%7B%22multi_room_type%22%3A%5B2%5D%2C%22selling_type%22%3A%5B0%2C1%2C2%5D%2C%22deposit_range%22%3A%5B0%2C999999%5D%2C%22price_range%22%3A%5B0%2C999999%5D%2C%22trade_range%22%3A%5B0%2C999999%5D%2C%22maintenance_cost_range%22%3A%5B0%2C999999%5D%2C%22room_size%22%3A%5B0%2C999999%5D%2C%22supply_space_range%22%3A%5B0%2C999999%5D%2C%22room_floor_multi%22%3A%5B1%2C2%2C3%2C4%2C5%2C6%2C7%2C-1%2C0%5D%2C%22division%22%3Afalse%2C%22duplex%22%3Afalse%2C%22room_type%22%3A%5B1%2C2%5D%2C%22use_approval_date_range%22%3A%5B0%2C999999%5D%2C%22parking_average_range%22%3A%5B0%2C999999%5D%2C%22household_num_range%22%3A%5B0%2C999999%5D%2C%22parking%22%3Afalse%2C%22short_lease%22%3Afalse%2C%22full_option%22%3Afalse%2C%22elevator%22%3Afalse%2C%22balcony%22%3Afalse%2C%22safety%22%3Afalse%2C%22pano%22%3Afalse%2C%22is_contract%22%3Afalse%2C%22deal_type%22%3A%5B0%2C1%5D%7D&page=1&version=1&zoom=18';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _notifications = jsonResponse;
      } else {
        // You can handle HTTP error statuses here
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      // Handle any errors thrown by the call to http.get()
      print('An error occurred: $error');
    }
    notifyListeners(); // This is important to notify any listening widgets
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        isRead: true,
      );
      notifyListeners(); // Again, notify the listeners
    }
  }
}
