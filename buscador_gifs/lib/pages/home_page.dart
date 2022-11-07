import 'package:buscador_gifs/pages/gif_page.dart';
import 'package:buscador_gifs/repositories/gif_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GifRepository gifRepository = GifRepository();

  @override
  void initState() {
    super.initState();

    gifRepository.getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              //texto que fica dentro
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  gifRepository.search = text;
                  gifRepository.offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: gifRepository.getGifs(),
              builder: (context, snapshot) {
                //função que vai criar o layout dependendo do status
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        //especificando a cor, sempre parada, do tipo branca
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Erro ao carregar dados :(',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      );
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    String? searchCopy = gifRepository.search;
    if (searchCopy == null) {
      //se não tiver pesquisado nada, retorna o valor total de gifs
      return data.length;
    } else {
      return data.length + 1;             //se não, retorna o valor total de gifs + 1, para ficar um espaço para colocar um botao
    }
  }

  Future<void> share(String link) async {
    await FlutterShare.share(
      title: 'Compartilhar Gif',
      linkUrl: link,
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    //criando uma grade
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      //como os itens vão ser organizados na tela
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,                                          //quantos itens vai poder ter na horizontal
        crossAxisSpacing: 12,                                       //espaçamento dos itens na horizontal
        mainAxisSpacing: 12,                                       //espaçamento dos itens na vertical
      ),
      itemCount: _getCount(snapshot.data['data']),                //quantidade de itens
      itemBuilder: (context, index) {
        String? searchCopy = gifRepository.search;
        if (searchCopy == null || searchCopy == "" || index < snapshot.data['data'].length) {
          // se não estiver pesquisando, ou não é o último item
          return GestureDetector(
            onLongPress: (){
              share(snapshot.data['data'][index]['images']['fixed_height']['url'].toString());
            },
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  //rota para a próxima página
                  builder: (context) => GifPage(gifData: snapshot.data['data'][index]),
                ),
              );
            },
            child: FadeInImage.memoryNetwork(                 //carrega as imagens de uma forma suave
              placeholder: kTransparentImage, 
              image: snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        } else {
          //caso contrário, cria o botão
          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  gifRepository.offset += 19;                 //pega os próximos 19 itens
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
