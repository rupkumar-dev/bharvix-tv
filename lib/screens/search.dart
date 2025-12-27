// import 'dart:async';

// import 'package:bharvix_tv/home.dart';
// import 'package:bharvix_tv/models/app_channel.dart';
// import 'package:bharvix_tv/provider/iptv_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // class SearchScreen extends StatefulWidget {
// //   const SearchScreen({super.key});

// //   @override
// //   State<SearchScreen> createState() => _SearchScreenState();
// // }

// // class _SearchScreenState extends State<SearchScreen> {
// //   Timer? _timer;
// //   String _query = '';

// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final provider = context.watch<IptvProvider>();
// //     final results = provider.search(_query);

// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: Colors.black,
// //         title: TextField(
// //           autofocus: true,
// //           onChanged: (v) {
// //             _timer?.cancel();
// //             _timer = Timer(
// //               const Duration(milliseconds: 300),
// //               () => setState(() => _query = v),
// //             );
// //           },
// //           style: const TextStyle(color: Colors.white),
// //           decoration: const InputDecoration(
// //             hintText: 'Search channels, categories...',
// //             hintStyle: TextStyle(color: Colors.white54),
// //             border: InputBorder.none,
// //           ),
// //         ),
// //       ),
// //       body: ChannelGrid(list: results),
// //     );
// //   }
// // }
// class SearchScreen extends StatefulWidget {
//   final String initialQuery;
//   const SearchScreen({super.key, this.initialQuery = ''});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   late final TextEditingController _controller;
//   late final FocusNode _focusNode;
//   Timer? _debounce;

//   String _query = '';

//   @override
//   void initState() {
//     super.initState();

//     _query = widget.initialQuery;
//     _controller = TextEditingController(text: _query);
//     _focusNode = FocusNode();

//     // optional: auto focus after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _onTextChanged(String value) {
//     _debounce?.cancel();
//     _debounce = Timer(
//       const Duration(milliseconds: 300),
//       () {
//         if (_query == value) return;
//         setState(() => _query = value);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<IptvProvider>();
//     final searching = _query.trim().isNotEmpty;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: TextField(
//           controller: _controller,
//           // focusNode: _focusNode,
//           onChanged: _onTextChanged,
//           style: const TextStyle(color: Colors.white),
//           decoration: const InputDecoration(
//             hintText: 'Search channels, movies, language...',
//             hintStyle: TextStyle(color: Colors.white54),
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//       body: searching
//           ? ChannelGrid(list: provider.search(_query))
//           : _DiscoverView(provider: provider),
//     );
//   }
// }


// class _DiscoverView extends StatelessWidget {
//   final IptvProvider provider;
//   const _DiscoverView({required this.provider});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(12),
//       children: [
//         _sectionTitle('Trending Channels'),
//         _horizontalList(provider.trendingChannels()),

//         _sectionTitle('Top 10 Movies'),
//         _horizontalList(provider.topMovies()),

//         _sectionTitle('Browse by Language'),
//         _languageChips(context),
//       ],
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _horizontalList(List<AppChannel> list) {
//     return SizedBox(
//       height: 150,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: list.length,
//         itemBuilder: (_, i) {
//           final c = list[i];
//           return Container(
//             width: 120,
//             margin: const EdgeInsets.only(right: 12),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Image.network(
//                     c.logo,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) =>
//                         const Icon(Icons.tv, color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   c.name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
  

//   // Widget _languageChips(BuildContext context) {
//   //   final langs = ['Hindi', 'English', 'Tamil', 'Telugu', 'Malayalam'];

//   //   return Wrap(
//   //     spacing: 8,
//   //     children: langs.map((lang) {
//   //       return ActionChip(
//   //         label: Text(lang),
//   //         onPressed: () {
//   //           Navigator.push(
//   //             context,
//   //             MaterialPageRoute(
//   //               builder: (_) => SearchScreen(initialQuery: lang),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     }).toList(),
//   //   );
//   // }
//   Widget _languageChips(BuildContext context) {
//   final langs = ['Hindi', 'English', 'Tamil', 'Telugu', 'Malayalam'];

//   return Wrap(
//     spacing: 8,
//     children: langs.map((lang) {
//       return ActionChip(
//         label: Text(lang),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => LanguageScreen(language: lang),
//             ),
//           );
//         },
//       );
//     }).toList(),
//   );
// }

// }

// class LanguageScreen extends StatelessWidget {
//   final String language;
//   const LanguageScreen({super.key, required this.language});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<IptvProvider>();

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(language),
//         backgroundColor: Colors.black,
//       ),
//       body: ChannelGrid(
//         list: provider.byLanguage(language),
//       ),
//     );
//   }
// }
