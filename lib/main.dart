
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_insta/flutter_insta.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _key = GlobalKey<ScaffoldState>();
  FlutterInsta flutterInsta=FlutterInsta();
  String username,imgageurl,reelurl;
  bool isimg=false,isloading=false,isloading2=false,isdark=true;

  final snackBar = SnackBar(
    backgroundColor: Colors.blueAccent,
    content: Text('Downloading'),
  );
  final snackBar2 = SnackBar(
    backgroundColor: Colors.blueAccent,
    content: Text('Successfully Downloaded!!'),
  );


  Future getImage(String username) async {

    try{

      if(username.contains('https://')){
        int count=22;
        while(count<username.length)
        {
          if(username[count]=='?' ){
            break;
          }
          count++;
        }
        username=username.substring(22,count);
      }

      flutterInsta = FlutterInsta();
      setState(() {
        isimg=false;
        isloading=true;
      });
      await flutterInsta.getProfileData(username);

      setState(() {
        imgageurl=flutterInsta.imgurl;
        isimg=true;
        isloading=false;
      });

    }catch(e){
      _key.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text('Enter correct username or URL'),
      ));
      setState(() {
        isloading=false;
      });
    }




  }



  Future imagedownload( String imgurl) async {
    try{
      setState(() {
        isloading2=true;
      });

      final status = await Permission.storage.request();

      final appDocDir = await getExternalStorageDirectory();
      String path = appDocDir.path+Platform.pathSeparator+'Download';
      final savedDir = Directory(path);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      _key.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Colors.blueAccent,
        content: Text('Downloading'),
      ));

      final taskId = await FlutterDownloader.enqueue(
        url: '$imgurl',
        savedDir:path,
        fileName: username+DateTime.now().toString()+'.jpg',
        showNotification: true,
        // show download progress in status bar (for Android)
        openFileFromNotification:true, // click on notification to open downloaded file (for Android)
      ).whenComplete(() {
        setState(() {
          isloading2 = false; // set to false to stop Progress indicator
        });
        _key.currentState.showSnackBar(snackBar2);
      });
    }catch(e){
      _key.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text('Enter correct URL'),
      ));
      setState(() {
        isloading2=false;
      });
    }
  }



  Future getReel( String reelurl) async {
    try{
      setState(() {
        isloading2=true;
      });
      String s=reelurl.substring(0,42);
      var myvideourl = await flutterInsta.downloadReels(s);
      print(myvideourl);
      final appDocDir = await getExternalStorageDirectory();
      String path = appDocDir.path+Platform.pathSeparator+'Download';
      final savedDir = Directory(path);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      _key.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 4),
        backgroundColor: Colors.blueAccent,
        content: Text('Downloading'),
      ));

      final taskId = await FlutterDownloader.enqueue(
        url: '$myvideourl',
        savedDir:path,
        fileName: 'reelvideo'+DateTime.now().toString()+'.mp4',
        showNotification: true,
        // show download progress in status bar (for Android)
        openFileFromNotification:true, // click on notification to open downloaded file (for Android)
      ).whenComplete(() {
        setState(() {
          isloading2 = false; // set to false to stop Progress indicator
        });
        _key.currentState.showSnackBar(snackBar2);
      });
    }catch(e){
      _key.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blueAccent,
        content: Text('Enter correct URL'),
      ));
      setState(() {
        isloading2=false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
     InitializeDownloader();
  }
  void InitializeDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
    );
  }


  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      theme: isdark?ThemeData.dark():ThemeData.light(),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            actions: [
              IconButton(icon: Icon(Icons.invert_colors),onPressed: (){
                setState(() {
                  isdark=!isdark;
                });
              },)
            ],
            bottom: TabBar(

              tabs: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.photo_library,),
                ),
                Icon(Icons.video_library)
              ],
            ),
            title: Text('Insta DP Reels Downloader'),
          ),
          body:TabBarView(
           
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text('Download Profile Photo',style: TextStyle(fontSize: 20),),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Username or Profile URL ',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.pink, width: 2.0)),
                        ),
                        onChanged: (val){
                          setState(() {
                            username=val;
                          });
                        },
                      ),
                    ),

                    RaisedButton.icon(onPressed:()async{
                      FocusScope.of(context).requestFocus(FocusNode());
                      getImage(username);


                    }, icon: Icon(Icons.search), label: Text('Search')),
                    SizedBox(height: 10,),
                    Divider(height: 10,thickness: 3,),
                    SizedBox(height: 10,),
                    isimg?Image.network(imgageurl,):Text(''),
                    SizedBox(height: 10,),
                    isimg?RaisedButton.icon(onPressed: ()async{

                      imagedownload(imgageurl);

                    },color: Colors.blueAccent, icon: Icon(Icons.file_download,size: 30,),label: Text('Download'),):Text(''),
                    isloading?SpinKitCircle(
                      color: Colors.blueAccent,
                      size: 50.0,
                    ):Container(),
                  ],
                ),
              ),

              Reel()
            ],
          ),
        ),
      ),
    );
  }





  Widget Reel(){
    return Column(
      children: [
        SizedBox(height: 10,),
        Text('Download Reels Video',style: TextStyle(fontSize: 20),),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Paste Reel URL here... ',
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink, width: 2.0)),
            ),
            onChanged: (val){
              setState(() {
                reelurl=val;
              });
            },
          ),
        ),

        RaisedButton.icon(onPressed:()async{
          FocusScope.of(context).requestFocus(FocusNode());
          getReel(reelurl);


        }, icon: Icon(Icons.file_download), label: Text('Download')),
        SizedBox(height: 10,),
        Divider(height: 10,thickness: 3,),
        SizedBox(height: 10,),
        SizedBox(height: 10,),
        isloading2?SpinKitCircle(
          color: Colors.blueAccent,
          size: 50.0,
        ):Container(),
      ],
    );
  }
}
