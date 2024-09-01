import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';

final Color azulBaixoGradiente = const Color.fromARGB(255, 31, 84, 109);

void mostrarModalAtualizarConta(BuildContext context, {ContaInformacao? conta, bool isEditMode = false}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: azulBaixoGradiente,
    isDismissible: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return AtualizarContaModal(
        conta: conta ?? ContaInformacao(
          id: const Uuid().v1(),
          nome: '',
          valor: 0.0,
          categoria: '',
          data: DateTime.now(),
        ),
        isEditMode: isEditMode,
      );
    },
  );
}

class ContaInformacao {
  final String id;
  final String nome;
  final double valor;
  final String categoria;
  final DateTime data;

  ContaInformacao({
    required this.id,
    required this.nome,
    required this.valor,
    required this.categoria,
    required this.data,
  });

  Future<void> adicionarInformacao(ContaInformacao conta) async {
    
  }

  Future<void> atualizarInformacao(ContaInformacao conta) async {
    
  }

  Future<void> removerInformacao(String id) async {
    
  }
}

class AtualizarContaModal extends StatefulWidget {
  final ContaInformacao conta;
  final bool isEditMode;

  const AtualizarContaModal({super.key, required this.conta, this.isEditMode = false});

  @override
  State<AtualizarContaModal> createState() => _AtualizarContaModalState();
}

class _AtualizarContaModalState extends State<AtualizarContaModal> {
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _valorCtrl = TextEditingController();
  final TextEditingController _categoriaCtrl = TextEditingController();

  bool isCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl.text = widget.conta.nome;
    _valorCtrl.text = widget.conta.valor.toStringAsFixed(2);
    _categoriaCtrl.text = widget.conta.categoria;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEditMode ? "Atualizar Conta" : "Cadastrar Conta",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const Divider(color: Colors.white),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Qual o nome?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Qual o valor?",
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoriaCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Qual a categoria?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: enviarClicado,
              child: isCarregando
                  ? const CircularProgressIndicator()
                  : Text(widget.isEditMode ? "Atualizar" : "Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> enviarClicado() async {
    setState(() {
      isCarregando = true;
    });

    String nome = _nomeCtrl.text;
    double valor = double.tryParse(_valorCtrl.text) ?? 0.0;
    String categoria = _categoriaCtrl.text;

    ContaInformacao conta = ContaInformacao(
      id: widget.conta.id,
      nome: nome,
      valor: valor,
      categoria: categoria,
      data: widget.conta.data,
    );

    try {
      if (widget.isEditMode) {
        await conta.atualizarInformacao(conta);
      } else {
        await conta.adicionarInformacao(conta);
      }
      log("Conta ${widget.isEditMode ? 'atualizada' : 'adicionada'} com sucesso");
      Navigator.pop(context);
    } catch (e) {
      log("Erro ao ${widget.isEditMode ? 'atualizar' : 'adicionar'} conta: $e");
    } finally {
      setState(() {
        isCarregando = false;
      });
    }
  }
}
