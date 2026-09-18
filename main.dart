import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const SkOttApp());

class Movie {
  final String title, category, description, image, videoUrl;
  Movie(this.title, this.category, this.description, this.image, this.videoUrl);
}

final movies = <Movie>[
  Movie('SK Action', 'Action', 'एक्शन से भरपूर मनोरंजन।', 'https://picsum.photos/seed/action/800/450',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
  Movie('SK Drama', 'Drama', 'कहानी, रिश्ते और रोमांच।', 'https://picsum.photos/seed/drama/800/450',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
  Movie('SK Comedy', 'Comedy', 'हल्की-फुल्की कॉमेडी और मज़ा।', 'https://picsum.photos/seed/comedy/800/450',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
  Movie('SK Series', 'Web Series', 'एक नई वेब सीरीज़ का अनुभव।', 'https://picsum.photos/seed/series/800/450',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
];

class SkOttApp extends StatelessWidget {
  const SkOttApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SK OTT',
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF080808),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark)),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int index=0;
  final List<Movie> watchlist=[];
  @override Widget build(BuildContext context) {
    final pages=[
      _home(context),
      _search(context),
      _watchlist(context),
      const ProfilePage()
    ];
    return Scaffold(body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(selectedIndex:index,
        onDestinationSelected:(i)=>setState(()=>index=i),
        destinations: const [
          NavigationDestination(icon:Icon(Icons.home_outlined), selectedIcon:Icon(Icons.home), label:'Home'),
          NavigationDestination(icon:Icon(Icons.search), label:'Search'),
          NavigationDestination(icon:Icon(Icons.favorite_border), selectedIcon:Icon(Icons.favorite), label:'Watchlist'),
          NavigationDestination(icon:Icon(Icons.person_outline), selectedIcon:Icon(Icons.person), label:'Profile'),
        ]));
  }
  Widget _home(BuildContext c)=>CustomScrollView(slivers:[
    SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,20,18,10),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        const Text('SK OTT',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
        IconButton(onPressed:()=>setState(()=>index=1),icon:const Icon(Icons.search))
      ]))),
    SliverToBoxAdapter(child:Container(height:220,margin:const EdgeInsets.all(16),
      decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),image:const DecorationImage(
        image:NetworkImage('https://picsum.photos/seed/hero/1200/700'),fit:BoxFit.cover)),
      child:Container(padding:const EdgeInsets.all(22),alignment:Alignment.bottomLeft,
        decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),gradient:LinearGradient(
          begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Colors.black87])),
        child:Column(mainAxisAlignment:MainAxisAlignment.end,crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('SK Originals',style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
          const SizedBox(height:8), const Text('नया मनोरंजन, एक ही जगह'),
          const SizedBox(height:12), FilledButton.icon(onPressed:()=>_open(c,movies[0]),
            icon:const Icon(Icons.play_arrow),label:const Text('Watch Now'))
        ])))),
    _section('Trending'),
    _cards(c,movies.take(3).toList()),
    _section('Web Series'),
    _cards(c,movies.where((m)=>m.category=='Web Series').toList()),
  ]);
  Widget _section(String s)=>SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,14,18,8),
    child:Text(s,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))));
  Widget _cards(BuildContext c,List<Movie> list)=>SliverToBoxAdapter(child:SizedBox(height:190,
    child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:18),scrollDirection:Axis.horizontal,
      itemCount:list.length,itemBuilder:(_,i)=>GestureDetector(onTap:()=>_open(c,list[i]),
        child:SizedBox(width:250,child:ClipRRect(borderRadius:BorderRadius.circular(12),
          child:Image.network(list[i].image,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:Colors.grey[900],
            child:const Icon(Icons.movie,size:50))))),),separatorBuilder:(_,__)=>const SizedBox(width:12))));
  Widget _search(BuildContext c){return const SearchPage();}
  Widget _watchlist(BuildContext c)=>watchlist.isEmpty
    ? const Center(child:Text('Watchlist खाली है'))
    : ListView.builder(padding:const EdgeInsets.all(16),itemCount:watchlist.length,
      itemBuilder:(_,i)=>ListTile(leading:Image.network(watchlist[i].image,width:90,fit:BoxFit.cover),
        title:Text(watchlist[i].title),subtitle:Text(watchlist[i].category),
        onTap:()=>_open(c,watchlist[i])));
  void _open(BuildContext c,Movie m)=>Navigator.push(c,MaterialPageRoute(builder:(_)=>DetailsPage(movie:m,
    inWatchlist:watchlist.contains(m),onWatch:(){setState(()=>watchlist.contains(m)?watchlist.remove(m):watchlist.add(m));})));
}

class SearchPage extends StatefulWidget { const SearchPage({super.key}); @override State<SearchPage> createState()=>_SearchPageState();}
class _SearchPageState extends State<SearchPage>{
  String q='';
  @override Widget build(BuildContext c){
    final list=movies.where((m)=>m.title.toLowerCase().contains(q.toLowerCase())).toList();
    return Column(children:[Padding(padding:const EdgeInsets.all(16),child:TextField(
      onChanged:(v)=>setState(()=>q=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Movie या series खोजें',border:OutlineInputBorder()))),
      Expanded(child:ListView.builder(itemCount:list.length,itemBuilder:(_,i)=>ListTile(
        leading:Image.network(list[i].image,width:100,fit:BoxFit.cover),title:Text(list[i].title),subtitle:Text(list[i].category),
        onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>DetailsPage(movie:list[i],inWatchlist:false,onWatch:(){})))))]);}
}

class DetailsPage extends StatelessWidget{
  final Movie movie; final bool inWatchlist; final VoidCallback onWatch;
  const DetailsPage({super.key,required this.movie,required this.inWatchlist,required this.onWatch});
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(movie.title)),
    body:ListView(children:[Image.network(movie.image,height:230,fit:BoxFit.cover),
      Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(movie.title,style:const TextStyle(fontSize:27,fontWeight:FontWeight.bold)),const SizedBox(height:8),
        Text(movie.category,style:TextStyle(color:Colors.grey[400])),const SizedBox(height:15),Text(movie.description),
        const SizedBox(height:20),Row(children:[
          Expanded(child:FilledButton.icon(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>PlayerPage(movie:movie))),
            icon:const Icon(Icons.play_arrow),label:const Text('Play'))),
          const SizedBox(width:10),IconButton(onPressed:onWatch,icon:Icon(inWatchlist?Icons.favorite:Icons.favorite_border))
        ])
      ]))]));
}

class PlayerPage extends StatefulWidget{final Movie movie;const PlayerPage({super.key,required this.movie});@override State<PlayerPage> createState()=>_PlayerPageState();}
class _PlayerPageState extends State<PlayerPage>{
  late VideoPlayerController controller;
  @override void initState(){super.initState();controller=VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl))
    ..initialize().then((_){setState((){});controller.play();});}
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(widget.movie.title)),
    body:Center(child:controller.value.isInitialized?AspectRatio(aspectRatio:controller.value.aspectRatio,
      child:Stack(alignment:Alignment.bottomCenter,children:[VideoPlayer(controller),
        VideoProgressIndicator(controller,allowScrubbing:true)])):const CircularProgressIndicator()));
}

class ProfilePage extends StatelessWidget{const ProfilePage({super.key});@override Widget build(BuildContext c)=>const Center(
  child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.account_circle,size:90),SizedBox(height:15),
    Text('SK OTT Profile',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('Login & subscription यहाँ जोड़े जा सकते हैं।')]));
}
