import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GifRepository {

  String? search; //pesquisa pode ser null
  int offset = 0; //páginas

  Future<Map> getGifs() async {
    http.Response response; //cria a variável

    if(search == null || search == ""){
       //traz os melhores gifs
      response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=ddwaRSLPtxegL4Vosh8RLmxg79TU97Ra&limit=20&rating=g'));
    }else{
      //faz a pesquisa
      response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=ddwaRSLPtxegL4Vosh8RLmxg79TU97Ra&q=$search&limit=19&offset=$offset&rating=g&lang=en'));
    }
    return json.decode(response.body);

  }
}
