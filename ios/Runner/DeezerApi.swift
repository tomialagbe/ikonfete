//
//  DeezerApi.swift
//  Runner
//
//  Created by Tomi Alagbe on 07/11/2018.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import Foundation

class DeezerApi : NSObject, DeezerSessionDelegate, DZRPlayerDelegate {
    
    let permissions: [String]! = [
        DeezerConnectPermissionBasicAccess,
        DeezerConnectPermissionEmail,
        DeezerConnectPermissionListeningHistory,
        DeezerConnectPermissionManageLibrary]
    
    let ERROR_CODE_CANCELLED = "deezer_auth_cancelled"
    let ERROR_CODE_EXCEPTION = "deezer_auth_exception"
    let ERROR_CODE_INVALID_SESSION = "deezer_invalid_session"
    
    var requestMgr: DZRRequestManager!
    var deezerPlayer: DZRPlayer!
    var deezerConnect: DeezerConnect!
    var loginResult: FlutterResult!
    var logoutResult: FlutterResult!
    var trackRequest: DZRCancelable?
    
    init(_ applicationId: String!) {
        super.init()
        deezerConnect = DeezerConnect.init(appId: applicationId, andDelegate: self)
        requestMgr = DZRRequestManager.default().sub()
        requestMgr.dzrConnect = deezerConnect
    }
    
    func authorize(_ loginResult: @escaping FlutterResult) -> Void {
        self.loginResult = loginResult
        if deezerConnect.isSessionValid() {
            deezerDidLogin()
        } else {
            deezerConnect.authorize(permissions)
        }
    }
    
    func getAccessToken(_ result: @escaping FlutterResult) -> Void {
        if !deezerConnect.isSessionValid() {
            result(FlutterError.init(code: ERROR_CODE_INVALID_SESSION, message: "Invalid Session", details: nil))
        } else {
            let token = deezerConnect.accessToken
            result(String(token!))
        }
    }
    
    func logout(_ logoutResult: @escaping FlutterResult) -> Void {
        self.logoutResult = logoutResult
        if !deezerConnect.isSessionValid() {
            return
        }
        deezerConnect.accessToken = nil
        deezerConnect.expirationDate = nil
        deezerConnect.logout()
    }
    
    func isSessionValid(_ result: @escaping FlutterResult) -> Void {
        result(deezerConnect.isSessionValid())
    }
    
    func getCurrentUser(_ result: @escaping FlutterResult) -> Void {
        if !deezerConnect.isSessionValid() {
            result(FlutterError.init(code: ERROR_CODE_INVALID_SESSION, message: "Invalid Session", details: nil))
            return
        }
        
        let currentUserId = deezerConnect.userId!
        DZRUser.object(withIdentifier: currentUserId, requestManager: requestMgr, callback: { (a: Any?, e: Error?) -> Void in
            
            if let err = e {
                result(FlutterError.init(code: err.localizedDescription, message: err.localizedDescription, details: nil))
            } else {
                let keyPaths =  ["gender", "email", "name", "firstName", "lastName", "status", "link", "smallImageUrl", "mediumImageUrl", "bigImageUrl"]
                let user = a as! DZRUser
                user.values(forKeyPaths: keyPaths, with: self.requestMgr, callback: { (h: [AnyHashable : Any]?, e: Error?) in
                    var statusStr = ""
                    
                    if let status = h?["status"] as? Int {
                        switch status {
                        case 0:
                            statusStr = "STATUS_FREEMIUM"
                        case 1:
                            statusStr = "STATUS_PREMIUM"
                        case 2:
                            statusStr = "STATUS_PREMIUM_PLUS"
                        default:
                            statusStr = "STATUS_PREMIUM_PLUS"
                        }
                    }
                    
                    let resultMap : NSDictionary = [
                        "id": currentUserId,
                        "gender": h!["gender"]!,
                        "email": h!["email"]!,
                        "name": h!["name"]!,
                        "firstName": h!["firstname"] ?? "",
                        "lastName": h!["lastname"] ?? "",
                        "status": statusStr,
                        "link": h!["link"] ?? "",
                        "smallImageUrl": h!["picture_small"] ?? "",
                        "mediumImageUrl": h!["picture_medium"] ?? "",
                        "bigImageUrl": h!["picture_big"] ?? ""
                    ]
                    
                    result(resultMap)
                })
            }
            return;
        })
    }
    
