#include "include/flutter_visual_keyboard/flutter_visual_keyboard_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_visual_keyboard_plugin.h"

void FlutterVisualKeyboardPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_visual_keyboard::FlutterVisualKeyboardPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
