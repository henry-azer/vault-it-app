/// Ad loading states
enum AdState {
  /// Ad is not loaded yet
  notLoaded,
  
  /// Ad is currently loading
  loading,
  
  /// Ad loaded successfully and ready to show
  loaded,
  
  /// Ad failed to load
  failed,
  
  /// Ad is currently being shown
  showing,
  
  /// Ad was shown and dismissed
  dismissed,
}

/// Ad type enumeration
enum AdType {
  banner,
  interstitial,
  rewarded,
  appOpen,
}
