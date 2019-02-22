package com.ikonfete.ikonfetemobile.ikonfetemobile;

import android.content.Intent;
import android.os.Bundle;

import com.ikonfete.ikonfetemobile.ikonfetemobile.deezer.DeezerChannels;
import com.ikonfete.ikonfetemobile.ikonfetemobile.spotify.SpotifyChannels;
import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationResponse;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final int SPOTIFY_AUTH_REQUEST_CODE = 1221;
    private SpotifyChannels spotifyChannels;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new DeezerChannels().initialize(this, getFlutterView());
        spotifyChannels = new SpotifyChannels(this, getFlutterView(), SPOTIFY_AUTH_REQUEST_CODE);
        spotifyChannels.initialize();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == SPOTIFY_AUTH_REQUEST_CODE) {
            AuthenticationResponse response = AuthenticationClient.getResponse(resultCode, data);
            spotifyChannels.handleAuthResponse(response);
        }
    }
}
