import 'package:e_book_reader/screens/home/StoryDetail.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGridView = false;
  bool isLoading = false;
  final List<Map<String, String>> books = [
    {
      'title': 'Flutter for Beginners',
      'author': 'John Doe',
      'description':
          'Learn Flutter from scratch with this comprehensive guide for beginners. Covers everything from setup to advanced widgets.',
      'image': 'https://picsum.photos/seed/flutter1/100/150',
      'spdf': 'assets/pdf/the-great-gatsby.pdf',
      'langugage': 'English',
    },
    {
      'title': 'Mastering Dart',
      'author': 'Jane Smith',
      'description':
          'Dive deep into Dart programming language with practical examples and patterns. Perfect for those who want to strengthen their Flutter foundation.',
      'image': 'https://picsum.photos/seed/flutter2/100/150',
      'pdf': 'assets/pdf/Who_Is-Sellfish.pdf',
      'langugage': 'Punjabi',
    },
    {
      'title': 'UI Design Patterns',
      'author': 'Alice Brown',
      'description':
          'Understand beautiful app designs and implement them effectively in Flutter. Learn how to create consistent, appealing interfaces.',
      'image': 'https://picsum.photos/seed/flutter3/100/150',
      'pdf': 'assets/pdf/Comic_book_Hindi.pdf',
      'langugage': 'Hindi',
    },
    {
      'title': 'हिम्मत और सफलता',
      'author': 'स्वामी विवेकानंद',
      'description':
          'यह पुस्तक आपको साहस और आत्म-विश्वास से भर देती है, जो जीवन में किसी भी कठिनाई को पार करने में मदद करती है।',
      'image': 'https://picsum.photos/seed/hindi1/100/150',
      'pdf': 'assets/pdf/himmat_safalta.pdf',
      'langugage': 'Hindi',
    },
    {
      'title': 'The Power of Focus',
      'author': 'Jack Canfield',
      'description':
          'A motivational book to help you concentrate on your goals and avoid distractions. Improve productivity and achieve more.',
      'image': 'https://picsum.photos/seed/focusbook/100/150',
      'pdf': 'assets/pdf/power_of_focus.pdf',
      'langugage': 'English',
    },
    {
      'title': 'प्रेरणादायक कहानियाँ',
      'author': 'रामकृष्ण परमहंस',
      'description':
          'छोटी-छोटी कहानियाँ जो जीवन में सच्चाई, ईमानदारी और सेवा की भावना को प्रेरित करती हैं।',
      'image': 'https://picsum.photos/seed/hindi2/100/150',
      'pdf': 'assets/pdf/Bhootnath Part_text.pdf',
      'langugage': 'Hindi',
    },
    {
      'title': 'ਸਚ ਦੀ ਕਹਾਣੀ',
      'author': 'ਪ੍ਰੇਮ ਸਿੰਘ',
      'description':
          'ਇਹ ਕਿਤਾਬ ਇੱਕ ਪ੍ਰੇਰਕ ਕਹਾਣੀ ਹੈ ਜੋ ਸੱਚਾਈ ਅਤੇ ਹਿੰਮਤ ਬਾਰੇ ਗੱਲ ਕਰਦੀ ਹੈ।',
      'image': 'https://picsum.photos/seed/punjabi1/100/150',
      'pdf': 'assets/pdf/Who_Is-Sellfish.pdf',
      'langugage': 'Punjabi',
    },
    {
      'title': 'মন খুলে বাঁচো',
      'author': 'রবীন্দ্রনাথ ঠাকুর',
      'description':
          'একটি অনুপ্রেরণামূলক বই যা জীবনের সৌন্দর্য এবং আত্মবিশ্বাসের উপর ভিত্তি করে লেখা।',
      'image': 'https://picsum.photos/seed/bangla1/100/150',
      'pdf': 'assets/pdf/Jyotish.pdf',
      'langugage': 'Bangla',
    },
  ];

  void _handleExplore(String title, String pdfPath, String langugage, String description, String image, String author) {
    // Navigate to StoryDetail instead of BookDetailsPage
   
   print('hii');
   
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  StoryDetail(
        title: title,
        description: description,
        pdfPath: pdfPath,
        langugage: langugage,
        image: image,
        author: author,
        authorImage: image,
        
      )),
    );
  }

  Widget _buildGridBookCard(Map<String, String> book) {
    return InkWell(
      onTap:
          () =>
              _handleExplore(book['title']!, book['pdf']!, book['langugage']!, book['description']!,
              
              
              book['image']!,
              book['author']!,
              ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book['image']!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120,
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey[700],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueGrey,
                          ),
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 1.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Book Title
              Text(
                book['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Book Author
              Text(
                book['author']!,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Expanded(
                      child: Text(
                        book['description']!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              
              const SizedBox(height: 4),
              // Single Explore Button
              TextButton.icon(
                onPressed:
                    () => _handleExplore(
                      book['title']!,
                      book['spdf']!,
                      book['langugage']!,
                      book['description']!,
                      book['image']!,
                      book['author']!
                    ),
                icon: const Icon(Icons.explore, size: 14),
                label: const Text('Explore', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListBookCard(Map<String, String> book) {
    return InkWell(
      onTap:
          () =>
              _handleExplore(book['title']!, book['pdf']!, book['langugage']!, book['description']!,
              
              book['image']!
              , book['author']!,
              ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book['image']!,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author']!,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        book['description']!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Single Explore Button
                    ElevatedButton.icon(
                      onPressed:
                          () => _handleExplore(
                            book['title']!,
                            book['pdf']!,
                            book['langugage']!,
                            book['description']!,
                            book['image']!,
                            book['author']!
                          ),
                      icon: const Icon(Icons.explore, size: 16),
                      label: const Text('Explore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text(
          "eBook Catalog",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.list : Icons.grid_view,
              color: Colors.blueGrey[800],
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey[100]!, const Color(0xFFF6F9FC)],
            stops: const [0.0, 0.2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueGrey,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                  : isGridView
                  ? GridView.builder(
                    itemCount: books.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 10,
                          childAspectRatio:
                              0.65, // Adjusted to provide more height
                        ),
                    itemBuilder:
                        (context, index) => _buildGridBookCard(books[index]),
                  )
                  : ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder:
                        (context, index) => SizedBox(
                          height: 180,
                          child: _buildListBookCard(books[index]),
                        ),
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });

          // Simulating an upload action
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add new book functionality coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        },
        backgroundColor: Colors.blueGrey[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
