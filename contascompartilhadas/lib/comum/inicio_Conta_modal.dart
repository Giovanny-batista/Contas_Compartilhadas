import 'package:contascompartilhadas/servicos/containformacao.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer'; 

final Color azulBaixoGradiente = const Color.fromARGB(255, 31, 84, 109);

void mostrarModalInicio(BuildContext context, {ContaInformacao? conta, bool isEditMode = false, required String titulo, required String textoBotao}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: azulBaixoGradiente,
    isDismissible: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return ContaModal(
        service: conta ?? ContaInformacao(
          id: const Uuid().v1(),
          nome: '',
          valor: 0.0,
          data: DateTime.now(),
        ),
        isEditMode: isEditMode,
        titulo: titulo,
        textoBotao: textoBotao,
      );
    },
  );
}

class ContaModal extends StatefulWidget {
  final ContaInformacao service;
  final bool isEditMode;
  final String titulo;
  final String textoBotao;

  const ContaModal({
    super.key,
    required this.service,
    this.isEditMode = false,
    required this.titulo,
    required this.textoBotao,
  });

  @override
  State<ContaModal> createState() => _ContaModalState();
}

class _ContaModalState extends State<ContaModal> {
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _valorCtrl = TextEditingController();
  final TextEditingController _dataCtrl = TextEditingController();

  String? _categoriaSelecionada;
  final List<String> _categorias = ['Contas Fixas', 'Contas Variáveis'];

  bool isCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl.text = widget.service.nome;
    _valorCtrl.text = widget.service.valor.toStringAsFixed(2);
    _dataCtrl.text = "${widget.service.data.day}/${widget.service.data.month}/${widget.service.data.year}";
    _categoriaSelecionada = widget.service.categoria;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.service.data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dataCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
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
                      widget.titulo,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        if (widget.isEditMode) ...[
                          IconButton(
                            onPressed: () async {
                              
                              log("Editar conta: ${widget.service.id}");
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                await widget.service.removerConta(widget.service.id);
                                Navigator.pop(context);
                              } catch (e) {
                                log("Erro ao remover conta: $e");
                              }
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ],
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
                    hintText: "Qual o nome da conta?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _categoriaSelecionada,
                  hint: const Text('Categoria'),
                  items: _categorias.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (String? novaCategoria) {
                    setState(() {
                      _categoriaSelecionada = novaCategoria;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Qual o valor da conta?",
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
                  controller: _dataCtrl,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Qual é a data da conta?",
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
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
                  : Text(widget.textoBotao),
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
    String? categoria = _categoriaSelecionada;
    double valor = double.tryParse(_valorCtrl.text) ?? 0.0;

    DateTime data;
    try {
      if (_dataCtrl.text.isNotEmpty) {
        List<String> partes = _dataCtrl.text.split('/');
        data = DateTime(
          int.parse(partes[2]), // Ano
          int.parse(partes[1]), // Mês
          int.parse(partes[0]), // Dia
        );
      } else {
        data = DateTime.now();
      }
    } catch (e) {
      data = DateTime.now();
      log("Erro ao processar a data: $e");
    }

    ContaInformacao conta = ContaInformacao(
      id: widget.service.id,
      nome: nome,
      categoria: categoria,
      valor: valor,
      data: data,
    );

    try {
      if (widget.isEditMode) {
        await conta.atualizarConta(conta);
      } else {
        await conta.adicionarConta(conta);
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
