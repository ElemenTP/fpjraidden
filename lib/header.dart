//import 'dart:convert';
import 'dart:math';
//import 'dart:io';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart'; //LatLng 类型在这里面，即为点类
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shortpath.dart';

const double BIKESPEED = 0.5;

LatLng latLngfromJson(Map<String, dynamic> json) {
  return LatLng(json['latitude'] as double, json['longitude'] as double);
}

Map<String, dynamic> latLngtoJson(LatLng latLng) {
  return <String, dynamic>{
    'latitude': latLng.latitude,
    'longitude': latLng.longitude,
  };
}

//点集类
class MapVertex {
  List<LatLng> listVertex = [];

  MapVertex();

  MapVertex.fromList(this.listVertex);

  MapVertex.fromJson(Map<String, dynamic> json) {
    List listVertexJson = json['listVertex'] as List;
    listVertexJson.forEach((element) {
      listVertex.add(latLngfromJson(element));
    });
  }

  Map<String, dynamic> toJson() {
    List listVertexJson = [];
    listVertex.forEach((element) {
      listVertexJson.add(latLngtoJson(element));
    });
    return <String, dynamic>{
      'listVertex': listVertexJson,
    };
  }
}

//建筑类
class Building {
  //建筑入口
  List<LatLng> doors = [];
  //建筑入口连接点
  List<int> juncpoint = [];
  //描述集
  List<String> description = [];

  Building();

  LatLng getApproxLocation() {
    double latall = 0;
    double lngall = 0;
    doors.forEach((element) {
      latall += element.latitude;
      lngall += element.longitude;
    });
    return LatLng(latall / doors.length, lngall / doors.length);
  }

  Building.fromJson(Map<String, dynamic> json) {
    List doorsJson = json['doors'] as List;
    doorsJson.forEach((element) {
      doors.add(latLngfromJson(element));
    });
    List juncpointJson = json['juncpoint'] as List;
    juncpointJson.forEach((element) {
      juncpoint.add(element as int);
    });
    List descriptionJson = json['description'] as List;
    descriptionJson.forEach((element) {
      description.add(element as String);
    });
  }

  Map<String, dynamic> toJson() {
    List doorsJson = [];
    doors.forEach((element) {
      doorsJson.add(latLngtoJson(element));
    });
    return <String, dynamic>{
      'doors': doorsJson,
      'juncpoint': juncpoint,
      'description': description,
    };
  }
}

//建筑集类
class MapBuilding {
  List<Building> listBuilding = [];

  MapBuilding();

  MapBuilding.fromJson(Map<String, dynamic> json) {
    List listBuildingJson = json['listBuilding'] as List;
    listBuildingJson.forEach((element) {
      listBuilding.add(Building.fromJson(element));
    });
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'listBuilding': listBuilding,
    };
  }
}

//校区类
class MapCampus {
  List<LatLng> campusShape = [];
  int gate = 0;
  int busstop = 0;
  String name = 'My Campus';

  MapCampus();

  MapCampus.fromJson(Map<String, dynamic> json) {
    List campusShapeJson = json['campusShape'] as List;
    campusShapeJson.forEach((element) {
      campusShape.add(latLngfromJson(element));
    });
    gate = json['gate'] as int;
    busstop = json['busstop'] as int;
    name = json['name'] as String;
  }

  Map<String, dynamic> toJson() {
    List campusShapeJson = [];
    campusShape.forEach((element) {
      campusShapeJson.add(latLngtoJson(element));
    });
    return <String, dynamic>{
      'campusShape': campusShapeJson,
      'gate': gate,
      'busstop': busstop,
      'name': name,
    };
  }
}

//边类
class Edge {
  int pointa = -1;
  int pointb = -1;
  //边长度，建造函数自动生成
  double length = double.infinity;
  //边适应性，默认不通（<0），仅可步行(0)，可使用自行车(1)
  int availmthod = -1;
  //边拥挤度，需要时调用随机方法生成。
  double crowding = 1;

