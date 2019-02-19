package com.ikonfete.ikonfetemobile.ikonfetemobile.spotify;


import android.util.Log;

import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.player.Config;
import com.spotify.sdk.android.player.Spotify;
import com.spotify.sdk.android.player.SpotifyPlayer;

import java.util.HashMap;
import java.util.Map;

import androidx.appcompat.app.AppCompatActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SpotifyChannels {

    private static final String SPOTIFY_CLIENT_ID = "32b3180329a040b0967ce130abecb1a3";

    private static final String SPOTIFY_METHOD_CHANNEL = "ikonfete_spotify_method_channel";

    private SpotifyApi spotifyApi;
    private AppCompatActivity activity;
    private BinaryMessenger binaryMessenger;
    private int spotifyAuthActivityRequestCode;
    private MethodChannel.Result loginResultHandler;

    public SpotifyChannels(AppCompatActivity activity, BinaryMessenger binaryMessenger, int spotifyAuthActivityRequestCode) {
        this.activity = activity;
        this.binaryMessenger = binaryMessenger;
        this.spotifyAuthActivityRequestCode = spotifyAuthActivityRequestCode;
    }

    public void initialize() {
        spotifyApi = new SpotifyApi(activity, SPOTIFY_CLIENT_ID, spotifyAuthActivityRequestCode);

        new MethodChannel(binaryMessenger, SPOTIFY_METHOD_CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                switch (methodCall.method) {
                    case "login":
                        loginResultHandler = result;
                        spotifyApi.login();
                        break;
                    case "play":
                        String trackId = methodCall.argument("trackId");
                        spotifyApi.playTrack(trackId, result);
                        break;
                    case "pause":
                        spotifyApi.pause(result);
                        break;
                    case "resume":
                        spotifyApi.resume(result);
                        break;
                    case "stop":
                        break;
                    default:
                        result.notImplemented();
                }
            }
        });
    }

    public void handleAuthResponse(AuthenticationResponse response) {
        Map<String, Object> resultMap = new HashMap<>();
        if (response.getType() == AuthenticationResponse.Type.TOKEN) {
            if (loginResultHandler != null) {
                resultMap.put("success", true);
                resultMap.put("access_token", response.getAccessToken());
                loginResultHandler.success(resultMap);
            }

            Config playerConfig = new Config(activity, response.getAccessToken(), SPOTIFY_CLIENT_ID);
            Spotify.getPlayer(playerConfig, this, new SpotifyPlayer.InitializationObserver() {
                @Override
                public void onInitialized(SpotifyPlayer spotifyPlayer) {
                    spotifyApi.setPlayer(spotifyPlayer);
                }

                @Override
                public void onError(Throwable throwable) {
                    Log.e("MainActivity", "Could not initialize player: " + throwable.getMessage());
                }
            });
        } else if (response.getType() == AuthenticationResponse.Type.ERROR){
            resultMap.put("success", false);
            resultMap.put("cancelled", false);
            resultMap.put("error", response.getError());
            loginResultHandler.success(resultMap);
        } else if (response.getType() == AuthenticationResponse.Type.EMPTY) {
            resultMap.put("success", false);
            resultMap.put("cancelled", true);
            loginResultHandler.success(resultMap);
        }
    }
}
