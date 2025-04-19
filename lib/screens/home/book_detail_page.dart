import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:translator/translator.dart';

class BookDetailsPage extends StatefulWidget {
  final String pdfPath;
  final String title;
  final String langugage;

  const BookDetailsPage({
    super.key,
    required this.pdfPath,
    required this.title,
    required this.langugage,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final Map<int, GlobalKey> _itemKeys = {};
  bool isHeaderFooterShowing = true;

  bool isSpeaking = false;
  bool isLoading = true;
  bool isTranslating = false; // Flag for translation progress
  List<String> lines = [];
  List<List<String>> pages = [];
  int currentLineIndex = -1;
  int selectedLineIndex = -1;
  double speechRate = 1.0;

  bool manualNavigation = false;
  bool allowAutoComplete = true;
  bool isReadAllowedMode = false;
  // Layout and feature options
  bool isTwoPageMode = false;
  bool isNightMode = false;
  bool showAsPdf = true;
  double zoomLevel = 1.0;
  Set<int> bookmarkedPages = {};
  int currentPage = 0;
  final FlutterTts flutterTts = FlutterTts();
  String? selectedText;

  @override
  void initState() {
    super.initState();
    // disableHeaderFooter();
    _loadPreferences();
    extractTextFromAssetsPdf(widget.pdfPath);
    // Register the completion handler (using an async closure)
    flutterTts.setCompletionHandler(() async {
      debugPrint("TTS complete callback triggered.");
      await _handleLineComplete();
    });
  }

  void disableHeaderFooter() {
    setState(() {
      isHeaderFooterShowing = !isHeaderFooterShowing;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNightMode = prefs.getBool('nightMode') ?? false;
      isTwoPageMode = prefs.getBool('twoPageMode') ?? false;
      showAsPdf = prefs.getBool('showAsPdf') ?? true;

      // Load bookmarks for this specific book
      final bookmarkKey = 'bookmarks_${widget.title}';
      bookmarkedPages =
          (prefs.getStringList(bookmarkKey) ?? [])
              .map((e) => int.parse(e))
              .toSet();
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nightMode', isNightMode);
    await prefs.setBool('twoPageMode', isTwoPageMode);
    await prefs.setBool('showAsPdf', showAsPdf);

    // Save bookmarks for this specific book
    final bookmarkKey = 'bookmarks_${widget.title}';
    await prefs.setStringList(
      bookmarkKey,
      bookmarkedPages.map((e) => e.toString()).toList(),
    );
  }

  List<Map<String, dynamic>> highlights = [];

  void saveHighlight(String text, int position) {
    highlights.add({'text': text, 'position': position});
  }

  @override
  void dispose() {
    flutterTts.stop();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

 Future<void> extractTextFromAssetsPdf(String assetPath) async {
  try {
    // Load PDF file from assets
    ByteData data = await rootBundle.load(assetPath);
    Uint8List bytes = data.buffer.asUint8List();

    // Load the PDF document
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);

    // Extract text from each page
    List<List<String>> extractedPages = [];
    for (int i = 0; i < document.pages.count; i++) {
      String pageText = extractor.extractText(startPageIndex: i);
      List<String> pageLines = pageText
          .split(RegExp(r'\n+'))
          .where((line) => line.trim().isNotEmpty)
          .toList();
      extractedPages.add(pageLines);
    }

    document.dispose();

    // Update state or handle extracted text
    setState(() {
      lines = extractedPages.expand((element) => element).toList();
      pages = extractedPages;
      isLoading = false;
    });
  } catch (e) {
    debugPrint("Error loading PDF: $e");
  }
}

  Future<void> _speakText() async {
    if (isSpeaking) {
      await flutterTts.stop();
      timer?.cancel();
      setState(() {
        isSpeaking = false;
        currentLineIndex = -1;
      });
    } else {
      _startTiming();
      setState(() {
        isSpeaking = true;
        if (currentLineIndex < 0 || currentLineIndex >= lines.length) {
          currentLineIndex = selectedLineIndex >= 0 ? selectedLineIndex : 0;
        }
      });
      await _speakCurrentLine();
    }
  }

  Future<void> _speakCurrentLine() async {
    if (currentLineIndex < 0 || currentLineIndex >= lines.length) {
      setState(() {
        isSpeaking = false;
        currentLineIndex = 0;
      });
      return;
    }

    // ... inside _speakCurrentLine(), replacing your old if-block:
    final originalLine = lines[currentLineIndex];
    String lineToSpeak = originalLine;

    if ([
      'bengali',
      'hindi',
      'punjabi',
    ].contains(widget.langugage.toLowerCase())) {
      setState(() {
        isTranslating = true;
      });

      try {
        final translator = GoogleTranslator();
        // Determine target code (ISO‑639‑1)
        String toLangCode;
        switch (widget.langugage.toLowerCase()) {
          case 'bengali':
            toLangCode = 'bn';
            break;
          case 'hindi':
            toLangCode = 'hi';
            break;
          case 'punjabi':
            toLangCode = 'pa';
            break;
          default:
            toLangCode = 'en';
        }

        // Omit `from:` so the package auto‑detects source
        var translation = await translator.translate(
          originalLine,
          to: toLangCode,
        );
        lineToSpeak = translation.text;
      } catch (e) {
        debugPrint('Translation error: $e');
      } finally {
        setState(() {
          isTranslating = false;
        });
      }
    }

    // ... then the rest of your TTS call, using lineToSpeak
    debugPrint("Speaking line: $lineToSpeak");

    // Scroll the current line into view
    final key = _itemKeys[currentLineIndex];
    if (key != null && key.currentContext != null) {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    Map<String, String> languageMap = {
      'bengali': 'bn-IN',
      'hindi': 'hi-IN',
      'punjabi': 'pa-IN',
      'english': 'en-US',
      'tamil': 'ta-IN',
      'telugu': 'te-IN',
      'kannada': 'kn-IN',
      'malayalam': 'ml-IN',
      'marathi': 'mr-IN',
      'gujarati': 'gu-IN',
      'urdu': 'ur-IN',
      'assamese': 'as-IN',
      'odia': 'or-IN',
      'kashmiri': 'ks-IN',
      'sindhi': 'sd-IN',
      'nepali': 'ne-IN',
      'sanskrit': 'sa-IN',
      'maithili': 'mai-IN',
      'dogri': 'doi-IN',
      'manipuri': 'mni-IN',
      'bodo': 'brx-IN',
      'santhali': 'sat-IN',
      'sikkimese': 'sit-IN',
      'bhili': 'bhi-IN',
      'bhutia': 'bht-IN',
      'garhwali': 'gwr-IN',
    };

    String langKey = widget.langugage.toLowerCase();
    if (!languageMap.containsKey(langKey)) {
      langKey = 'english'; // Fallback to English if not supported
    }

    // Get TTS language code or fallback to 'en-US'
    String ttsLanguage = languageMap[langKey] ?? 'en-US';
    debugPrint("Selected language: $langKey");
    debugPrint("TTS language: $ttsLanguage");

    // Set TTS engine
    // await flutterTts.setEngine('com.google.android.tts');
    await flutterTts.setSharedInstance(true);
    await flutterTts.setSpeechRate(speechRate / 2);
    await flutterTts.setVolume(1.0);

    // Set TTS configuration
    await flutterTts.setLanguage(ttsLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(speechRate / 2);

    // Speak the translated or selected line
    await flutterTts.speak(lineToSpeak);
    debugPrint("Speaking: $lineToSpeak");
    // Set the selected line index
    setState(() {
      selectedLineIndex = currentLineIndex;
      currentLineIndex = selectedLineIndex;
    });
    // Scroll to the selected line

    // Update UI
    setState(() {});
  }

  Future<void> _handleLineComplete() async {
    debugPrint("Handling line complete. Current index: $currentLineIndex");
    if (!isSpeaking || !allowAutoComplete) return;

    if (currentLineIndex + 1 < lines.length) {
      setState(() {
        currentLineIndex++;
      });
      await _speakCurrentLine();
    } else {
      setState(() {
        isSpeaking = false;
        currentLineIndex = -1;
      });
    }
  }

  Future<void> _selectLine(int index) async {
    disableHeaderFooter();
    if (isReadAllowedMode) {
      if (isSpeaking) await flutterTts.stop();

      setState(() {
        selectedLineIndex = index;
        currentLineIndex = selectedLineIndex;
        isSpeaking = true;
      });

      await _speakCurrentLine();
    }
  }

  Future<void> _speakPreviousLine() async {
    if (currentLineIndex > 0) {
      manualNavigation = true;
      allowAutoComplete = false;
      await flutterTts.stop();
      _startTiming();
      setState(() {
        currentLineIndex--;
        isSpeaking = true;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      await _speakCurrentLine();
      manualNavigation = false;
      Future.delayed(const Duration(seconds: 1), () {
        allowAutoComplete = true;
      });
    }
  }

  Future<void> _speakNextLine() async {
    if (currentLineIndex + 1 < lines.length) {
      manualNavigation = true;
      allowAutoComplete = false;
      await flutterTts.stop();
      _startTiming();
      setState(() {
        currentLineIndex++;
        isSpeaking = true;
      });
      await Future.delayed(const Duration(milliseconds: 100));
      await _speakCurrentLine();
      manualNavigation = false;
      Future.delayed(const Duration(seconds: 1), () {
        allowAutoComplete = true;
      });
    }
  }

  // PDF page navigation functions
  void _previousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    final maxPage = isTwoPageMode ? (pages.length / 2).ceil() : pages.length;
    if (_pageController.page! < maxPage - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleBookmark() {
    final pageIndex = _pageController.page!.toInt();
    setState(() {
      if (bookmarkedPages.contains(pageIndex)) {
        bookmarkedPages.remove(pageIndex);
      } else {
        bookmarkedPages.add(pageIndex);
      }
    });
    _savePreferences();
  }

  void _togglePageMode() {
    setState(() {
      isTwoPageMode = !isTwoPageMode;
      final currentPageIndex = _pageController.page!.toInt();
      final newPageIndex =
          isTwoPageMode ? (currentPageIndex / 2).floor() : currentPageIndex * 2;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(newPageIndex);
      });
    });
    _savePreferences();
  }

  void _toggleNightMode() {
    setState(() {
      isNightMode = !isNightMode;
    });
    _savePreferences();
  }

  void _toggleViewMode() {
    setState(() {
      showAsPdf = !showAsPdf;
    });
    _savePreferences();
  }

  void adjustZoom(double factor) {
    setState(() {
      zoomLevel = (zoomLevel * factor).clamp(0.5, 3.0);
    });
  }

  int timing = 0;
  Timer? timer;
  String increamentedTime = '00:00';
  void _startTiming() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isSpeaking) {
        timing++;
        final seconds = timing;
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        increamentedTime =
            '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(int index) {
    if (index < 0) return '00:00';
    final seconds = (index * 2).toInt();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showSpeedPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Speech Speed'),
              content: Slider(
                value: speechRate,
                min: 0.1,
                max: 2.5,
                divisions: 9,
                label: speechRate.toStringAsFixed(1),
                onChanged: (double value) {
                  flutterTts.setSpeechRate(speechRate / 2);
                  setState(() {
                    speechRate = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // New: Settings bottom sheet for TTS/Translation options.
  void _showSettingsSheet(BuildContext context) {
    String selectedLanguage = widget.langugage;
    double tempSpeechRate = speechRate;
    bool translationEnabled = widget.langugage.toLowerCase() == 'bengali';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Select TTS Language:"),
                      DropdownButton<String>(
                        value: selectedLanguage,
                        items:
                            <String>['Hindi', 'English', 'Bengali']
                                .map(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            selectedLanguage = newValue!;
                            translationEnabled =
                                newValue.toLowerCase() == 'bengali';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Speech rate slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Speech Rate:"),
                      Expanded(
                        child: Slider(
                          value: tempSpeechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          label: tempSpeechRate.toStringAsFixed(1),
                          onChanged: (value) {
                            setModalState(() {
                              tempSpeechRate = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Translation toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Enable Translation:"),
                      Switch(
                        value: translationEnabled,
                        onChanged: (val) {
                          setModalState(() {
                            translationEnabled = val;
                            selectedLanguage = val ? 'Bengali' : 'Hindi';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        speechRate = tempSpeechRate;
                        // Note: In this example, widget.langugage is immutable.
                        // For production, store the language setting in a mutable state.
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Settings"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // New: Enhanced TTS control panel widget.
  Widget _buildTTSControlPanel() {
    return Container(
      height: 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isNightMode ? Colors.black : Colors.blueGrey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    lines.isNotEmpty && currentLineIndex >= 0
                        ? currentLineIndex / lines.length
                        : 0,
                backgroundColor:
                    isNightMode ? Colors.grey[800] : Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  increamentedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: isNightMode ? Colors.grey[400] : Colors.black,
                  ),
                ),
                Text(
                  _formatDuration(lines.length),
                  style: TextStyle(
                    fontSize: 12,
                    color: isNightMode ? Colors.grey[400] : Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://avatar.iran.liara.run/public/boy?username=Ash',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: _speakPreviousLine,
                  color: isNightMode ? Colors.white : Colors.black,
                ),
                ElevatedButton(
                  onPressed: _speakText,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      isTranslating
                          ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : Icon(
                            isSpeaking ? Icons.stop : Icons.play_arrow,
                            size: 20,
                          ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: _speakNextLine,
                  color: isNightMode ? Colors.white : Colors.black,
                ),
                GestureDetector(
                  onTap: () {
                    _showSpeedPopup(context).then((val) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isNightMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${speechRate.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isNightMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : const Color(0xFFF6F9FC),
      appBar: PreferredSize(
        preferredSize:
            isHeaderFooterShowing == false
                ? Size.fromHeight(0)
                : const Size.fromHeight(50),
        child: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              color: isNightMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: isNightMode ? Colors.black : Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(
            color: isNightMode ? Colors.white : Colors.black,
          ),
          actions: [
            // Settings button for TTS/translation options.
            IconButton(
              icon: const Icon(Icons.headphones, size: 24),
              onPressed: () => _showSettingsSheet(context),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 24),
              onSelected: (value) async {
                switch (value) {
                  case 'layout':
                    _togglePageMode();
                    break;
                  case 'view_mode':
                    _toggleViewMode();
                    break;
                  case 'night_mode':
                    _toggleNightMode();
                    break;
                  case 'bookmark':
                    _toggleBookmark();
                    break;
                  case 'bookmarks':
                    _showBookmarksPopup(context);
                    break;
                  case 'read_allowed':
                    setState(() {
                      isReadAllowedMode = !isReadAllowedMode;
                    });
                    if (isSpeaking == true && !isReadAllowedMode) {
                      _speakText();
                    }

                    break;
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'layout',
                      child: ListTile(
                        leading: Icon(
                          isTwoPageMode ? Icons.book : Icons.chrome_reader_mode,
                          color: Colors.black,
                        ),
                        title: Text(
                          isTwoPageMode ? 'Single Page Mode' : 'Two Page Mode',
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'view_mode',
                      child: ListTile(
                        leading: Icon(
                          showAsPdf ? Icons.text_fields : Icons.picture_as_pdf,
                          color: Colors.black,
                        ),
                        title: Text(showAsPdf ? 'Show as Text' : 'Show as PDF'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'night_mode',
                      child: ListTile(
                        leading: Icon(
                          isNightMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.black,
                        ),
                        title: Text(isNightMode ? 'Day Mode' : 'Night Mode'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'bookmark',
                      child: ListTile(
                        leading: Icon(
                          bookmarkedPages.contains(
                                _pageController.hasClients
                                    ? _pageController.page?.toInt() ?? 0
                                    : 0,
                              )
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.black,
                        ),
                        title: const Text('Bookmark Page'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'bookmarks',
                      child: ListTile(
                        leading: const Icon(
                          Icons.bookmarks,
                          color: Colors.black,
                        ),
                        title: const Text('View Bookmarks'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'read_allowed',
                      child: ListTile(
                        leading:
                            isReadAllowedMode
                                ? const Icon(
                                  Icons.headphones,
                                  color: Colors.green,
                                  size: 25,
                                )
                                : const Icon(
                                  Icons.headphones,
                                  color: Colors.black,
                                  size: 25,
                                ),

                        title: const Text('Read Aloud'),
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        if (isSpeaking) {
                          disableHeaderFooter();
                        }
                      },
                      child: showAsPdf ? _buildPdfView() : _buildTextView(),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child:
                        showAsPdf ||
                                isHeaderFooterShowing == false ||
                                isReadAllowedMode == false
                            ? Container()
                            : _buildTTSControlPanel(),
                  ),
                ],
              ),

      floatingActionButton:
          showAsPdf
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'prevBtn',
                    mini: true,
                    onPressed: _previousPage,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'nextBtn',
                    mini: true,
                    onPressed: _nextPage,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              )
              : null,
    );
  }

  Widget _buildTextView() {
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      minScale: 0.5,
      maxScale: 3.0,
      child: Transform.scale(
        scale: zoomLevel,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: lines.length,
          itemBuilder: (context, index) {
            _itemKeys.putIfAbsent(index, () => GlobalKey());
            final isCurrent = index == currentLineIndex;
            return GestureDetector(
              onTap: () => _selectLine(index),
              child: Container(
                key: _itemKeys[index],
                color:
                    isCurrent
                        ? Colors.blue[200]
                        : (isNightMode ? Colors.black : Colors.white),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  lines[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color:
                        isCurrent
                            ? Colors.black
                            : (isNightMode ? Colors.white : Colors.grey[800]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          currentPage = index;
        });
      },
      itemCount: isTwoPageMode ? (pages.length / 2).ceil() : pages.length,
      itemBuilder: (context, pageIndex) {
        if (isTwoPageMode) {
          return Row(
            children: [
              Expanded(child: _buildSinglePage(pageIndex * 2)),
              Expanded(
                child:
                    pageIndex * 2 + 1 < pages.length
                        ? _buildSinglePage(pageIndex * 2 + 1)
                        : Container(),
              ),
            ],
          );
        } else {
          return _buildSinglePage(pageIndex);
        }
      },
    );
  }

  Widget _buildSinglePage(int pageIndex) {
    if (pageIndex >= pages.length) return Container();

    final pageLines = pages[pageIndex];
    final isBookmarked = bookmarkedPages.contains(pageIndex);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: isBookmarked ? Colors.orange : Colors.transparent,
          width: isBookmarked ? 2 : 0,
        ),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                _previousPage();
              } else if (details.primaryVelocity! < 0) {
                _nextPage();
              }
            },
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Transform.scale(
                scale: zoomLevel,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pageLines.length,
                  itemBuilder: (context, lineIndex) {
                    int globalLineIndex = 0;
                    for (int i = 0; i < pageIndex; i++) {
                      globalLineIndex += pages[i].length;
                    }
                    globalLineIndex += lineIndex;
                    _itemKeys.putIfAbsent(globalLineIndex, () => GlobalKey());
                    final isCurrent = globalLineIndex == currentLineIndex;
                    return GestureDetector(
                      onTap: () => _selectLine(globalLineIndex),
                      child: Container(
                        key: _itemKeys[globalLineIndex],
                        color:
                            isCurrent ? Colors.blue[200] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          pageLines[lineIndex],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color:
                                isNightMode
                                    ? (isCurrent ? Colors.black : Colors.white)
                                    : (isCurrent
                                        ? Colors.black
                                        : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNightMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Page ${pageIndex + 1}/${pages.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: isNightMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isBookmarked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.bookmark,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBookmarksPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bookmarks'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                bookmarkedPages.isEmpty
                    ? const Center(child: Text('No bookmarks yet'))
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: bookmarkedPages.length,
                      itemBuilder: (context, index) {
                        final pageNum = bookmarkedPages.elementAt(index);
                        return ListTile(
                          title: Text('Page ${pageNum + 1}'),
                          onTap: () {
                            Navigator.pop(context);
                            _pageController.jumpToPage(pageNum);
                          },
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
