package com.ikonfete.ikonfetemobile.ikonfetemobile.deezer;

import android.app.Activity;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class DeezerChannels {

    private static final String DEEZER_METHOD_CHANNEL = "ikonfete_deezer_method_channel";
    private static final String DEEZER_PLAYER_EVENT_CHANNEL = "ikonfete_deezer_player_event_channel";
    private static final String DEEZER_PLAYER_BUFFER_EVENT_CHANNEL = "ikonfete_deezer_player_buffer_event_channel";
    private static final String DEEZER_APPLICATION_ID = "293124";

    private DeezerApi deezerApi;

    public void initialize(Activity activity, BinaryMessenger binaryMessenger) {

        deezerApi = new DeezerApi(DEEZER_APPLICATION_ID, activity);
        new EventChannel(binaryMessenger, DEEZER_PLAYER_EVENT_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                deezerApi.setPlayerEventSink(eventSink);
            }

            @Override
            public void onCancel(Object o) {
            }
        });

        new EventChannel(binaryMessenger, DEEZER_PLAYER_EVENT_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                deezerApi.setPlayerEventSink(eventSink);
            }

            @Override
            public void onCancel(Object o) {
            }
        });
        new EventChannel(binaryMessenger, DEEZER_PLAYER_BUFFER_EVENT_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                deezerApi.setPlayerBufferEventSink(eventSink);
            }

            @Override
            public void onCancel(Object o) {
            }
        });

        new MethodChannel(binaryMessenger, DEEZER_METHOD_CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                switch (methodCall.method) {
                    case "authorize":
                        deezerApi.authorize(result);
                        break;
                    case "getAccessToken":
                        deezerApi.getAccessToken(result);
                        break;
                    case "logout":
                        deezerApi.logout(result);
                        break;
                    case "isSessionValid":
                        deezerApi.isSessionValid(result);
                        break;
                    case "getCurrentUser":
                        deezerApi.getCurrentUser(result);
                        break;
                    case "getTrack": {
                        long trackId = Long.valueOf(methodCall.argument("trackId").toString());
                        deezerApi.getTrack(trackId, result);
                    }
                    break;
                    case "initializeTrackPlayer":
                        deezerApi.initializeTrackPlayer(result);
                        break;
                    case "playTrack": {
                        long trackId = Long.valueOf(methodCall.argument("trackId").toString());
                        deezerApi.playTrack(trackId, result);
                        break;
                    }
                    case "pause":
                        deezerApi.pausePlayer(result);
                        break;
                    case "resume":
                        deezerApi.resumePlayer(result);
                        break;
                    case "stop":
                        deezerApi.stopPlayer(result);
                        break;
                    case "closePlayer":
                        deezerApi.closePlayer(result);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
    }


}
