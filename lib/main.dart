import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

late List municipalities;
ll.LatLng center = ll.LatLng(60.459772, 22.279673);
// late GoogleMapController mapController;
fm.MapController fmMapController = fm.MapController();

void main() => runApp(const HakuApp());

class HakuApp extends StatefulWidget {
  const HakuApp({Key? key}) : super(key: key);
  @override
  _HakuAppState createState() => _HakuAppState();
}

class _HakuAppState extends State<HakuApp> {

  //TODO: Not used currently
  final hakuController = TextEditingController();
  Icon hakuIcon = const Icon(Icons.search);
  Widget hakuSearchBar = const Text('Haku');
  // final ll.LatLng _center = ll.LatLng(60.459772, 22.279673);

  /* void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  } */

  void loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/municipalities.json');
    municipalities = json.decode(jsonText);
  }

  @override
  void initState() {
    super.initState();
    hakuController.addListener((){
      if(hakuController.text.length > 2) {
        print('Haku: ${hakuController.text}');
      }
    });
    loadJsonData();
  }

  @override
  void dispose() {
    hakuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff7dc200);

    final body = fm.FlutterMap(
      mapController: fmMapController,
      options: fm.MapOptions(
        center: center,
        zoom: 13.0,
      ),
      layers: [
        fm.TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
        ),
        /* fm.MarkerLayerOptions(
          markers: [
            fm.Marker(
              width: 80.0,
              height: 80.0,
              point: _center,
              builder: (ctx) =>
                  Container(
                    child: const FlutterLogo(),
                  ),
            ),
          ],
        ),*/
      ],
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: hakuSearchBar,
          backgroundColor: color,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (hakuIcon.icon == Icons.search) {
                      hakuIcon = const Icon(Icons.cancel);
                      hakuSearchBar = const HakuAutocomplete();
                    } else {
                      hakuIcon = const Icon(Icons.search);
                      hakuSearchBar = const Text('Haku');
                    }
                  });
                },
                icon: hakuIcon)
          ],
        ),
        body: body
        /*GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 17.0,
          ),
        ),*/
      ),
    );
  }
}

class HakuAutocomplete extends StatelessWidget {
  const HakuAutocomplete({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<String> _kOptions = <String>[];
    municipalities[0]["features"].forEach((element) {
      _kOptions.add(element["properties"]["name"]);
    });
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
          return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        municipalities[0]["features"].forEach((element) {
          if(element["properties"]["name"] == selection) {
            fmMapController.move(ll.LatLng(element["geometry"]["coordinates"][1], element["geometry"]["coordinates"][0]), 15);
            /*CameraPosition municipalityCenter = CameraPosition(
              target: LatLng(element["geometry"]["coordinates"][1], element["geometry"]["coordinates"][0]),
              zoom: 15.0,
            );
            mapController.animateCamera(CameraUpdate.newCameraPosition(municipalityCenter));*/
          }
        });
      },
    );
  }
}