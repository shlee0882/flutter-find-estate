<br>

# 귀뚜라미 홈시스텔 매물 찾기 앱
<br>

## 개요

- 프로젝트 팀원이 살고 있는 집이 좋아 보여 해당 매물이 떴는지 확인하기 위해 만든 앱
- 매일 AM 09:00, PM 18:00 스케줄링 되어 매물 조회 후 매물 건수 푸시 알림 발생  
- 매물 조회 API는 다방 APP에서 사용하는 API 사용(오픈 API 아님)
- 정보 빠르게 확인 후 원하는 매물 선점 가능

<br>

## 개발 기간

- 당일치기 (23.06.08 ~ 23.06.08)

<br>

## 기능 요약

- 매물 조회 기능

![조회기능](/lib/assets/gif/gif_get_data.gif)

- 스케쥴링 푸시 알림 기능

![푸시기능](/lib/assets/gif/gif_push_test.gif)


<br>

## 기술 및 오픈소스

- Dart, Flutter
- flutter_local_notifications: ^14.1.1
- firebase_messaging: ^14.6.2
- fluttertoast: ^8.2.2
- shared_preferences: ^2.1.1
- provider: ^6.0.5
- http: ^0.13.6
- permission_handler: ^10.3.0
- cloud_firestore: ^4.8.0
- uuid: ^3.0.7


<br>

## 추가하면 좋을 것들

- 여러개의 플랫폼(네이버 부동산, 다음 부동산, 직방, 다방)에서 특정 매물이 올라왔는지 확인 알림 받기

<br>
