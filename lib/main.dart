import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: MainNavigationScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey _globalKey = GlobalKey();

  // စာသားနှင့် ပုံစံ ကိန်းရှင်များ
  String _userText = "မင်္ဂလာပါ ချစ်ရပါသော မြန်မာပြည်";
  double _fontSize = 24.0;
  Color _textColor = Colors.white;
  String _selectedFont = 'Padauk';
  Offset _textPosition = const Offset(50, 150);

  // ရွေးချယ်ထားသော ပုံ
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // ပုံရွေးချယ်သည့် Function (ကင်မရာ သို့မဟုတ် Gallery)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _currentIndex = 0; // ပုံရွေးပြီးပါက မူလပင်မမျက်နှာပြင်သို့ ပြန်သွားမည်
      });
    }
  }

  // ပုံဖန်တီးထုတ်ယူသည့် Function
  Future<void> _saveFinalImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ပုံကို အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ။')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('အမှားဖြစ်ပေါ်ပါသည်: $e')),
      );
    }
  }

  // ရွေးချယ်ထားသော ဖောင့်စတိုင် ရယူခြင်း
  TextStyle _getTextStyle() {
    TextStyle baseStyle = TextStyle(
      fontSize: _fontSize,
      color: _textColor,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(offset: Offset(1.5, 1.5), blurRadius: 4.0, color: Colors.black),
      ],
    );

    switch (_selectedFont) {
      case 'Myanmar Sans Pro':
        return GoogleFonts.myanmarSansPro(textStyle: baseStyle);
      case 'Noto Sans Myanmar':
        return GoogleFonts.notoSansMyanmar(textStyle: baseStyle);
      case 'Padauk':
      default:
        return GoogleFonts.padauk(textStyle: baseStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('မြန်မာစာ ဓာတ်ပုံစတိုင်လာ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'ပုံထုတ်ယူမည်',
            onPressed: _saveFinalImage,
          ),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ပင်မ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'စာရိုက်',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'ပုံရွေး',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            label: 'စာအလှဆင်',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 1:
        return _buildTextEntryTab();
      case 2:
        return _buildImagePickerTab();
      case 3:
        return _buildStylingTab();
      case 0:
      default:
        return _buildHomePreviewTab();
    }
  }

  // ၁။ ပင်မ စာမျက်နှာ (နမူနာပုံစံနှင့် စာသားရွှေ့နိုင်သော Preview)
  Widget _buildHomePreviewTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              '💡 စာသားကို လက်ဖြင့် ဖိဆွဲပြီး နေရာလွတ်သို့ ရွှေ့နိုင်ပါသည်',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // ရွေးချယ်ထားသော ပုံ သို့မဟုတ် နမူနာပုံ
                      Positioned.fill(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : Image.network(
                                'https://picsum.photos/600/800',
                                fit: BoxFit.cover,
                              ),
                      ),
                      // အလင်းအမှောင် သမမျှတစေရန် Overlay
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      // လွတ်လပ်စွာ ရွှေ့နိုင်သော စာသား
                      Positioned(
                        left: _textPosition.dx,
                        top: _textPosition.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _textPosition += details.delta;
                            });
                          },
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              _userText,
                              style: _getTextStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ၂။ ဓာတ်ပုံပေါ်စာရိုက်ရန် Tab
  Widget _buildTextEntryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ရေးသားလိုသော စာသားကို ရိုက်ထည့်ပါ:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'ဤနေရာတွင် မြန်မာစာ ရိုက်ပါ...',
            ),
            onChanged: (val) {
              setState(() {
                _userText = val.isEmpty ? "စာသားရိုက်ထည့်ပါ" : val;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0; // စာရိုက်ပြီးပါက ပင်မသို့ ပြန်ပြမည်
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('ပင်မပုံတွင် ကြည့်ရှုမည်', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ၃။ ဓာတ်ပုံရွေးရန် Tab (ကင်မရာ / ဖုန်း Gallery)
  Widget _buildImagePickerTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.teal, size: 36),
              title: const Text('ကင်မရာဖြင့် ချက်ချင်းရိုက်မည်'),
              tileColor: Colors.teal.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.teal, size: 36),
              title: const Text('ဖုန်း Gallery ထဲမှ ရွေးချယ်မည်'),
              tileColor: Colors.teal.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ၄။ စာအလှဆင် Tab (အရွယ်အစား၊ အရောင်၊ Font)
  Widget _buildStylingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // စာလုံးအရွယ်အစား (Font Size Slider)
          const Text('စာလုံးအရွယ်အစား (Font Size):', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _fontSize,
            min: 14.0,
            max: 50.0,
            activeColor: Colors.teal,
            onChanged: (newSize) {
              setState(() {
                _fontSize = newSize;
              });
            },
          ),
          const SizedBox(height: 16),

          // ဖောင့်ရွေးချယ်မှု (Myanmar Unicode Fonts)
          const Text('မြန်မာ Font ရွေးချယ်ရန်:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedFont,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Padauk', child: Text('Padauk ဖောင့်')),
              DropdownMenuItem(value: 'Myanmar Sans Pro', child: Text('Myanmar Sans Pro ဖောင့်')),
              DropdownMenuItem(value: 'Noto Sans Myanmar', child: Text('Noto Sans Myanmar ဖောင့်')),
            ],
            onChanged: (font) {
              if (font != null) {
                setState(() {
                  _selectedFont = font;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // အရောင်ရွေးချယ်မှု (Color Palette)
          const Text('စာလုံးအရောင် ရွေးချယ်ရန်:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildColorCircle(Colors.white),
              _buildColorCircle(Colors.black),
              _buildColorCircle(Colors.yellow),
              _buildColorCircle(Colors.amber),
              _buildColorCircle(Colors.redAccent),
              _buildColorCircle(Colors.greenAccent),
              _buildColorCircle(Colors.cyanAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _textColor == color ? Colors.teal : Colors.grey.shade400,
            width: _textColor == color ? 3.0 : 1.0,
          ),
        ),
      ),
    );
  }
}
