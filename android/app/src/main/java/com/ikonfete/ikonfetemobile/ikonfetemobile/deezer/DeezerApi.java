package com.ikonfete.ikonfetemobile.ikonfetemobile.deezer;

import android.os.Bundle;

import com.deezer.sdk.model.Permissions;
import com.deezer.sdk.model.Track;
import com.deezer.sdk.model.User;
import com.deezer.sdk.network.connect.DeezerConnect;
import com.deezer.sdk.network.connect.SessionStore;
import com.deezer.sdk.network.connect.event.DialogListener;
import com.deezer.sdk.network.request.DeezerRequest;
import com.deezer.sdk.network.request.DeezerRequestFactory;
import com.deezer.sdk.network.request.event.JsonRequestListener;
import com.deezer.sdk.player.event.BufferState;
import com.deezer.sdk.player.event.PlayerState;
import com.ikonfete.ikonfetemobile.ikonfetemobile.BuildConfig;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import androidx.appcompat.app.AppCompatActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class DeezerApi {

    private final String[] permissions = new String[]{
            Permissions.BASIC_ACCESS,
            Permissions.EMAIL,
            Permissions.LISTENING_HISTORY,
            Permissions.MANAGE_LIBRARY,
    };
    private static final String ERROR_CODE_CANCELLED = "deezer_auth_cancelled";
    private static final String ERROR_CODE_EXCEPTION = "deezer_auth_exception";
    private static final String ERROR_CODE_INVALID_SESSION = "deezer_invalid_session";


    private DeezerConnect deezerConnect;
    private SessionStore sessionStore;
    private AppCompatActivity activity;
    //    private String applicationId;
    private DeezerTrackPlayer deezerTrackPlayer;
    private EventChannel.EventSink playerEventSink;
    private EventChannel.EventSink playerBufferEventSink;

    DeezerApi(String applicationId, AppCompatActivity activity) {
        this.activity = activity;
//        this.applicationId = applicationId;
        this.sessionStore = new SessionStore();
        deezerConnect = new DeezerConnect(activity, applicationId);
    }

    void authorize(final MethodChannel.Result result) {
        if (sessionStore.restore(deezerConnect, activity)) {
            result.success(true);
        } else {
            final Map<String, Object> resultMap = new HashMap<>();
            deezerConnect.authorize(activity, permissions, new DialogListener() {
                @Override
                public void onComplete(Bundle bundle) {
                    for (String key : bundle.keySet()) {
                        System.out.println(key + ": " + bundle.get(key).toString());
                    }
                    sessionStore.save(deezerConnect, activity);
                    resultMap.put("success", true);
                    resultMap.put("access_token", bundle.get("access_token"));
                    resultMap.put("expires", bundle.get("expires"));
                    result.success(resultMap);
                }

                @Override
                public void onCancel() {
                    result.error(ERROR_CODE_CANCELLED, "Deezer authentication canceled", null);
                }

                @Override
                public void onException(Exception e) {
                    result.error(ERROR_CODE_EXCEPTION, "Deezer authentication failed with exception: " + e.getMessage(), e);
                }
            });
        }
    }

    void getAccessToken(final MethodChannel.Result result) {
        if (deezerConnect.isSessionValid() && deezerConnect.getAccessToken() != null) {
            result.success(deezerConnect.getAccessToken());
        } else {
            result.error(ERROR_CODE_INVALID_SESSION, "Invalid Session", null);
        }
    }

    void isSessionValid(final MethodChannel.Result result) {
        result.success(deezerConnect.isSessionValid());
    }

    void logout(final MethodChannel.Result result) {
        deezerConnect.logout(activity);
        result.success(null);
    }

    void getCurrentUser(final MethodChannel.Result result) {
        if (BuildConfig.DEBUG && !deezerConnect.isSessionValid()) {
            throw new AssertionError("Invalid Deezer Session");
        }

        User user = deezerConnect.getCurrentUser();
        if (user == null) {
            result.error(ERROR_CODE_INVALID_SESSION, "Invalid Deezer Session", null);
            return;
        }

        Map<String, Object> userMap = new HashMap<>();
        userMap.put("id", user.getId());
        userMap.put("gender", user.getGender());
        userMap.put("email", user.getEmail());
        userMap.put("name", user.getName());
        userMap.put("firstName", user.getFirstName());
        userMap.put("lastName", user.getLastName());
        String statusString;
        if (user.getStatus() == User.STATUS_FREEMIUM) {
            statusString = "STATUS_FREEMIUM";
        } else if (user.getStatus() == User.STATUS_PREMIUM) {
            statusString = "STATUS_PREMIUM";
        } else {
            statusString = "STATUS_PREMIUM_PLUS";
        }
        userMap.put("status", statusString);
        userMap.put("link", user.getLink());
        userMap.put("smallImageUrl", user.getSmallImageUrl());
        userMap.put("mediumImageUrl", user.getMediumImageUrl());
        userMap.put("bigImageUrl", user.getBigImageUrl());
        result.success(userMap);
    }

    void getTrack(long trackId, final MethodChannel.Result channelResult) {
        DeezerRequest request = DeezerRequestFactory.requestTrack(trackId);
        deezerConnect.requestAsync(request, new JsonRequestListener() {
            @Override
            public void onUnparsedResult(String s, Object o) {
            }

            @Override
            public void onResult(Object result, Object requestId) {
                Track track = (Track) result;
                Map<String, Object> trackMap = new HashMap<>();
                trackMap.put("id", track.getId());
                trackMap.put("albumId", track.getAlbum().getId());
                trackMap.put("albumTitle", track.getAlbum().getTitle());
                trackMap.put("albumLabel", track.getAlbum().getLabel());
                trackMap.put("albumBigImageUrl", track.getAlbum().getBigImageUrl());
                trackMap.put("albumMediumImageUrl", track.getAlbum().getMediumImageUrl());
                trackMap.put("albumSmallImageUrl", track.getAlbum().getSmallImageUrl());
                trackMap.put("artistId", track.getArtist().getId());
                trackMap.put("artistName", track.getArtist().getName());
                trackMap.put("artistBigImageUrl", track.getArtist().getBigImageUrl());
                trackMap.put("artistMediumImageUrl", track.getArtist().getMediumImageUrl());
                trackMap.put("artistSmallImageUrl", track.getArtist().getSmallImageUrl());
                trackMap.put("duration", track.getDuration());
                trackMap.put("link", track.getLink());
                Calendar cal = Calendar.getInstance();
                cal.setTime(track.getReleaseDate());
                trackMap.put("releaseDate", cal.getTimeInMillis());
                trackMap.put("shortTitle", track.getShortTitle());
                trackMap.put("title", track.getTitle());

                channelResult.success(trackMap);
            }

            @Override
            public void onException(Exception e, Object requestId) {
                channelResult.error(e.getLocalizedMessage(), e.getMessage(), e);
            }
        });
    }

    void setPlayerEventSink(EventChannel.EventSink eventSink) {
        playerEventSink = eventSink;
    }

    void setPlayerBufferEventSink(EventChannel.EventSink eventSink) {
        playerBufferEventSink = eventSink;
    }

    void initializeTrackPlayer(MethodChannel.Result result) {
        if (!deezerConnect.isSessionValid()) {
            result.error(ERROR_CODE_INVALID_SESSION, "Invalid Deezer Session", null);
            return;
        }
        deezerTrackPlayer = new DeezerTrackPlayer(activity, deezerConnect, new DeezerTrackPlayer.DeezerTrackPlayerEventListener() {
            @Override
            public void onBufferStateChange(BufferState bufferState, double v) {
                Map<String, Object> bufferEvent = new HashMap<>();
                bufferEvent.put("state", bufferState.name());
                bufferEvent.put("bufferPercent", v);
                playerBufferEventSink.success(bufferEvent);
            }

            @Override
            public void onPlayerStateChange(PlayerState playerState, long l) {
                Map<String, Object> playerEvent = new HashMap<>();
                playerEvent.put("state", playerState.name());
                playerEvent.put("timePosition", l);
                playerEventSink.success(playerEvent);
            }

            @Override
            public void onPlayerProgress(PlayerState playerState, long l) {
                Map<String, Object> playerEvent = new HashMap<>();
                playerEvent.put("state", playerState.name());
                playerEvent.put("timePosition", l);
                playerEventSink.success(playerEvent);
            }

            @Override
            public void onPlayerError(Exception e, long l) {
                playerEventSink.error(e.getLocalizedMessage(), e.getMessage(), e);
            }
        });
        result.success(true);
    }

    void playTrack(long trackId, MethodChannel.Result result) {
        deezerTrackPlayer.play(trackId);
        result.success(null);
    }

    void pausePlayer(MethodChannel.Result result) {
        deezerTrackPlayer.pause();
        result.success(null);
    }

    void resumePlayer(MethodChannel.Result result) {
        deezerTrackPlayer.resume();
        result.success(null);
    }

    void stopPlayer(MethodChannel.Result result) {
        deezerTrackPlayer.stop();
        result.success(null);
    }

    void closePlayer(MethodChannel.Result result) {
        deezerTrackPlayer.close();
        deezerTrackPlayer = null;
        result.success(null);
    }


}
