import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContaInformacao {
  String id;
  String nome;
  String? categoria;
  double valor;
  DateTime data;
  final String userId;

  ContaInformacao({
    required this.id,
    required this.nome,
    this.categoria,
    required this.valor,
    required this.data,
  }) : userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarConta(ContaInformacao conta) async {
    try {
      print('Iniciando adição da conta...');
      await _firestore
          .collection('usuarios') 
          .doc(userId)
          .collection('contas') 
          .doc(conta.id) 
          .set(conta.toMap());
      print('Conta adicionada com sucesso!');
    } on FirebaseException catch (e) {
      print('Erro do Firebase: ${e.code}');
      rethrow; 
    } catch (e) {
      print('Erro ao adicionar conta: $e');
      rethrow; 
    }
  }

  Future<void> atualizarConta(ContaInformacao conta) async {
    try {
      print('Iniciando atualização da conta...');
      await _firestore
          .collection('usuarios') 
          .doc(userId)
          .collection('contas') 
          .doc(conta.id) 
          .update(conta.toMap());
      print('Conta atualizada com sucesso!');
    } on FirebaseException catch (e) {
      print('Erro do Firebase: ${e.code}');
      rethrow; 
    } catch (e) {
      print('Erro ao atualizar conta: $e');
      rethrow; 
    }
  }

  Future<void> removerConta(String id) async {
    try {
      print('Iniciando remoção da conta...');
      await _firestore
          .collection('usuarios') 
          .doc(userId)
          .collection('contas') 
          .doc(id) 
          .delete();
      print('Conta removida com sucesso!');
    } on FirebaseException catch (e) {
      print('Erro do Firebase: ${e.code}');
      rethrow; 
    } catch (e) {
      print('Erro ao remover conta: $e');
      rethrow; 
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'valor': valor,
      'data': data.toIso8601String(),
    };
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conectarStreamConta() {
    return _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('contas')
        .snapshots();
  }

  static ContaInformacao fromMap(Map<String, dynamic> map, String id) {
    return ContaInformacao(
      id: id,
      nome: map['nome'],
      categoria: map['categoria'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
    );
  }

  void editarConta() {}

  ContaInformacao copyWith({required String nome, String? categoria, required double valor, required DateTime data}) {
    return ContaInformacao(
      id: this.id,
      nome: nome,
      categoria: categoria,
      valor: valor,
      data: data,
    );
  }
}
