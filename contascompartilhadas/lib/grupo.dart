import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GrupoPage extends StatefulWidget {
  @override
  _GrupoPageState createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _membrosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _enviarConvite() async {
    final id = _idController.text;
    final nome = _nomeController.text;
    final membros = _membrosController.text;
    final email = _emailController.text;

    if (id.isEmpty || nome.isEmpty || membros.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final linkConfirmacao = 'https://yourdomain.com/confirmar?grupo_id=$id&email=$email'; // 

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull(
        'subject=Convite para Criar Conta'
        '&body=Olá,%0D%0A%0D%0A'
        'Você foi convidado para se juntar ao grupo:%0D%0A'
        'ID: $id%0D%0A'
        'Nome: $nome%0D%0A'
        'Membros: $membros%0D%0A%0D%0A'
        'Clique no link abaixo para preencher suas informações e criar uma conta compartilhada com quem enviou o convite:%0D%0A'
        '$linkConfirmacao%0D%0A%0D%0A'
        'Atenciosamente,%0D%0A'
        'Sua Equipe',
      ),
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o cliente de e-mail')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tentar enviar o e-mail: $e')),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _membrosController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Grupo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Preencha as informações do grupo:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID do Grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o ID do grupo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do grupo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _membrosController,
                  decoration: InputDecoration(
                    labelText: 'Membros do Grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira os membros do grupo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Preencha o e-mail para enviar o convite:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o e-mail';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _enviarConvite,
                  child: Text('Enviar Convite'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
