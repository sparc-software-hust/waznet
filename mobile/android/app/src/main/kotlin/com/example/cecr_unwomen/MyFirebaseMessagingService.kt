// package com.example.cecr_unwomen

// import androidx.core.app.NotificationCompat
// import android.content.Context
// import android.content.Intent
// import android.app.PendingIntent
// import android.app.NotificationManager
// import com.google.firebase.messaging.FirebaseMessagingService
// import com.google.firebase.messaging.RemoteMessage

// class MyFirebaseMessagingService : FirebaseMessagingService() {
//   override fun onMessageReceived(remoteMessage: RemoteMessage) {
//     if (remoteMessage.notification != null) {
//         val title : String = remoteMessage.notification?.title!!
//         val body : String = remoteMessage.notification?.body!!
//         System.out.println("remoteMessage: " + title + body)
//         addNotification(title, body)
//     }
// }

// private fun addNotification(title: String, body: String) {
//     val builder: NotificationCompat.Builder = NotificationCompat.Builder(this)
//         .setSmallIcon(R.drawable.ic_launcher) //set icon for notification
//         .setContentTitle(title) //set title of notification
//         .setContentText(body) //this is notification message
//         .setAutoCancel(true) // makes auto cancel of notification
//         .setPriority(NotificationCompat.PRIORITY_DEFAULT) //set priority of notification
//     val notificationIntent = Intent(this, MainActivity::class.java)
//     notificationIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
//     //notification message will get at NotificationView
//     notificationIntent.putExtra("message", body)
//     val pendingIntent = PendingIntent.getActivity(
//         this, 0, notificationIntent,
//         PendingIntent.FLAG_UPDATE_CURRENT
//     )
//     builder?.setContentIntent(pendingIntent)
//     // Add as notification
//     val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//     manager.notify(1, builder?.build())
// }
// }