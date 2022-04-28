import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

import '../util/http.dart';

class CroppingPage extends StatefulWidget {
  final image;
  final name;
  final square;

  const CroppingPage({Key? key, this.image, this.name, this.square = true})
      : super(key: key);

  @override
  _CroppingPageState createState() => _CroppingPageState();
}

class _CroppingPageState extends State<CroppingPage> {
  var token = '';
  final cropKey = GlobalKey<CropState>();

  init() async {
    var res = await Http().post('/normal/getQiniuToken', {'key': widget.name});
    setState(() {
      token = res['info'];
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          //去除阴影
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                NavRouter.pop();
              },
              icon: Icon(Icons.arrow_back)),
          actions: [
            TextButton(
              onPressed: () async {
                var crop = cropKey.currentState;
                var area = crop?.area;
                if (area == null) {
                  print('裁剪不成功');
                } else {
                  await ImageCrop.requestPermissions().then((value) {
                    if (value) {
                      ImageCrop.cropImage(
                        file: widget.image,
                        area: area,
                      ).then((value) {
                        Storage storage = Storage();

                        storage
                            .putFile(value, token,
                                options: PutOptions(key: widget.name))
                            .then((value) async {
                          Navigator.pop(context, value.key);
                        }).catchError((err) {
                          Toaster().show('上传失败');
                        });
                      });
                    }
                  });
                }
              },
              child: Text(
                '确定',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: widget.image == null
              ? Text('No image selected.')
              : Crop.file(
                  widget.image,
                  key: cropKey,
                  scale: 1,
                  aspectRatio: widget.square ? 1 : null,
                ),
        ));
  }
}
