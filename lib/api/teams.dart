import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/model/team.dart';

class TeamApi extends Api {
  TeamApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Team> getTeamByID(String id) async {
    final url = "$apiBaseUrl/teams/${Uri.encodeComponent(id)}";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final team = Team()..fromJson(data["team"]);
          return team;
        case 404:
          return null;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Team>> getTeams(int page, int size) async {
    final url = "$apiBaseUrl/teams?page=$page&size=$size";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          List<Team> teams = <Team>[];
          Map data = json.decode(response.body);
          List teamMapList = data["teams"];
          for (Map teamMap in teamMapList) {
            final team = new Team()..fromJson(teamMap);
            teams.add(team);
          }
          return teams;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Team>> searchTeams(String query, int page, int size) async {
    query = Uri.encodeComponent(query);
    final url = "$apiBaseUrl/teams/search/?page=$page&size=$size&query=$query";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          List<Team> teams = <Team>[];
          Map data = json.decode(response.body);
          List teamMapList = data["teams"];
          for (Map teamMap in teamMapList) {
            final team = new Team()..fromJson(teamMap);
            teams.add(team);
          }
          return teams;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<bool> addFanToTeam(String teamId, String fanUid) async {
    fanUid = Uri.encodeComponent(fanUid);
    final url = "$apiBaseUrl/teams/$teamId/fans?fanUid=$fanUid";
    try {
      final headers = {"Content-Type": "application/x-www-form-urlencoded"};
      final http.Response response = await http.post(url, headers: headers);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          return data["success"];
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Fan>> getFansInTeam(String teamId, int page, int pageSize) async {
    teamId = Uri.encodeComponent(teamId);
    final url = "$apiBaseUrl/teams/$teamId/fans?page=$page&size=$pageSize";
    try {
      final response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          List resultList = data["result"];
          List<Fan> fans = <Fan>[];
          for (var m in resultList) {
            final fan = Fan()..fromJson(m);
            fans.add(fan);
          }
          return fans;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