  //默认构造函数，将生成不通的边
  Edge();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pointa': pointa,
      'pointb': pointb,
      'length': length,
      'availmthod': availmthod,
    };
  }

  Edge.fromJson(Map<String, dynamic> json) {
    pointa = json['pointa'] ?? -1;
    pointb = json['pointb'] ?? -1;
    length = json['length'] ?? double.infinity;
    availmthod = json['availmthod'] ?? -1;
  }
}

//边集类
class MapEdge {
  List<Edge> listEdge = [];

  bool crowded = false;

  MapEdge();

  MapEdge.fromJson(Map<String, dynamic> json) {
    List listEdgeJson = json['listEdge'] as List;
    listEdgeJson.forEach((element) {
      listEdge.add(Edge.fromJson(element));
    });
  }

  Map<String, dynamic> toJson() {
    /*List listEdgeJson = [];
    listEdge.forEach((element) {
      listEdgeJson.add(element.toJson());
    });*/
    return <String, dynamic>{
      'listEdge': listEdge,
    };
  }
}

//校车时间表类
class BusTimeTable {
  //始发校区编号
  int campusFrom = 0;
  //目的校区编号
  int campusTo = 0;
  //出发时间的时
  int setOutHour = 0;
  //出发时间的分
  int setOutMinute = 0;
  //星期几？1-7，7是周日
  int dayOfWeek = 1;

  BusTimeTable();

  BusTimeTable.fromJson(Map<String, dynamic> json) {
    campusFrom = json['campusFrom'] as int;
    campusTo = json['campusTo'] as int;
    setOutHour = json['setOutHour'] as int;
    setOutMinute = json['setOutMinute'] as int;
    dayOfWeek = json['dayOfWeek'] as int;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'campusFrom': campusFrom,
      'campusTo': campusTo,
      'setOutHour': setOutHour,
      'setOutMinute': setOutMinute,
      'dayOfWeek': dayOfWeek,
    };
  }
}

//地图数据类
class MapData {
  //校区与编号的对应表
  List<MapCampus> mapCampus = [];
  //建筑列表
  List<MapBuilding> mapBuilding = [];
  //点与编号对应表
  List<MapVertex> mapVertex = [];
  //边与地图结构数据，按校区分成多个
  List<MapEdge> mapEdge = [];
  //校车时间表
  List<BusTimeTable> busTimeTable = [];

  MapData();

