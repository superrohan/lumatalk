import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import 'signaling_client.dart';
import 'data_channel_handler.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;

  final SignalingClient _signalingClient = SignalingClient();
  final DataChannelHandler _dataChannelHandler = DataChannelHandler();

  final _onAsrPartialController = StreamController<Map<String, dynamic>>.broadcast();
  final _onAsrFinalController = StreamController<Map<String, dynamic>>.broadcast();
  final _onMtResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _onTtsAudioController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onAsrPartial => _onAsrPartialController.stream;
  Stream<Map<String, dynamic>> get onAsrFinal => _onAsrFinalController.stream;
  Stream<Map<String, dynamic>> get onMtResult => _onMtResultController.stream;
  Stream<Map<String, dynamic>> get onTtsAudio => _onTtsAudioController.stream;

  Future<void> initialize() async {
    await _signalingClient.connect();
    await _createPeerConnection();
    await _setupLocalStream();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(AppConstants.iceServers);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _signalingClient.sendIceCandidate(candidate);
    };

    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _setupDataChannel(channel);
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
    };
  }

  Future<void> _setupLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'sampleRate': AppConstants.sampleRate,
        'channelCount': AppConstants.channels,
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<void> _setupDataChannel(RTCDataChannel channel) async {
    _dataChannel = channel;

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _dataChannelHandler.handleMessage(
        message,
        onAsrPartial: _onAsrPartialController.add,
        onAsrFinal: _onAsrFinalController.add,
        onMtResult: _onMtResultController.add,
        onTtsAudio: _onTtsAudioController.add,
      );
    };
  }

  Future<void> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await _signalingClient.sendOffer(offer);
  }

  Future<void> handleAnswer(RTCSessionDescription answer) async {
    await _peerConnection!.setRemoteDescription(answer);
  }

  Future<void> handleIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void sendControlMessage(Map<String, dynamic> message) {
    _dataChannelHandler.sendMessage(_dataChannel!, message);
  }

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _dataChannel?.close();
    await _peerConnection?.close();
    await _signalingClient.disconnect();

    await _onAsrPartialController.close();
    await _onAsrFinalController.close();
    await _onMtResultController.close();
    await _onTtsAudioController.close();
  }
}
