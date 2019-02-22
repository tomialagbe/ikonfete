import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';

class ProfileApi extends Api {
  ProfileApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<bool> updateProfile(EditProfileData updateData) async {
    var url =
        "$apiBaseUrl/update_profile?uid=${updateData.uid}&isArtist=${updateData.isArtist}";
    if (!StringUtils.isNullOrEmpty(updateData.displayName)) {
      url += "&displayName=${updateData.displayName}";
    }

    if (!StringUtils.isNullOrEmpty(updateData.bio)) {
      url += "&bio=${updateData.bio}";
    }

    if (!StringUtils.isNullOrEmpty(updateData.countryIsoCode)) {
      url += "&countryISOCode=${updateData.countryIsoCode}";
    }

    if (!StringUtils.isNullOrEmpty(updateData.profilePictureUrl)) {
      url +=
          "&profilePictureURL=${Uri.encodeComponent(updateData.profilePictureUrl)}";
    }

    if (updateData.removeFacebook) {
      url += "&removeFacebook=true";
    } else if (!StringUtils.isNullOrEmpty(updateData.facebookId)) {
      url += "&facebookUID=${updateData.facebookId}";
    }

    if (updateData.removeTwitter) {
      url += "&removeTwitter=true";
    } else if (!StringUtils.isNullOrEmpty(updateData.twitterId)) {
      url += "&twitterUID=${updateData.twitterId}";
    }

    url = Uri.encodeFull(url);

    try {
      final headers = {"Content-Type": "application/x-www-form-urlencoded"};
      http.Response response = await http.post(url, headers: headers);
      switch (response.statusCode) {
        case 200:
          return true;
        default:
          final apierr = ApiError()..fromJson(json.decode(response.body));
          throw new ApiException(apierr.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