  MapData.fromJson(Map<String, dynamic> json) {
    List mapCampusJson = json['mapCampus'] as List;
    mapCampusJson.forEach((element) {
      mapCampus.add(MapCampus.fromJson(element));
    });
    List mapBuildingJson = json['mapBuilding'] as List;
    mapBuildingJson.forEach((element) {
      mapBuilding.add(MapBuilding.fromJson(element));
    });
    List mapVertexJson = json['mapVertex'] as List;
    mapVertexJson.forEach((element) {
      mapVertex.add(MapVertex.fromJson(element));
    });
    List mapEdgeJson = json['mapEdge'] as List;
    mapEdgeJson.forEach((element) {
      mapEdge.add(MapEdge.fromJson(element));
    });
    List busTimeTableJson = json['busTimeTable'] as List;
    busTimeTableJson.forEach((element) {
      busTimeTable.add(BusTimeTable.fromJson(element));
    });
    for (int i = 0; i < mapEdge.length; ++i) {
      List<Edge> curListEdge = mapEdge[i].listEdge;
      for (int j = 0; j < curListEdge.length; ++j) {
        Edge curEdge = curListEdge[j];
        if (curEdge.availmthod >= 0 && curEdge.length == double.infinity) {
          curEdge.length = AMapTools.distanceBetween(
              mapVertex[i].listVertex[curEdge.pointa],
              mapVertex[i].listVertex[curEdge.pointb]);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mapCampus': mapCampus,
      'mapBuilding': mapBuilding,
      'mapVertex': mapVertex,
      'mapEdge': mapEdge,
      'busTimeTable': busTimeTable,
    };
  }

  int locationInCampus(LatLng location) {
    for (int i = 0; i < mapCampus.length; ++i) {
      if (AMapTools.latLngIsInPolygon(location, mapCampus[i].campusShape))
        return i;
    }
    return -1;
  }

  int buildingInCampus(Building building) {
    for (int i = 0; i < mapCampus.length; ++i) {
      if (mapBuilding[i].listBuilding.contains(building)) return i;
    }
    return -1;
  }

  List<List<Edge>> getAdjacentMatrix(int campusNum) {
    List<Edge> listEdge = mapEdge[campusNum].listEdge;
    int squareSize = mapVertex[campusNum].listVertex.length;
    List<List<Edge>> tmp = List.generate(
        squareSize, (_) => List.generate(squareSize, (_) => Edge()));
    listEdge.forEach((element) {
      tmp[element.pointa][element.pointb] = element;
      tmp[element.pointb][element.pointa] = element;
    });
    return tmp;
  }

  int nearestVertex(int campusNum, LatLng location) {
    List<LatLng> listVertex = mapVertex[campusNum].listVertex;
    late int shortestVtx;
    double shortestLength = double.infinity;
    for (int i = 0; i < listVertex.length; ++i) {
      double tmp = AMapTools.distanceBetween(location, listVertex[i]);
      if (tmp < shortestLength) {
        shortestVtx = i;
        shortestLength = tmp;
      }
    }
    return shortestVtx;
  }

  LatLng getVertexLatLng(int campusNum, int vertexNum) {
    return mapVertex[campusNum].listVertex[vertexNum];
  }

  //随机拥挤度函数
  void randomCrowding() {
    mapEdge.forEach((element) {
      if (!element.crowded) {
        element.listEdge.forEach((element) {
          element.crowding = 1.0 - Random().nextDouble();
        });
        element.crowded = true;
      }
    });
  }

  void disableCrowding() {
    mapEdge.forEach((element) {
      if (element.crowded) {
        element.listEdge.forEach((element) {
          element.crowding = 1;
        });
        element.crowded = false;
      }
    });
  }
}

//导航状态类
class NaviState {
  bool naviStatus = false;
  bool crowding = false;
  bool onbike = false;
  bool startOnUserLoc = false;
  dynamic start;
  List end = [];

  NaviState();

  Future<bool> manageNaviState(BuildContext context) async {
    return await showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
                  builder: (context, _setState) => AlertDialog(
                    title: Text('导航'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getStartWidget(_setState),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('以当前位置为起点：'),
                              Switch(
                                  value: startOnUserLoc,
                                  onChanged: (state) {
                                    _setState(() => startOnUserLoc = state);
                                    start = null;
                                    mapMarkers.remove('start');
                                  })
                            ],
                          ),
                          LimitedBox(
                            maxHeight: 270,
                            child: SingleChildScrollView(
                              child: _getEndWidget(_setState),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _setState(() => end.clear());
                              mapMarkers.removeWhere(
                                  (key, value) => key.contains('end'));
                            },
                            icon: Icon(Icons.delete),
                            label: Text('清除全部终点'),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('骑车：'),
                              Switch(
                                  value: onbike,
                                  onChanged: (state) {
                                    _setState(() => onbike = state);
                                  })
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('拥挤：'),
                              Switch(
                                  value: crowding,
                                  onChanged: (state) =>
                                      _setState(() => crowding = state))
                            ],
                          ),
                          Text(
                            '提示：点击可删除起点/终点',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('取消'),
                        onPressed: () =>
                            Navigator.of(context).pop(false), //关闭对话框
                      ),
                      TextButton(
                        child: Text('停止'),
                        onPressed: naviStatus
                            ? () {
                                naviStatus = false;
                                Navigator.of(context).pop(true);
                              }
                            : null, //关闭对话框
                      ),
                      TextButton(
                        child: Text('开始'),
                        onPressed:
                            (startOnUserLoc || start != null) && end.isNotEmpty
                                ? () {
                                    naviStatus = true;
                                    Navigator.of(context).pop(true);
                                  }
                                : null, //关闭对话框
                      ),
                    ],
                  ),
                )) ??
        false;
  }

  Widget _getStartWidget(void Function(void Function()) setState) {
    if (startOnUserLoc) {
      return Card(
        child: ListTile(
          title: Text('当前位置。'),
        ),
      );
    } else if (start.runtimeType == LatLng) {
      return Card(
        child: ListTile(
          title: Text('坐标：${start!.longitude}，${start!.latitude}。'),
          onTap: () {
            setState(() => start = null);
            mapMarkers.remove('start');
          },
        ),
      );
    } else if (start.runtimeType == Building) {
      return Card(
        child: ListTile(
          title: Text('建筑：${start!.description[0]}。'),
          onTap: () {
            setState(() => start = null);
            mapMarkers.remove('start');
          },
        ),
      );
    } else {
      return Card(
        child: ListTile(
          title: Text('未设置出发点。'),
        ),
      );
    }
  }

  Widget _getEndWidget(void Function(void Function()) setState) {
    List<Widget> inColumn = [];
    end.forEach((element) {
      inColumn.add(element.runtimeType == LatLng
          ? Card(
              child: ListTile(
                title: Text('坐标：${element.longitude}，${element.latitude}。'),
                onTap: () {
                  setState(() => end.remove(element));
                  mapMarkers.remove('end' + element.hashCode.toString());
                },
              ),
            )
          : Card(
              child: ListTile(
                title: Text('建筑：${element.description[0]}。'),
                onTap: () {
                  setState(() => end.remove(element));
                  mapMarkers.remove('end' + element.hashCode.toString());
                },
              ),
            ));
    });
    if (inColumn.isEmpty)
      inColumn.add(Card(
        child: ListTile(
          title: Text('未设置目的地。'),
        ),
      ));
    return Column(
      children: inColumn,
    );
  }
}

