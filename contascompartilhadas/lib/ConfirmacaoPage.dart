import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmacaoPage extends StatefulWidget {
  @override
  _ConfirmacaoPageState createState() => _ConfirmacaoPageState();
}

class _ConfirmacaoPageState extends State<ConfirmacaoPage> {
  @override
  void initState() {
    super.initState();
    _adicionarUsuarioAoGrupo();
  }

  Future<void> _adicionarUsuarioAoGrupo() async {
    final queryParameters = Uri.base.queryParameters;
    final groupId = queryParameters['groupId'];
    final userEmail = queryParameters['userEmail'];

    if (groupId != null && userEmail != null) {
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/confirmar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'groupId': groupId,
          'userEmail': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você foi adicionado ao grupo com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível processar sua solicitação')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível processar sua solicitação')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmação de Convite'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Processando seu convite...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
