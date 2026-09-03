import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // CU-16. El SDK nativo de Maps no lee los --dart-define: la clave le tiene
    // que llegar por acá, igual que en Android le llega por el meta-data del
    // manifiesto. Sale de Info.plist (GMSApiKey), que a su vez la toma de
    // MAPS_API_KEY en ios/Flutter/Maps.xcconfig, un archivo que no se commitea.
    //
    // Si no hay clave no se llama a provideAPIKey: con una cadena vacía el SDK
    // aborta la app al arrancar, y sin mapa el resto de Laburito funciona igual
    // (es el mismo criterio por el que Env.googleMapsApiKey no entra en
    // Env.esValido).
    let clave = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
    if !clave.isEmpty {
      GMSServices.provideAPIKey(clave)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
