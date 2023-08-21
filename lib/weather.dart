import 'dart:convert';
import 'constraints.dart' as k;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';


class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {

  DateTime now = DateTime.now();
  String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
  String monthAndDate = DateFormat('MMMM d').format(DateTime.now());
  String formattedTime = DateFormat('HH:mm').format(DateTime.now());

  bool isLoaded=false;
  num? temp;
  num? pressure;
  num? humidity;
  num? cover;
  late int sunset;
  late int sunrise;
  var dt_sunrise;
  var dt_sunset;

  String cityname='';
  String description='';

  TextEditingController controller=TextEditingController();

  void initState(){
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/img_1.png"),
              fit: BoxFit.fill),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 14,top: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cityname.toUpperCase()}', style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.white
                ),),
                Text('${dayOfWeek}, ${monthAndDate}', style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                  color: Colors.white,
                ),),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud, size: 68, color: Colors.white,),
                      Text('${description.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: Colors.white),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_circle_outlined, size: 60,
                        color: Colors.white,),
                      Text("${DateFormat('hh:mm a').format(dt_sunset)}" ,style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.white),),
                      const SizedBox(width: 50,),
                      const Icon(Icons.cloud_circle_outlined, size: 60,
                        color: Colors.white,),
                      Text('${DateFormat('hh:mm a').format(dt_sunrise)}', style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.white),),
                    ],
                  ),
                ),
                Center(
                  child: Text('${temp?.toInt()}°C', style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(.6)),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  getCurrentLocation() async{
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    if(position != null){
      print('lat: ${position.latitude},long: ${position.longitude}');
      getCurrentCityWeather(position);
    }
    else{
      print('Data Unvailable');
    }
  }

  getCurrentCityWeather(Position pos)async{
    var client= http.Client();
    var url='${k.domain}lat=${pos.latitude}&lon=${pos.longitude}&appid=${k.apiKey}';
    print(url);
    var uri=Uri.parse(url);
    var response=await client.get(uri);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);
      setState(() {
        isLoaded=true;
      });
    }
    else{
      print('Error : ${response.statusCode}');
    }
  }
  updateUI(var decodedData){
    setState(() {

      if(decodedData==null){
        temp=0;
        pressure=0;
        humidity=0;
        cover=0;
        cityname='Not Available';
      }
      else{
        temp=decodedData['main']['temp']-273;
        pressure=decodedData['main']['pressure'];
        humidity=decodedData['main']['humidity'];
        cover=decodedData['clouds']['all'];
        cityname=decodedData['name'];
        sunrise=decodedData['sys']['sunrise'];
        sunset=decodedData['sys']['sunset'];
        description=decodedData['weather'][0]['description'];

        dt_sunrise = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
        dt_sunset = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);

      }
    });
  }

  getCityWeather(String cityname) async{
    var client=http.Client();
    var url='${k.domain}q=$cityname&appid=${k.apiKey}';
    var uri=Uri.parse(url);
    var response=await client.get(uri);
    if(response.statusCode == 200){
      var data=response.body;
      var decodedData=jsonDecode(data);
      print(data);
      updateUI(decodedData);
      setState(() {
        isLoaded=true;
      });
    }
    else{
      print(response.statusCode);
    }
  }

  @override
  void dispose(){
    // TODO: implement dispose();
    super.dispose();
  }
}


