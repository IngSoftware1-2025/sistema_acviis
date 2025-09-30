class CascadeManager {
  static final CascadeManager _instance = CascadeManager._internal();
  dynamic _opened; // Usa dynamic para evitar el import circular

  CascadeManager._internal();

  static CascadeManager get instance => _instance;

  void register(dynamic state) {
    if (_opened != null && _opened != state) {
      _opened.cerrarCascada();
    }
    _opened = state;
  }

  void unregister(dynamic state) {
    if (_opened == state) {
      _opened = null;
    }
  }

  void closeActive() {
    if (_opened != null) {
      _opened.cerrarCascada();
    }
  }

  void setInteractionEnabled(bool enable) {
    if (_opened != null) {
      _opened.setOverlayInteraction(enable);
    }
  }
}