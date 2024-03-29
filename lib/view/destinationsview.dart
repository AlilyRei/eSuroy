import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class DestinationsView extends StatefulWidget {
  final Database db;
  const DestinationsView({required this.db, super.key});

  @override
  State<DestinationsView> createState() => _DestinationsViewState();
}

class _DestinationsViewState extends State<DestinationsView> {
  Future<List<String>> getActNames(String fileName) async {
    List<String> actNames = [];
    var queried = await widget.db.query('placeName',
        columns: ['id'], where: 'placeName LIKE ?', whereArgs: ['%$fileName%']);
    var actIds = await widget.db.query(
      'ids',
      columns: ['actId'],
      where: 'placeId = ?',
      whereArgs: [queried.first['id'].toString()],
    );
    for (var actID in actIds) {
      /*widget.db
          .query('activities',
              columns: ['actName'],
              where: 'id = ?',
              whereArgs: [actID['actId'].toString()])
          .then((actName) {
        actNames.add(actName.first['actName'].toString());
        debugPrint('Adding data to actnames');
      });*/
      var actName = await widget.db.query('activities',
          columns: ['actName'],
          where: 'id = ?',
          whereArgs: [actID['actId'].toString()]);
      actNames.add(actName.first['actName'].toString());
    }

    return actNames;
    /*widget.db
        .query('placeName',
            columns: ['id'],
            where: 'placeName LIKE ?',
            whereArgs: ['%$fileName%'])
        .then(
      (queried) {
        widget.db
            .query(
          'ids',
          columns: ['actId'],
          where: 'placeId = ?',
          whereArgs: [queried.first['id'].toString()],
        )
            .then(
          (actIds) {
            List<String> actNames = [];
            for (var actID in actIds) {
              widget.db
                  .query('activities',
                      columns: ['actName'],
                      where: 'id = ?',
                      whereArgs: [actID['actId'].toString()])
                  .then((actName) {
                actNames.add(actName.first['actName'].toString());
                debugPrint('Adding data to actnames');
              });
            }
          },
        );
      },
    );*/
  }

  Future<Widget> loadImageList() async {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    String ret = await rootBundle.loadString('assets/text/PlacesList.txt');
    List<Widget> list = [];

    ret.split(',').forEach((fileName) {
      list.add(
        Container(
          width: scrWidth * 0.50,
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            image: DecorationImage(
              image: AssetImage('assets/ImageList/$fileName.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.image_rounded,
              color: Color.fromARGB(0, 255, 255, 255),
            ),
            onPressed: () {
              getActNames(fileName).then(
                (actNames) {
                  List<Widget> wid = [];
                  wid.add(Text(
                    fileName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Calibre',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ));
                  wid.add(Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text(
                      'Activities: ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Calibre',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ));
                  for (var name in actNames) {
                    wid.add(Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        bottom: 10,
                        top: 10,
                      ),
                      child: Text(
                        '* $name',
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ));
                  }

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: const Text(
                            'Descriptions',
                            style: TextStyle(
                              fontFamily: 'Calibre',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: wid,
                        );
                      });
                },
              );
            },
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(204, 210, 237, 248),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 57, 156, 173),
            spreadRadius: 2,
            blurRadius: 2,
          )
        ],
      ),
      width: scrWidth * 0.9,
      height: scrHeight * 0.2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  Future<void> launchUrlText(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could Not Launch URL');
    }
  }

  Future<Widget> loadImages({required String listName}) async {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    String ret = await rootBundle.loadString('assets/text/${listName}List.txt');
    List<Widget> list = [];

    ret.split(',').forEach((fileName) {
      list.add(Container(
        width: scrWidth * 0.50,
        margin: const EdgeInsets.fromLTRB(10, 0, 0, 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
            image: AssetImage('assets/images/$listName/$fileName.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.image_rounded,
            color: Color.fromARGB(0, 255, 255, 255),
          ),
          onPressed: () {
            widget.db
                .query(listName == 'restaurants' ? 'restaurants' : 'hotel',
                    columns: ['url', 'contact'],
                    where: listName == 'restaurants'
                        ? 'name = ?'
                        : 'hotelName = ?',
                    whereArgs: [fileName])
                .then(
              (queried) {
                debugPrint('Pressed $fileName');
                final Uri _uri = Uri.parse(queried.first['url'].toString());
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Descriptions'),
                        children: [
                          Text(fileName),
                          Text(
                              'Contact Info: ${queried.first['contact'].toString()}'),
                          ElevatedButton(
                            onPressed: () async {
                              if (queried.first['url'].toString() !=
                                  'unavailable') {
                                await launchUrlText(_uri);
                              }
                            },
                            child: Text(queried.first['url'].toString()),
                          ),
                        ],
                      );
                    });
              },
            );
          },
        ),
      ));
    });

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(204, 210, 237, 248),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 57, 156, 173),
            spreadRadius: 2,
            blurRadius: 2,
          )
        ],
      ),
      width: scrWidth * 0.9,
      height: scrHeight * 0.2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSuroy'),
        foregroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
            margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 251, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 57, 156, 173),
                  spreadRadius: 3,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'DESTINATIONS',
                  style: TextStyle(
                    fontFamily: 'Calibre',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 50, top: 40),
                  child: Text(
                    'Famouse Places In Surigao',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder(
                    future: loadImageList(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.requireData;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })),
                const Padding(
                  padding: EdgeInsets.only(right: 50, top: 20),
                  child: Text(
                    'Hotels Recommendations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder(
                    future: loadImages(listName: 'hotels'),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.requireData;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })),
                const Padding(
                  padding: EdgeInsets.only(right: 20, top: 20),
                  child: Text(
                    'Restaurant Recommendations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder(
                    future: loadImages(listName: 'restaurants'),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.requireData;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })),
              ],
            ),
          )
        ],
      ),
    );
  }
}
