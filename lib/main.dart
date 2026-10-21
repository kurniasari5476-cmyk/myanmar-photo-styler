import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    home: PhotoTextEditor(),
    debugShowCheckedModeBanner: false,
  ));
}

class PhotoTextEditor extends StatefulWidget {
  const PhotoTextEditor({super.key});

  @override
  State<PhotoTextEditor> createState() => _PhotoTextEditorState();
}

class _PhotoTextEditorState extends State<PhotoTextEditor> {
  final GlobalKey _globalKey = GlobalKey();
  String _userText = "မင်္ဂလာပါ ချစ်ရပါသော မြန်မာပြည်";
  final double _fontSize = 22.0;

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ပုံကို အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ။')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('မြန်မာစာ ဓာတ်ပုံစတိုင်လာ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'ဓာတ်ပုံပေါ်တင်မည့် စာသားရိုက်ပါ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                onChanged: (val) {
                  setState(() {
                    _userText = val.isEmpty ? "စာသားရိုက်ထည့်ပါ" : val;
                  });
                },
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://picsum.photos/600/400',
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _userText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.padauk(
                          fontSize: _fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              offset: Offset(1.5, 1.5),
                              blurRadius: 4.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.download),
                label: const Text('ပုံထုတ်ယူမည်'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
