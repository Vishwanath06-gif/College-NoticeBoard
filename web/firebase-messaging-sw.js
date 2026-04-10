importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDtqot4f6K9wISfMYWAPu7PbgJINd9u3-I",
  authDomain: "collegenoticeboard-9993b.firebaseapp.com",
  projectId: "collegenoticeboard-9993b",
  storageBucket: "collegenoticeboard-9993b.firebasestorage.app",
  messagingSenderId: "474377253391",
  appId: "1:474377253391:web:8cba187a6d0c0782cd297a"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received:', payload);
  const notificationTitle = payload.notification?.title || 'New Notice';
  const notificationOptions = {
    body: payload.notification?.body || 'Check the notice board',
    icon: '/icons/Icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
