import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:painter2/painter2.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart' as Path;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class DrawMe extends StatefulWidget {
  @override
  _DrawMeState createState() => _DrawMeState();
}

class _DrawMeState extends State<DrawMe> {
  bool _finished;
  PainterController _controller;
  final count = 0;

//  Future<void> _uploadFile() async {
//    StorageReference storageReference;
//    String filename = "image$count.png";
//    storageReference = FirebaseStorage.instance.ref().child("images/$filename");
//
//    final StorageUploadTask uploadTask = storageReference.putFile(file);
//    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
//    final String url = (await downloadUrl.ref.getDownloadURL());
//    print("URL is $url");
//  }

  @override
  void initState() {
    super.initState();
    _finished = false;
    _controller = newController();
  }

  PainterController newController() {
    PainterController controller = PainterController();
    controller.thickness = 10.0;
    controller.backgroundColor = Colors.lightBlueAccent.withOpacity(0.1);
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        IconButton(
          icon: Icon(Icons.content_copy),
          tooltip: 'New Painting',
          onPressed: () => setState(() {
            _finished = false;
            _controller = newController();
          }),
        ),
      ];
    } else {
      actions = <Widget>[
        IconButton(
          icon: Icon(Icons.undo),
          tooltip: 'Undo',
          onPressed: () {
            if (_controller.canUndo) _controller.undo();
          },
        ),
        IconButton(
          icon: Icon(Icons.redo),
          tooltip: 'Redo',
          onPressed: () {
            if (_controller.canRedo) _controller.redo();
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Clear',
          onPressed: () => _controller.clear(),
        ),
        IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              // GallerySaver.saveImage(myImagePath);
//              final directory = await Path.getExternalStorageDirectory();
//              final myImagePath = '${directory.path}/Pictures';
//              print(myImagePath);
//              final myDir = await Directory(myImagePath).create();
//              final path = myImagePath + '${DateTime.now()}.png';
              //final File newImage = await _image.copy('$path/image1.png');
              //GallerySaver.saveImage('image1.png');
              setState(() {
                _finished = true;
              });
              //String _uploadedFileURL;
              Uint8List bytes = await _controller.exportAsPNGBytes();
              //File('thumbnail.png').writeAsBytesSync(bytes);
              File('image$count.png').writeAsBytesSync(bytes);
//              StorageReference storageReference = FirebaseStorage.instance
//                  .ref()
//                  .child('images/${_image.path}}');
//              StorageUploadTask uploadTask = storageReference.putFile(_image);
//              await uploadTask.onComplete;
              //_uploadFile(Uri.file('image$count.png0'));
              print('File Uploaded');
//              storageReference.getDownloadURL().then((fileURL) {
//                setState(() {
//                  _uploadedFileURL = fileURL;
//                });
//              });
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white10,
                    title: Text('View your image'),
                  ),
                  body: Container(
                    child: Image.memory(bytes),
                  ),
                );
              }));
            }),
      ];
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: Text('Draw Me'),
        actions: actions,
        bottom: PreferredSize(
          child: DrawBar(_controller),
          preferredSize: Size(MediaQuery.of(context).size.width, 30.0),
        ),
      ),
      body: Center(
          child: AspectRatio(aspectRatio: 1.0, child: Painter(_controller))),
    );
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;
  DrawBar(this._controller);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              child: Slider(
            value: _controller.thickness,
            onChanged: (value) => setState(() {
              _controller.thickness = value;
            }),
            min: 1.0,
            max: 20.0,
            activeColor: Colors.white,
          ));
        })),
        ColorPickerButton(_controller),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;

  ColorPickerButton(this._controller);

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_iconData, color: _color),
      tooltip: 'Change draw color',
      onPressed: () => _pickColor(),
    );
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Pick color'),
                  ),
                  body: Container(
                      alignment: Alignment.center,
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (Color c) => pickerColor = c,
                      )));
            }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget._controller.drawColor;

  IconData get _iconData => Icons.brush;

  set _color(Color color) {
    widget._controller.drawColor = color;
  }
}
