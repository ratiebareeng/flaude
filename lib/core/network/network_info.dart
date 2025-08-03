// lib/core/network/network_info.dart

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network connectivity checker and monitor
class NetworkInfo {
  static final NetworkInfo _instance = NetworkInfo._internal();
  factory NetworkInfo() => _instance;
  NetworkInfo._internal();

  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isConnected = false;
  List<ConnectivityResult> _currentConnectivityResults = [];

  /// Stream of connection status changes
  Stream<bool> get onConnectivityChanged => _connectionStatusController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Current connectivity results
  List<ConnectivityResult> get currentConnectivityResults => 
      List.unmodifiable(_currentConnectivityResults);

  /// Check if device has internet connection
  bool get hasInternetConnection => _isConnected;

  /// Check if connected via WiFi
  bool get isConnectedViaWiFi => 
      _currentConnectivityResults.contains(ConnectivityResult.wifi);

  /// Check if connected via mobile data
  bool get isConnectedViaMobile => 
      _currentConnectivityResults.contains(ConnectivityResult.mobile);

  /// Check if connected via ethernet
  bool get isConnectedViaEthernet => 
      _currentConnectivityResults.contains(ConnectivityResult.ethernet);

  /// Get connection type description
  String get connectionType {
    if (_currentConnectivityResults.isEmpty) {
      return 'No Connection';
    }

    final types = <String>[];
    for (final result in _currentConnectivityResults) {
      switch (result) {
        case ConnectivityResult.wifi:
          types.add('WiFi');
          break;
        case ConnectivityResult.mobile:
          types.add('Mobile Data');
          break;
        case ConnectivityResult.ethernet:
          types.add('Ethernet');
          break;
        case ConnectivityResult.bluetooth:
          types.add('Bluetooth');
          break;
        case ConnectivityResult.vpn:
          types.add('VPN');
          break;
        case ConnectivityResult.other:
          types.add('Other');
          break;
        case ConnectivityResult.none:
          types.add('None');
          break;
      }
    }

    return types.isNotEmpty ? types.join(', ') : 'Unknown';
  }

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Get initial connectivity status
    await _updateConnectivityStatus();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        debugPrint('Connectivity stream error: $error');
      },
    );
  }

  /// Check current connectivity status and update internal state
  Future<bool> checkConnectivity() async {
    await _updateConnectivityStatus();
    return _isConnected;
  }

  /// Perform internet connectivity test by trying to reach a reliable host
  Future<bool> hasInternetAccess({
    String testHost = 'google.com',
    int port = 443,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final result = await InternetAddress.lookup(testHost).timeout(timeout);
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      // Update internal state if different from actual connectivity
      if (hasConnection != _isConnected) {
        _isConnected = hasConnection;
        _connectionStatusController.add(_isConnected);
      }
      
      return hasConnection;
    } catch (e) {
      debugPrint('Internet access test failed: $e');
      
      // Update internal state to disconnected
      if (_isConnected) {
        _isConnected = false;
        _connectionStatusController.add(_isConnected);
      }
      
      return false;
    }
  }

  /// Test connection to a specific host and port
  Future<bool> canReachHost({
    required String host,
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(host, port).timeout(timeout);
      await socket.close();
      return true;
    } catch (e) {
      debugPrint('Cannot reach $host:$port - $e');
      return false;
    }
  }

  /// Test if Claude API is reachable
  Future<bool> canReachClaudeAPI({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return canReachHost(
      host: 'api.anthropic.com',
      port: 443,
      timeout: timeout,
    );
  }

  /// Test if Firebase is reachable
  Future<bool> canReachFirebase({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return canReachHost(
      host: 'firebase.google.com',
      port: 443,
      timeout: timeout,
    );
  }

  /// Get detailed connectivity information
  Future<ConnectivityInfo> getConnectivityInfo() async {
    await _updateConnectivityStatus();
    
    return ConnectivityInfo(
      isConnected: _isConnected,
      connectivityResults: _currentConnectivityResults,
      connectionType: connectionType,
      hasInternetAccess: await hasInternetAccess(),
      canReachClaudeAPI: _isConnected ? await canReachClaudeAPI() : false,
      canReachFirebase: _isConnected ? await canReachFirebase() : false,
    );
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _currentConnectivityResults = results;
    final wasConnected = _isConnected;
    
    // Determine if connected based on connectivity results
    _isConnected = results.isNotEmpty && 
                   !results.every((result) => result == ConnectivityResult.none);
    
    // Notify listeners if connection status changed
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
      debugPrint('Network connectivity changed: ${_isConnected ? 'Connected' : 'Disconnected'} ($connectionType)');
    }

    // For more accurate internet connectivity, perform a test when connected
    if (_isConnected) {
      hasInternetAccess();
    }
  }

  /// Update connectivity status from the platform
  Future<void> _updateConnectivityStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      _isConnected = false;
      _currentConnectivityResults = [ConnectivityResult.none];
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Detailed connectivity information
class ConnectivityInfo {
  final bool isConnected;
  final List<ConnectivityResult> connectivityResults;
  final String connectionType;
  final bool hasInternetAccess;
  final bool canReachClaudeAPI;
  final bool canReachFirebase;

  const ConnectivityInfo({
    required this.isConnected,
    required this.connectivityResults,
    required this.connectionType,
    required this.hasInternetAccess,
    required this.canReachClaudeAPI,
    required this.canReachFirebase,
  });

  @override
  String toString() {
    return 'ConnectivityInfo{\n'
           '  isConnected: $isConnected,\n'
           '  connectionType: $connectionType,\n'
           '  hasInternetAccess: $hasInternetAccess,\n'
           '  canReachClaudeAPI: $canReachClaudeAPI,\n'
           '  canReachFirebase: $canReachFirebase\n'
           '}';
  }

  /// Convert to JSON for debugging or logging
  Map<String, dynamic> toJson() {
    return {
      'isConnected': isConnected,
      'connectionType': connectionType,
      'hasInternetAccess': hasInternetAccess,
      'canReachClaudeAPI': canReachClaudeAPI,
      'canReachFirebase': canReachFirebase,
      'connectivityResults': connectivityResults.map((e) => e.name).toList(),
    };
  }
}

/// Mixin for widgets that need to respond to connectivity changes
mixin ConnectivityMixin {
  StreamSubscription<bool>? _connectivitySubscription;

  /// Start listening to connectivity changes
  void startConnectivityListening() {
    _connectivitySubscription = NetworkInfo().onConnectivityChanged.listen(
      onConnectivityChanged,
      onError: (error) {
        debugPrint('Connectivity listener error: $error');
      },
    );
  }

  /// Stop listening to connectivity changes
  void stopConnectivityListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Override this method to handle connectivity changes
  void onConnectivityChanged(bool isConnected);
}

/// Utility extensions for connectivity
extension ConnectivityResultExtensions on ConnectivityResult {
  /// Check if this result indicates an active connection
  bool get isConnected => this != ConnectivityResult.none;

  /// Get a user-friendly description of the connection type
  String get description {
    switch (this) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Check if this is a metered connection (mobile data)
  bool get isMetered => this == ConnectivityResult.mobile;

  /// Check if this is a high-speed connection
  bool get isHighSpeed => 
      this == ConnectivityResult.wifi || 
      this == ConnectivityResult.ethernet;
}