    func getTrack(_ trackId: Int, _ result: @escaping FlutterResult) -> Void {
        if !deezerConnect.isSessionValid() {
            result(FlutterError.init(code: ERROR_CODE_INVALID_SESSION, message: "Invalid Session", details: nil))
            return
        }
        
        DZRTrack.object(withIdentifier: String(trackId), requestManager: requestMgr, callback: { (a: Any?, e: Error?) -> Void in
            if let err = e {
                result(FlutterError.init(code: err.localizedDescription, message: err.localizedDescription, details: nil))
            } else {
                let keyPaths = ["id", "title", "title_short", "duration", "link", "album.id", "album.title", "album.label", "album.cover_big", "album.cover_medium", "album.cover_small", "artist.id", "artist.name", "artist.picture_big", "artist.picture_medium", "artist.picture_small", "album.release_date"]
                
                let track = a as! DZRTrack
                track.values(forKeyPaths: keyPaths, with: self.requestMgr, callback: { (h: [AnyHashable: Any]?, e: Error?) in
                    var releaseDateEpochMillis: Int = 0
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    var releaseDateStr = ""
                    if h!["album.release_date"] != nil {
                        releaseDateStr = h!["album.release_date"] as! String
                        let releaseDate = formatter.date(from: releaseDateStr)
                        releaseDateEpochMillis = Int(((releaseDate?.timeIntervalSince1970)! * 1000.0).rounded())
                    }
                    
                    let resultMap : NSDictionary = [
                        "id": h!["id"]!,
                        "albumId": h!["album.id"] ?? -1,
                        "albumTitle": h!["album.title"] ?? "",
                        "albumLabel": h!["album.label"] ?? "",
                        "albumBigImageUrl": h!["album.cover_big"] ?? "",
                        "albumMediumImageUrl": h!["album.cover_medium"] ?? "",
                        "albumSmallImageUrl": h!["album.cover_small"] ?? "",
                        "artistId": h!["artist.id"] ?? -1,
                        "artistName": h!["artist.name"] ?? "",
                        "artistBigImageUrl": h!["artist.picture_big"] ?? "",
                        "artistMediumImageUrl": h!["artist.picture_medium"] ?? "",
                        "artistSmallImageUrl": h!["artist.picture_small"] ?? "",
                        "duration": h!["duration"] ?? 0,
                        "link": h!["link"] ?? "",
                        "releaseDate": releaseDateEpochMillis ,
                        "shortTitle": h!["title_short"] ?? "",
                        "title": h!["title"] ?? "",
                        ]
                    
                    result(resultMap)
                })
            }
        })
    }
    
    func initializeTrackPlayer(_ result : @escaping FlutterResult) -> Void {
        deezerPlayer = DZRPlayer.init(connection: deezerConnect)
        deezerPlayer.delegate = self
        deezerPlayer.networkType = DZRPlayerNetworkType.wifiAnd3G
        result(true)
    }
    
    func playTrack(_ trackId: Int64, _ result: @escaping FlutterResult) -> Void {
        self.trackRequest?.cancel()
        self.deezerPlayer.stop()
        print("Loading track")
        self.trackRequest = DZRTrack.object(withIdentifier: String(trackId), requestManager: requestMgr, callback: { (a: Any?, e: Error?) -> Void in
            if let err = e {
                result(FlutterError.init(code: err.localizedDescription, message: err.localizedDescription, details: nil))
                return;
            }
            
            let track = a as! DZRTrack
            self.deezerPlayer.play(track)
            result(nil)
        })
    }
    
    func pause() -> Void {
        self.deezerPlayer.pause()
    }
    
    func resume() -> Void {
        self.deezerPlayer.play()
    }
    
    func stop() -> Void {
        self.deezerPlayer.stop();
    }
    
    /**
     PLAYER DELEGATE METHODS
     */
    //    @objc(player:didBufferBufferedBytes:outOfTotalBytes:)
    func player(_ player: DZRPlayer!, didBuffer bufferedBytes: Int64, outOf totalBytes: Int64) {
        print("DID BUFFER BYTES")
    }
    
    //    @objc(player:didPlay:outOf:)
    func player(_ player: DZRPlayer!, didPlay playedBytes: Int64, outOf totalBytes: Int64) -> Void {
        print("DID PLAY BYTES")
    }
    
    //    @objc(player:didStartPlayingTrack:)
    func player(_ player: DZRPlayer!, didStartPlaying track: DZRTrack) -> Void {
        print("DID START PLAYING TRACK")
    }
    
    //    @objc(player:didEncounterError:)
    func player(_ player: DZRPlayer!, didEncounterError error: Error!) -> Void {
        print("DID ENCOUNTER ERROR")
    }
    
    //    @objc(playerDidPause:)
    func playerDidPause(_ player: DZRPlayer!) {
        print("PLAYER DID PAUSE")
    }
    
    /**
     SESSION DELEGATE METHODS
     */
    func deezerDidLogin() -> Void {
        let resultMap: NSDictionary = [
            "success": true,
            "access_token": deezerConnect!.accessToken,
            "expires": Int((deezerConnect.expirationDate.timeIntervalSince1970 * 1000.0).rounded())
        ]
        loginResult(resultMap)
    }
    
    func deezerDidNotLogin(cancelled: Bool) -> Void {
        if cancelled {
            loginResult(FlutterError.init(code: ERROR_CODE_CANCELLED,
                                          message: "Deezer Authentication Cancelled",
                                          details: nil))
        } else {
            loginResult(FlutterError.init(code: ERROR_CODE_EXCEPTION, message: "Deezer authentication failed", details: nil))
        }
    }
    
    func deezerDidLogout() -> Void {
        logoutResult(true)
    }
    
}
