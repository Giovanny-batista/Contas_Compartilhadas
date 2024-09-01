import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contascompartilhadas/servicos/containformacao.dart' as servicos;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:contascompartilhadas/comum/inicio_Conta_modal.dart' as comum;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'grafico.dart'; 
import 'grupo.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImageDialog(BuildContext context) {
    if (_image == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: kIsWeb
              ? Image.network(
                  _image!.path,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
        );
      },
    );
  }

  void _showAddContaModal(BuildContext context) {
    comum.mostrarModalInicio(
      context,
      titulo: "Cadastrar Conta",
      textoBotao: 'Cadastrar',
    );
  }

  void _showUpdateContaModal(BuildContext context, servicos.ContaInformacao conta) {
    comum.mostrarModalInicio(
      context,
      conta: conta,
      titulo: "Editar Informações",
      textoBotao: "Salvar Alterações",
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, servicos.ContaInformacao conta) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: Text('Deseja realmente excluir a conta "${conta.nome}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(auth.currentUser?.uid)
                      .collection('contas')
                      .doc(conta.id)
                      .delete();
                } catch (e) {
                  print('Erro ao excluir a conta: $e');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); 
    } catch (e) {
      print('Erro ao sair: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: const Color.fromARGB(255, 111, 245, 122), 
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user?.uid)
              .collection('contas')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar os dados.'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhuma conta cadastrada.'));
            } else {
              List<servicos.ContaInformacao> listaConta = snapshot.data!.docs.map((doc) {
                return servicos.ContaInformacao.fromMap(doc.data(), doc.id);
              }).toList();

              double totalGeral = listaConta.fold(
                0.0,
                (previousValue, conta) => previousValue + conta.valor,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Bem-vindo, ${user?.email ?? "Usuário"} ao Aplicativo Contas Compartilhadas!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.deepPurple, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          'Total Geral: R\$ ${totalGeral.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: listaConta.length,
                      itemBuilder: (context, index) {
                        final conta = listaConta[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                conta.nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Categoria: ${conta.categoria ?? 'Não definida'}\nValor: R\$ ${conta.valor.toStringAsFixed(2)}\nData: ${conta.data.toLocal()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 111, 111, 111),
                                ),
                              ),
                              trailing: SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showUpdateContaModal(context, conta);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmation(context, conta);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "Usuário"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: GestureDetector(
                onTap: () async {
                  if (_image != null) {
                    _showImageDialog(context);
                  } else {
                    await _pickImage();
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: _image == null
                      ? const Icon(Icons.person, color: Color.fromARGB(255, 198, 168, 249))
                      : ClipOval(
                          child: kIsWeb
                              ? Image.network(
                                  _image!.path,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _image!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              title: const Text('Visualizar Gráficos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GraficoPage()), 
                );
              },
            ),
            ListTile(
              title: const Text('Criar Grupo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GrupoPage()), 
                );
              },
            ),
            ListTile(
              title: const Text('Sair'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContaModal(context),
        tooltip: 'Adicionar Conta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
