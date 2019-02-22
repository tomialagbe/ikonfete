package com.ikonfete.ikonfetemobile.ikonfetemobile.spotify;

import com.spotify.sdk.android.authentication.AuthenticationClient;
import com.spotify.sdk.android.authentication.AuthenticationRequest;
import com.spotify.sdk.android.authentication.AuthenticationResponse;
import com.spotify.sdk.android.player.ConnectionStateCallback;
import com.spotify.sdk.android.player.Player;
import com.spotify.sdk.android.player.PlayerEvent;
import com.spotify.sdk.android.player.SpotifyPlayer;

import androidx.appcompat.app.AppCompatActivity;
import io.flutter.plugin.common.MethodChannel;

public class SpotifyApi implements SpotifyPlayer.NotificationCallback, ConnectionStateCallback {

    private AppCompatActivity activity;
    private String clientId;
    private int authRequestCode;
    private Player player;

    SpotifyApi(AppCompatActivity activity, String clientId, int authRequestCode) {
        this.activity = activity;
        this.clientId = clientId;
        this.authRequestCode = authRequestCode;
    }

    public void login() {
        AuthenticationRequest.Builder builder =
                new AuthenticationRequest.Builder(clientId, AuthenticationResponse.Type.TOKEN,
                        "http://ikonfete.com");
        builder.setShowDialog(false);
        builder.setScopes(new String[]{"user-read-private", "user-read-email",
                "user-library-read", "user-top-read", "user-follow-read", "streaming",});
        AuthenticationRequest authRequest = builder.build();
        AuthenticationClient.openLoginActivity(activity, authRequestCode, authRequest);
    }

    public void setPlayer(Player player) {
        this.player = player;
        player.addNotificationCallback(this);
        player.addConnectionStateCallback(this);
    }

    public void playTrack(String trackId, final MethodChannel.Result result) {

        if (player == null) return;
        player.playUri(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                result.success(true);
            }

            @Override
            public void onError(Error error) {
                result.error(error.name(), error.toString(), error);
            }
        }, String.format("spotify:track:%s", trackId), 0, 0);
    }

    public void pause(final MethodChannel.Result result) {
        if (player == null) return;
        player.pause(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                result.success(true);
            }

            @Override
            public void onError(Error error) {
                result.error(error.name(), error.toString(), error);
            }
        });
    }

    public void resume(final MethodChannel.Result result) {
        if (player == null) return;
        player.resume(new Player.OperationCallback() {
            @Override
            public void onSuccess() {
                result.success(true);
            }

            @Override
            public void onError(Error error) {
                result.error(error.name(), error.toString(), error);
            }
        });
    }

    public void stop(final MethodChannel.Result result) {
        if (player == null) return;
        player.destroy();
    }

    @Override
    public void onLoggedIn() {

    }

    @Override
    public void onLoggedOut() {

    }

    @Override
    public void onLoginFailed(Error error) {

    }

    @Override
    public void onTemporaryError() {

    }

    @Override
    public void onConnectionMessage(String s) {

    }

    @Override
    public void onPlaybackEvent(PlayerEvent playerEvent) {

    }

    @Override
    public void onPlaybackError(Error error) {

    }
}
