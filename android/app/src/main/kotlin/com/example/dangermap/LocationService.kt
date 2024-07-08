package com.example.dangermap

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Geocoder
import android.location.Location
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.SphericalUtil
import com.google.firebase.ktx.Firebase
import com.google.firebase.firestore.ktx.firestore
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*

class LocationService : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private val firestore = Firebase.firestore

    private val notifId = "ForegroundServiceChannel"
    private val possibleDangers = listOf("Unidentified", "Fire", "Weather", "Crime", "Violence", "Animal")

    companion object{

        var pushNotifId = 0
        var locationServiceContext : Context? = null

        fun pushNotif(context : Context, dangerName: String) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val notificationChannel = NotificationChannel(
                pushNotifId.toString(),
                "Danger Notification Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(notificationChannel)
    
            val notification = NotificationCompat.Builder(context, pushNotifId.toString())
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Warning")
                .setContentText("There is a danger near you | $dangerName\nPress for details")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .build()
    
            notificationManager.notify(pushNotifId, notification)
            pushNotifId++
        }

        fun stopNotif(){
            Log.i("INFO", "INFOOO")
            val stopIntent = Intent(locationServiceContext, LocationService::class.java).apply{
                action = "ACTION_STOP_SERVICE"
            }

            locationServiceContext?.startService(stopIntent)
        }
    }

    override fun onCreate() {
        super.onCreate()

        locationServiceContext = this

        createNotificationChannel(this)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        startLocationUpdates()
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 60000 * 10
            fastestInterval = 60000 * 10
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                super.onLocationResult(locationResult)
                handleLocationResult(locationResult.locations[0])
            }
        }

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    private fun handleLocationResult(location: Location) {
        Log.i("INFO", "${location.latitude} - ${location.longitude}")

        sendNotifCheck(location)
    }

    private fun sendNotifCheck(location: Location) {
        val currentPosition = LatLng(location.latitude, location.longitude)

        val geocoder = Geocoder(this, Locale.getDefault())
        var result = geocoder.getFromLocation(location.latitude, location.longitude, 1)

        var localityName = "-"

        if (result != null && result!!.isNotEmpty()) {
            val localityName = result[0].locality

            localityName?.let { locality ->
                firestore.collection("waypoints").document(locality).get()
                    .addOnSuccessListener { query ->
                        if (query.exists()) {

                            val dangersInRadius: MutableList<Map<String, Any>> = mutableListOf()

                            query.data?.forEach { (key, value) ->
                                val keySplitted = key.split('_')

                                val latitude = "${keySplitted[0]}.${keySplitted[1]}".toDouble()
                                val longitude = "${keySplitted[2]}.${keySplitted[3]}".toDouble()

                                val position = LatLng(latitude, longitude)
                                val distance = SphericalUtil.computeDistanceBetween(position, currentPosition)

                                val item = jsonStringToMap(value.toString())

                                val radiusType = item["radiusType"] as? Double ?: 0.0

                                if (distance <= radiusType * 50) {
                                    val dangerType = (item["selectedDangerType"] as? Double)?.toInt() ?: 0
                                    pushNotif(this, possibleDangers[dangerType])
                                }
                            }
                        }
                    }
            }
        }
    }

    override fun onStartCommand(intent : Intent?, flags : Int, startId : Int) : Int {
        intent?.action?.let{ action ->
            if(action == "ACTION_STOP_SERVICE"){
                fusedLocationClient.removeLocationUpdates(locationCallback)
                stopForeground(true)
                stopSelf()
            }
        }

        return super.onStartCommand(intent, flags, startId)
    }

    private fun jsonStringToMap(jsonString: String): Map<String, Any> {
        val gson = Gson()
        val type = object : TypeToken<Map<String, Any>>() {}.type
        return gson.fromJson(jsonString, type)
    }

    private fun createNotificationChannel(context: Context) {
        val channel = NotificationChannel(
            notifId,
            "Foreground Service Channel",
            NotificationManager.IMPORTANCE_DEFAULT
        )

        val notifManager = getSystemService(NotificationManager::class.java)
        notifManager.createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(context, notifId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("ForegroundService")
            .setContentText("Tracking location")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        startForeground(1, notification)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
