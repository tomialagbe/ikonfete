package com.ikonfete.ikonfetemobile.ikonfetemobile.deezer;

import com.deezer.sdk.network.connect.DeezerConnect;
import com.deezer.sdk.network.request.event.DeezerError;
import com.deezer.sdk.player.TrackPlayer;
import com.deezer.sdk.player.event.BufferState;
import com.deezer.sdk.player.event.OnBufferStateChangeListener;
import com.deezer.sdk.player.event.OnPlayerErrorListener;
import com.deezer.sdk.player.event.OnPlayerProgressListener;
import com.deezer.sdk.player.event.OnPlayerStateChangeListener;
import com.deezer.sdk.player.event.PlayerState;
import com.deezer.sdk.player.exception.TooManyPlayersExceptions;
import com.deezer.sdk.player.networkcheck.NetworkStateCheckerFactory;

import androidx.appcompat.app.AppCompatActivity;

public class DeezerTrackPlayer implements OnBufferStateChangeListener, OnPlayerStateChangeListener, OnPlayerProgressListener, OnPlayerErrorListener {
    private DeezerConnect deezerConnect;
    private AppCompatActivity activity;
    private TrackPlayer trackPlayer;
    private DeezerTrackPlayerEventListener playerEventListener;

    private PlayerState playerState;
    private BufferState bufferState;

    private double bufferPercent;
    private long timePosition;

    DeezerTrackPlayer(AppCompatActivity activity, DeezerConnect deezerConnect, DeezerTrackPlayerEventListener playerEventListener) {
        this.activity = activity;
        this.deezerConnect = deezerConnect;
        this.playerEventListener = playerEventListener;
        try {
            trackPlayer = new TrackPlayer(activity.getApplication(), deezerConnect, NetworkStateCheckerFactory.wifiAndMobile());
            trackPlayer.addOnPlayerStateChangeListener(this);
            trackPlayer.addOnBufferStateChangeListener(this);
            trackPlayer.addOnPlayerProgressListener(this);
            trackPlayer.addOnPlayerErrorListener(this);

        } catch (TooManyPlayersExceptions tooManyPlayersExceptions) {
            tooManyPlayersExceptions.printStackTrace();
        } catch (DeezerError deezerError) {
            deezerError.printStackTrace();
        }
    }

    void play(long trackId) {
        trackPlayer.playTrack(trackId);
    }

    void pause() {
        trackPlayer.pause();
    }

    void resume() {
        trackPlayer.play();
    }

    void stop() {
        trackPlayer.stop();
    }

    void close() {
        trackPlayer.release();
    }

    @Override
    public void onBufferStateChange(BufferState bufferState, double v) {
        // v is buffer percent
        this.bufferState = bufferState;
        this.bufferPercent = v;
        if (playerEventListener != null) {
            playerEventListener.onBufferStateChange(bufferState, v);
        }
    }

    @Override
    public void onPlayerError(Exception e, long l) {
        // l is time position in ms
        if (playerEventListener != null) {
            playerEventListener.onPlayerError(e, l);
        }
    }

    @Override
    public void onPlayerProgress(long l) {
        // l is time position in ms
        this.timePosition = l;
        if (playerEventListener != null) {
            playerEventListener.onPlayerProgress(playerState, l);
        }
    }

    @Override
    public void onPlayerStateChange(PlayerState playerState, long l) {
        // l is time position in ms
        this.playerState = playerState;
        this.timePosition = l;
        if (playerEventListener != null) {
            playerEventListener.onPlayerStateChange(playerState, l);
        }
    }

    public interface DeezerTrackPlayerEventListener {
        void onBufferStateChange(BufferState bufferState, double v);

        void onPlayerStateChange(PlayerState playerState, long l);

        void onPlayerProgress(PlayerState state, long l);

        void onPlayerError(Exception e, long l);
    }
}

