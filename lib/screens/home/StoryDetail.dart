import 'package:e_book_reader/screens/home/book_detail_page.dart';
import 'package:flutter/material.dart';

class StoryDetail extends StatefulWidget {
  final String title;
  final String pdfPath;
  final String langugage;
  final String description;
  final String image;       // Book cover URL
  final String author;      // Author name
  final String authorImage; // Author avatar URL

  const StoryDetail({
    super.key,
    required this.title,
    required this.pdfPath,
    required this.langugage,
    required this.description,
    required this.image,
    required this.author,
    required this.authorImage,
  });

  @override
  _StoryDetailState createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  bool _isInLibrary = false;

  void _toggleLibrary() {
    setState(() {
      _isInLibrary = !_isInLibrary;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isInLibrary
              ? '${widget.title} added to Library'
              : '${widget.title} removed from Library',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFBA8E5D),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back Arrow
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Book Cover (half-screen height, full width)
            Container(
              width: double.infinity,
              height: screenHeight * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 10),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleLibrary,
                  icon: Icon(
                    _isInLibrary ? Icons.check_circle : Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isInLibrary ? 'Added' : 'Library',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isInLibrary ? Colors.green : Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsPage(
                          pdfPath: widget.pdfPath,
                          title: widget.title,
                          langugage: widget.langugage,
                        ),

      
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Read Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Details & Description Panel
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel Title
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Stats Row
                      Row(
                        children: const [
                          Text('375k Reads', style: TextStyle(color: Colors.grey)),
                          SizedBox(width: 12),
                          Icon(Icons.star, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('4.3 (324 Reviews)', style: TextStyle(color: Colors.green)),
                          SizedBox(width: 12),
                          Icon(Icons.trending_up, size: 16, color: Colors.cyan),
                          SizedBox(width: 4),
                          Text('0 Ch/Week', style: TextStyle(color: Colors.cyan)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        widget.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),

                      // Author & Follow with network image
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(widget.authorImage),
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.author,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: null,
                            child: const Text('Follow'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.white),
                              foregroundColor: MaterialStatePropertyAll(Colors.black87),
                            ),
                          ),
                        ],
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
}