//导航工具类
class NaviTools {
  //导航道路，传入dijstra得到的route和某校区点集，返回直线
  static void displayRoute(List<int> path, int campusNum) {
    const Map<int, dynamic> colortype = {
      3: Colors.green,
      2: Colors.amber,
      1: Colors.red,
      0: Colors.black,
    };
    List<List<Edge>> edgevertex = mapData.getAdjacentMatrix(campusNum);
    List<LatLng> listvertex = mapData.mapVertex[campusNum].listVertex;
    for (int i = 0; i < path.length - 1; ++i) {
      int a = edgevertex[path[i]][path[i + 1]].crowding * 3 ~/ 1;
      Polyline polyline = Polyline(
        points: <LatLng>[listvertex[path[i]], listvertex[path[i + 1]]],
        color: colortype[a],
        capType: CapType.arrow,
        joinType: JoinType.round,
      );
      mapPolylines[(mapPolylines.length).toString()] = polyline;
    }
  }

  //传入两点（建筑点和路径点），返回虚线
  static void entryRoute(LatLng road, LatLng entry) {
    Polyline polyline = Polyline(
      points: <LatLng>[road, entry],
      dashLineType: DashLineType.circle,
    );
    mapPolylines[(mapPolylines.length).toString()] = polyline;
  }

  //生成一个以某点为中心的近似圆
  static void circleAround(LatLng center) {
    const int times = 36; //多边形的点数
    Offset res = Offset(center.latitude, center.longitude);
    List<LatLng> circlelist = [];
    for (int i = 0; i < times; ++i) {
      Offset c = Offset.fromDirection(i * 2 * pi / times, 1 / 1000);
      Offset c1 = Offset(
          res.dx + c.dx, res.dy + c.dy / cos((res.dx + c.dx) / 180 * pi));

      circlelist.add(LatLng(c1.dx, c1.dy));
    }
    Color col = Colors.deepOrange.shade100;

    Polygon circle = Polygon(
        points: circlelist,
        fillColor: Color(0),
        strokeColor: col,
        strokeWidth: 0.4);
  }

