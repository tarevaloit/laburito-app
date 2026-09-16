package ar.com.laburito.laburito

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // CU-21: el canal tiene que existir antes de que llegue la primera
    // notificación. Para cuando eso pasa, la app ya se abrió al menos una vez
    // -es como se pidió el permiso y se registró el token-, así que crearlo
    // acá alcanza; no hace falta una clase Application aparte.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val canal = NotificationChannel(
                "pedidos_nuevos",
                "Pedidos nuevos",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Avisa cuando se publica un pedido para tu oficio y tu zona"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(canal)
        }
    }
}
