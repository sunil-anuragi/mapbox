import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_practical/config/const.dart';
import 'package:mapbox_practical/service/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap mapboxMap;
  geo.Position? position;
  PointAnnotationManager? pointAnnotationManager;
  List<dynamic> visitData = [];
  List<dynamic> customerData = [];
  List<dynamic> storesData = [];
  var mapLayer = ["Stores", "Customers", "Visits"];
  var isloading = true;
  var istoggle = false;
  Set<String> selectedLayers = {"Stores", "Customers", "Visits"};

  Future<void> _getCurrentLocationAndZoom() async {
    if (kDebugMode) {
      print("get location");
    }

    setState(() {
      isloading = true;
    });
    var result = await LocationService.requestPermission();
    if (result == true) {
      position = await LocationService.getCurrentLocation();
      if (kDebugMode) {
        print("pos${position!.latitude}");
      }
      if (kDebugMode) {
        print("pos${position!.longitude}");
      }
      setState(() {
        isloading = false;
      });
    } else {
      if (kDebugMode) {
        print("take permission");
      }
      openAppSettings();
    }
  }

  showcustomermarker() async {
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    final ByteData bytes =
        await rootBundle.load('assets/images/blue-marker.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    for (var cust in customerData) {
      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(cust['geoLocation']['longitude'],
                  cust['geoLocation']['latitude'])),
          image: imageData,
          iconSize: 0.15);

      pointAnnotationManager?.create(pointAnnotationOptions);
    }
  }

  showvisitMarker() async {
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    final ByteData bytes =
        await rootBundle.load('assets/images/visit-purple.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    for (var visit in visitData) {
      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(
              coordinates: Position(visit['geoLocation']['longitude'],
                  visit['geoLocation']['latitude'])),
          image: imageData,
          iconSize: 0.15);

      pointAnnotationManager?.create(pointAnnotationOptions);
    }
  }

  showStoreMarker() async {
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    final ByteData goldBytes =
        await rootBundle.load('assets/images/bronze-gray.png');
    final ByteData silverBytes =
        await rootBundle.load('assets/images/gold-gray.png');
    final ByteData bronzeBytes =
        await rootBundle.load('assets/images/silver-gray.png');

    final ByteData goldGreenBytes =
        await rootBundle.load('assets/images/bronze-green.png');
    final ByteData silverGreenBytes =
        await rootBundle.load('assets/images/gold-green.png');
    final ByteData bronzeGreenBytes =
        await rootBundle.load('assets/images/silver-green.png');

    final ByteData goldyellowBytes =
        await rootBundle.load('assets/images/bronze-yellow.png');
    final ByteData silveryellowBytes =
        await rootBundle.load('assets/images/gold-yellow.png');
    final ByteData bronzeyellowBytes =
        await rootBundle.load('assets/images/silver-yellow.png');

    final ByteData goldredBytes =
        await rootBundle.load('assets/images/bronze-red.png');
    final ByteData silverredBytes =
        await rootBundle.load('assets/images/gold-red.png');
    final ByteData bronzeredBytes =
        await rootBundle.load('assets/images/silver-red.png');

    final Uint8List goldIcon = goldBytes.buffer.asUint8List();
    final Uint8List silverIcon = silverBytes.buffer.asUint8List();
    final Uint8List bronzeIcon = bronzeBytes.buffer.asUint8List();

    final Uint8List goldGreenIcon = goldGreenBytes.buffer.asUint8List();
    final Uint8List silverGreenIcon = silverGreenBytes.buffer.asUint8List();
    final Uint8List bronzeGreenIcon = bronzeGreenBytes.buffer.asUint8List();

    final Uint8List goldyellowIcon = goldyellowBytes.buffer.asUint8List();
    final Uint8List silveryellowIcon = silveryellowBytes.buffer.asUint8List();
    final Uint8List bronzeyellowIcon = bronzeyellowBytes.buffer.asUint8List();

    final Uint8List goldredIcon = goldredBytes.buffer.asUint8List();
    final Uint8List silverredIcon = silverredBytes.buffer.asUint8List();
    final Uint8List bronzeredIcon = bronzeredBytes.buffer.asUint8List();

    for (var store in storesData) {
      Uint8List storeIcon;

      double caseVolumeLTM = store['caseVolumeLTM'] == null
          ? 0.0
          : double.parse(store['caseVolumeLTM'].toString());

      double cirocCases = store['cirocCases'] != null
          ? double.parse(store['cirocCases'].toString())
          : 0.0;

      if (cirocCases == 0 || caseVolumeLTM == 0) {
        if (store['percentile'] != null) {
          if (store['percentile'] < 10) {
            storeIcon = goldIcon;
          } else if (store['percentile'] >= 10 && store['percentile'] <= 50) {
            storeIcon = silverIcon;
          } else {
            storeIcon = bronzeIcon;
          }
        } else {
          storeIcon = bronzeIcon;
        }
      } else {
        double ratio = (caseVolumeLTM / cirocCases) * 100;

        if (ratio > 30) {
          if (store['percentile'] != null) {
            if (store['percentile'] < 10) {
              storeIcon = goldGreenIcon;
            } else if (store['percentile'] >= 10 && store['percentile'] <= 50) {
              storeIcon = silverGreenIcon;
            } else {
              storeIcon = bronzeGreenIcon;
            }
          } else {
            storeIcon = bronzeGreenIcon;
          }
        } else if (ratio >= 15 && ratio <= 30) {
          if (store['percentile'] != null) {
            if (store['percentile'] < 10) {
              storeIcon = goldyellowIcon;
            } else if (store['percentile'] >= 10 && store['percentile'] <= 50) {
              storeIcon = silveryellowIcon;
            } else {
              storeIcon = bronzeyellowIcon;
            }
          } else {
            storeIcon = bronzeyellowIcon;
          }
        } else if (ratio >= 0 && ratio <= 15) {
          if (store['percentile'] != null) {
            if (store['percentile'] < 10) {
              storeIcon = goldredIcon;
            } else if (store['percentile'] >= 10 && store['percentile'] <= 50) {
              storeIcon = silverredIcon;
            } else {
              storeIcon = bronzeredIcon;
            }
          } else {
            storeIcon = bronzeredIcon;
          }
        } else {
          if (store['percentile'] != null) {
            if (store['percentile'] < 10) {
              storeIcon = goldIcon;
            } else if (store['percentile'] >= 10 && store['percentile'] <= 50) {
              storeIcon = silverIcon;
            } else {
              storeIcon = bronzeIcon;
            }
          } else {
            storeIcon = bronzeIcon;
          }
        }
      }

      PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(
            coordinates: Position(store['geoLocation']['longitude'],
                store['geoLocation']['latitude'])),
        image: storeIcon,
        iconSize: 0.15,
      );
      pointAnnotationManager?.create(pointAnnotationOptions);
    }
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    showcustomermarker();
    showvisitMarker();
    showStoreMarker();
  }

  Future<void> _loadJsonDatavisit() async {
    String jsonString = await rootBundle.loadString('assets/json/visits.json');
    final data = json.decode(jsonString);
    setState(() {
      visitData = data['visits'];
    });
  }

  Future<void> _loadJsonDataCustomer() async {
    String jsonString =
        await rootBundle.loadString('assets/json/customers.json');
    final data = json.decode(jsonString);
    setState(() {
      customerData = data['customers'];
    });

    if (kDebugMode) {
      print("customer data$customerData");
    }
  }

  Future<void> _loadJsonDataStore() async {
    String jsonString = await rootBundle.loadString('assets/json/stores.json');
    final data = json.decode(jsonString);
    setState(() {
      storesData = data['stores'];
    });

    if (kDebugMode) {
      print("stores data $storesData");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentLocationAndZoom();
    });
    requestmethod();
  }

  requestmethod() async {
    await _getCurrentLocationAndZoom();
    _loadJsonDataCustomer();
    _loadJsonDatavisit();
    _loadJsonDataStore();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = accesskey;
    MapboxOptions.setAccessToken(accessToken);

    return Scaffold(
      appBar: AppBar(title: const Text("Mapbox Map")),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    MapWidget(
                        cameraOptions: CameraOptions(
                            center: Point(
                                coordinates: Position(
                                    position!.longitude, position!.latitude)),
                            zoom: 12.0,
                            bearing: 0,
                            pitch: 0),
                        onMapCreated: _onMapCreated),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          await _getCurrentLocationAndZoom();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.location_searching_outlined,
                              color: Colors.white, size: 25),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (istoggle) {
                            setState(() {
                              istoggle = false;
                            });
                          } else {
                            setState(() {
                              istoggle = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Row(
                            children: [
                              Icon(Icons.layers),
                              Text(
                                "Map Layers",
                              )
                            ],
                          ),
                        ),
                      ),
                      if (istoggle)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: Colors.white),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: mapLayer.length,
                            itemBuilder: (context, index) {
                              String layerName =
                                  mapLayer[index]; 
                              bool isSelected =
                                  selectedLayers.contains(layerName);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedLayers.remove(layerName);
                                    } else {
                                      selectedLayers.add(layerName);
                                    }
                                  });
                                  _updateMarkers();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedLayers.add(layerName);
                                            } else {
                                              selectedLayers.remove(layerName);
                                            }
                                          });
                                          _updateMarkers();
                                        },
                                      ),
                                    ),
                                    Text(layerName),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  void _updateMarkers() async {
    pointAnnotationManager?.deleteAll();

    if (selectedLayers.contains("Stores")) {
     
      await showStoreMarker();
    }
    if (selectedLayers.contains("Visits")) {
     
      await showvisitMarker();
    }
    if (selectedLayers.contains("Customers")) {
      
      await showcustomermarker();
    }
  }
}
