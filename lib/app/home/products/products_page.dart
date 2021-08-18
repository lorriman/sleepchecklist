import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:exif/exif.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../app_exceptions.dart';
import '../settings.dart';

//Product jpegs in the assets folder have the affiliate url embedded in the
//exif as 'Image Artist' or on Windows it's the 'Author'.
//The just 4 images are currently indexed as product1.jpg product2. etc
//as a quick demo. Expected to use Firebase storage and an A/B testing
//scheme in future.
class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final Map<String, String> productUrls = {};
  bool _showUrls = false;
  Future<Map<String, String>>? _urlsFuture;
  Future<void>? _launched;
  BoxConstraints? _constraints;

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        //headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw AppException('Could not launch $url');
    }
  }

  Future<Map<String, String>> _getUrls() async {
    for (int i = 1; i < 5; i++) {
      final String fileName = 'assets/products/product$i.jpg';
      final ByteData fileBytes = await rootBundle.load(fileName);
      final List<int> fileListInt = fileBytes.buffer
          .asUint8List(fileBytes.offsetInBytes, fileBytes.lengthInBytes);
      final Map<String, IfdTag> data = await readExifFromBytes(fileListInt);
      productUrls[i.toString()] = data['Image Artist']?.printable ??
          'url in "Image Artist" exif (windows: Authors) not found: please notify lorrimangpublic@gmail.com';
    }

    return productUrls;
  }

  @override
  void initState() {
    super.initState();
    _urlsFuture = _getUrls();
  }

  Widget itemBuilder(BuildContext context, int index) {
    final String? url = productUrls[(index + 1).toString()];
    final String assetPath = 'assets/products/product${index + 1}.jpg';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onDoubleTap: () => setState(() {
          if (!kReleaseMode) _showUrls = !_showUrls;
        }),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            elevation: 5,
          ),
          onPressed: () => setState(() {
            if (url != null) {
              _launched = _launchInBrowser(url);
            }
          }),
          //clipBehavior: Clip.antiAlias,
          /*
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 20,
          margin: EdgeInsets.all(0), */
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_showUrls) Text(url ?? 'no url string'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    cacheHeight:
                        -120 + (_constraints?.maxHeight.toInt() ?? 500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget separatorBuilder(BuildContext _, int index) {
    return const Divider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: Settings()),
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        _constraints = constraints;
        return FutureBuilder(
          future: _urlsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              if (constraints.maxWidth > 900) {
                return Column(
                  children: [
                    Expanded(
                      child: StaggeredGridView.countBuilder(
                        crossAxisCount: 4,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                              child: Center(
                            child: itemBuilder(context, index),
                          ));
                        },
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                      flex: 1,
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: itemBuilder,
                        separatorBuilder: separatorBuilder,
                        itemCount: 4,
                      ),
                      flex: 1,
                    ),
                  ],
                );
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      }),
    );
  }
}