  //生成一个点到一条边的垂足（存在误差），适用地区范围有限制北京地区
  static void trailTract(LatLng point, LatLng pointa, LatLng pointb) {
    Offset a = Offset(pointa.latitude, pointa.longitude);
    Offset b = Offset(pointb.latitude, pointb.longitude);
    Offset s = Offset(point.latitude, point.longitude);
    Offset res = AMapTools.getVerticalPointOnLine(s, a, b);
    LatLng vertical = LatLng(res.dx, res.dy);
  }
}

//用户设置
late SharedPreferences prefs;

//地图数据
late MapData mapData;

//导航状态
NaviState navistate = NaviState();

//地图Marker
Map<String, Marker> mapMarkers = {};

//地图直线
Map<String, Polyline> mapPolylines = {};

//地图控制器
AMapController? mapController;

//用户位置
AMapLocation userLocation = AMapLocation(latLng: LatLng(39.909187, 116.397451));

//定位权限状态
PermissionStatus locatePermissionStatus = PermissionStatus.denied;

//检查定位是否正常
bool stateLocationReqiurement(BuildContext context) {
  //没有定位权限，提示用户授予权限
  if (!locatePermissionStatus.isGranted) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('提示'),
              content: Text('欲使用此功能，请授予定位权限。'),
              actions: <Widget>[
                TextButton(
                  child: Text('取消'),
                  onPressed: () => Navigator.of(context).pop(), //关闭对话框
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    locatePermissionStatus =
                        await Permission.location.request();
                    Navigator.of(context).pop();
                  }, //关闭对话框
                ),
              ],
            ));
    return false;
  }
  //定位不正常（时间time为0），提示用户打开定位开关
  else if (userLocation.time == 0) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('提示'),
              content: Text('未开启系统定位开关，或者系统定位出错。'),
              actions: <Widget>[
                TextButton(
                  child: Text('确定'),
                  onPressed: () => Navigator.of(context).pop(), //关闭对话框
                ),
              ],
            ));
    return false;
  } else {
    return true;
  }
}

Future<bool> showRoute(BuildContext context) async {
  if (navistate.startOnUserLoc) {
    if (stateLocationReqiurement(context)) {
      int startCampus = mapData.locationInCampus(userLocation.latLng);
      if (startCampus >= 0) {
        navistate.start = userLocation.latLng;
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('提示'),
                  content: Text('您不在任何校区内。'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.of(context).pop(), //关闭对话框
                    ),
                  ],
                ));
        return false;
      }
    } else {
      return false;
    }
  }
  List naviOrder = [navistate.start];
  naviOrder.addAll(navistate.end);
  for (int i = 0; i < naviOrder.length - 2; ++i) {
    int nextEnd = i + 1;
    double minDistance = double.infinity;
    for (int j = i + 1; j < naviOrder.length; ++j) {
      double curDistance = AMapTools.distanceBetween(
          getLocation(naviOrder[i]), getLocation(naviOrder[j]));
      if (curDistance < minDistance) {
        minDistance = curDistance;
        nextEnd = j;
      }
    }
    if (nextEnd != i + 1) {
      var tmp = naviOrder[i + 1];
      naviOrder[i + 1] = naviOrder[nextEnd];
      naviOrder[nextEnd] = tmp;
    }
  }
  int transmethod = navistate.onbike ? 1 : 0;
  navistate.crowding ? mapData.randomCrowding() : mapData.disableCrowding();
  double relativeLength = 0;
  for (int i = 0; i < naviOrder.length; ++i) {
    int campusNum = 0;
    if (naviOrder[i].runtimeType == LatLng) {
      campusNum = mapData.locationInCampus(naviOrder[i]);
      int nearVertex = mapData.nearestVertex(campusNum, naviOrder[i]);
      LatLng nearLatLng = mapData.getVertexLatLng(campusNum, nearVertex);
      relativeLength += (AMapTools.distanceBetween(nearLatLng, naviOrder[i]) *
              (navistate.onbike ? BIKESPEED : 1)) /
          (navistate.crowding ? 1 - Random().nextDouble() : 1);
      NaviTools.entryRoute(nearLatLng, naviOrder[i]);
      naviOrder[i] = NaviLoc(campusNum, nearVertex, naviOrder[i]);
    } else if (naviOrder[i].runtimeType == Building) {
      Building curBuilding = naviOrder[i] as Building;
      campusNum = mapData.buildingInCampus(curBuilding);
      LatLng disReference = i == 0
          ? getLocation(naviOrder[1])
          : (naviOrder[i - 1] as NaviLoc).location;
      int choosedDoor = 0;
      if (curBuilding.doors.length > 1) {
        double minDistance = double.infinity;
        for (int j = 0; j < curBuilding.doors.length; ++j) {
          double curDistance =
              AMapTools.distanceBetween(disReference, curBuilding.doors[j]);
          if (curDistance < minDistance) {
            minDistance = curDistance;
            choosedDoor = j;
          }
        }
      }
      LatLng juncLatLng = mapData.getVertexLatLng(
          campusNum, curBuilding.juncpoint[choosedDoor]);
      relativeLength += (AMapTools.distanceBetween(
                  juncLatLng, curBuilding.doors[choosedDoor]) *
              (navistate.onbike ? BIKESPEED : 1)) /
          (navistate.crowding ? 1 - Random().nextDouble() : 1);
      NaviTools.entryRoute(juncLatLng, curBuilding.doors[choosedDoor]);
      naviOrder[i] = NaviLoc(campusNum, curBuilding.juncpoint[choosedDoor],
          curBuilding.doors[choosedDoor]);
    }
  }
  for (int i = 0; i < naviOrder.length - 1; ++i) {
    NaviLoc startVertex = naviOrder[i] as NaviLoc;
    NaviLoc endVertex = naviOrder[i + 1] as NaviLoc;
    if (startVertex.campusNum == endVertex.campusNum) {
      if (startVertex.vertexNum == endVertex.vertexNum) {
        relativeLength += (AMapTools.distanceBetween(
                    startVertex.location, endVertex.location) *
                (navistate.onbike ? BIKESPEED : 1)) /
            (navistate.crowding ? 1 - Random().nextDouble() : 1);
      } else {
        Shortpath path = Shortpath(
            mapData.getAdjacentMatrix(startVertex.campusNum),
            startVertex.vertexNum,
            endVertex.vertexNum,
            transmethod);
        if (path.getroute().isEmpty) {
          notAWay(context);
          return false;
        }
        relativeLength += path.getrelativelen();
        NaviTools.displayRoute(path.getroute(), startVertex.campusNum);
      }
    } else {
      Shortpath patha = Shortpath(
          mapData.getAdjacentMatrix(startVertex.campusNum),
          startVertex.vertexNum,
          mapData.mapCampus[startVertex.campusNum].busstop,
          transmethod);
      if (patha.getroute().isEmpty) {
        notAWay(context);
        return false;
      }
      relativeLength += patha.getrelativelen();
      NaviTools.displayRoute(patha.getroute(), startVertex.campusNum);
      Shortpath pathb = Shortpath(
          mapData.getAdjacentMatrix(endVertex.campusNum),
          mapData.mapCampus[endVertex.campusNum].busstop,
          endVertex.vertexNum,
          transmethod);
      if (pathb.getroute().isEmpty) {
        notAWay(context);
        return false;
      }
      relativeLength += pathb.getrelativelen();
      NaviTools.displayRoute(pathb.getroute(), endVertex.campusNum);
    }
  }
  return true;
}

void notAWay(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('提示'),
            content: Text('未找到路线。请检查地图数据。'),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(), //关闭对话框
              ),
            ],
          ));
}

LatLng getLocation(dynamic element) {
  if (element.runtimeType == LatLng)
    return element;
  else
    return (element as Building).getApproxLocation();
}

class NaviLoc {
  late int campusNum;
  late int vertexNum;
  late LatLng location;

  NaviLoc(this.campusNum, this.vertexNum, this.location);
}
