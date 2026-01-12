library msitef_flutter;

import 'dart:async';
import 'package:flutter/services.dart';

/// Plugin para integração com M-SiTef da Software Express
/// Permite realizar transações TEF em terminais Android
class MsitefFlutter {
  static const MethodChannel _channel = MethodChannel('msitef_flutter');

  /// Realiza uma transação de venda
  /// 
  /// [empresaSitef] - Código da empresa no SiTef
  /// [enderecoSitef] - IP do servidor SiTef
  /// [cnpjCpf] - CNPJ ou CPF do estabelecimento
  /// [valor] - Valor da transação em centavos (ex: 1000 = R$ 10,00)
  /// [operador] - Código do operador (opcional)
  /// [numeroCupom] - Número do cupom fiscal (opcional)
  /// [comExterna] - Tipo de comunicação (0=TLS SoftExpress, 1=TCP, 2=com externa, 3=GSurf, 4=TLSGWP)
  /// [restricoes] - Restrições de pagamento (opcional)
  /// [isDoubleValidation] - Validação dupla (opcional)
  /// [timeout] - Timeout em segundos (padrão: 180)
  /// 
  /// Retorna um [MsitefResponse] com o resultado da transação
  static Future<MsitefResponse> venda({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    String restricoes = "",
    bool isDoubleValidation = false,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "0", // Venda
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valor,
      operador: operador,
      numeroCupom: numeroCupom,
      comExterna: comExterna,
      restricoes: restricoes,
      isDoubleValidation: isDoubleValidation,
      timeout: timeout,
      tipoCartao: ""
    );
  }

  /// Realiza uma transação de venda com débito
  static Future<MsitefResponse> vendaDebito({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "2", // Débito
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valor,
      operador: operador,
      numeroCupom: numeroCupom,
      comExterna: comExterna,
      timeout: timeout,      
      tipoCartao: "D"
    );
  }

  /// Realiza uma transação de venda com crédito
  /// 
  /// [parcelas] - Número de parcelas (padrão: 1 = à vista)
  static Future<MsitefResponse> vendaCredito({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    int parcelas = 1,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "3", // Crédito
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valor,
      operador: operador,
      numeroCupom: numeroCupom,
      comExterna: comExterna,
      restricoes: "numParcelas=$parcelas",
      timeout: timeout,
      tipoCartao: "C"
    );
  }

  /// Realiza uma transação PIX
  static Future<MsitefResponse> pix({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "122", // Carteiras digitais (PIX)
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valor,
      operador: operador,
      numeroCupom: numeroCupom,
      comExterna: comExterna,
      restricoes: "transacoesHabilitadas=7;8;", // Restringe a PIX
      timeout: timeout,
      tipoCartao: "P"
    );
  }

  /// Realiza um cancelamento de transação
  static Future<MsitefResponse> cancelamento({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "200", // Cancelamento
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valor,
      operador: operador,
      numeroCupom: numeroCupom,
      comExterna: comExterna,
      timeout: timeout,
      tipoCartao: ""
    );
  }

  /// Abre o menu administrativo do M-SiTef
  static Future<MsitefResponse> menuAdministrativo({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    String operador = "0001",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "110", // Menu administrativo
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: 0,
      operador: operador,
      comExterna: comExterna,
      timeout: timeout,
      tipoCartao: ""
    );
  }

  /// Realiza reimpressão do último comprovante
  static Future<MsitefResponse> reimpressao({
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    String operador = "0001",
    int comExterna = 0,
    int timeout = 180,
  }) async {
    return _executarTransacao(
      modalidade: "114", // Reimpressão
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: 0,
      operador: operador,
      comExterna: comExterna,
      timeout: timeout,
      tipoCartao: ""
    );
  }

  /// Executa uma transação genérica no M-SiTef
  static Future<MsitefResponse> _executarTransacao({
    required String modalidade,
    required String empresaSitef,
    required String enderecoSitef,
    required String cnpjCpf,
    required int valor,
    required String tipoCartao,
    String operador = "0001",
    String numeroCupom = "",
    int comExterna = 0,
    String restricoes = "",
    bool isDoubleValidation = false,
    int timeout = 180,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'modalidade': modalidade,
        'empresaSitef': empresaSitef,
        'enderecoSitef': enderecoSitef,
        'cnpjCpf': cnpjCpf,
        'valor': valor.toString(),
        'operador': operador,
        'numeroCupom': numeroCupom,
        'comExterna': comExterna.toString(),
        'restricoes': restricoes,
        'isDoubleValidation': isDoubleValidation ? "1" : "0",
        'timeout': timeout.toString(),
        'tipoCartao': tipoCartao
      };

      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('executarTransacao', params);

      if (result == null) {
        return MsitefResponse(
          sucesso: false,
          codResp: "-1",
          mensagem: "Erro: resposta nula do M-SiTef",
        );
      }

      return MsitefResponse.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      return MsitefResponse(
        sucesso: false,
        codResp: "-1",
        mensagem: "Erro: ${e.message}",
      );
    } catch (e) {
      return MsitefResponse(
        sucesso: false,
        codResp: "-1",
        mensagem: "Erro inesperado: $e",
      );
    }
  }

  /// Verifica se o M-SiTef está instalado no dispositivo
  static Future<bool> isInstalado() async {
    try {
      final bool result = await _channel.invokeMethod('isInstalado');
      return result;
    } catch (e) {
      return false;
    }
  }
}

/// Classe que representa a resposta de uma transação M-SiTef
class MsitefResponse {
  /// Indica se a transação foi bem sucedida
  final bool sucesso;

  /// Código de resposta do SiTef
  final String codResp;

  /// Mensagem de retorno
  final String mensagem;

  /// NSU do host
  final String? nsuHost;

  /// NSU local
  final String? nsuLocal;

  /// Código de autorização
  final String? codAutorizacao;

  /// Bandeira do cartão
  final String? bandeira;

  /// Nome do cartão
  final String? nomeCartao;

  /// Últimos 4 dígitos do cartão
  final String? ultimos4Digitos;

  /// Tipo de cartão (crédito/débito)
  final String? tipoCartao;

  /// Via do cliente
  final String? viaCliente;

  /// Via do estabelecimento
  final String? viaEstabelecimento;

  /// Data/hora da transação
  final String? dataHora;

  /// Valor da transação
  final String? valor;

  /// Número de parcelas
  final String? parcelas;

  /// Código da transação
  final String? codTrans;

  /// Dados completos retornados
  final Map<String, dynamic>? dadosCompletos;

  MsitefResponse({
    required this.sucesso,
    required this.codResp,
    required this.mensagem,
    this.nsuHost,
    this.nsuLocal,
    this.codAutorizacao,
    this.bandeira,
    this.nomeCartao,
    this.ultimos4Digitos,
    this.tipoCartao,
    this.viaCliente,
    this.viaEstabelecimento,
    this.dataHora,
    this.valor,
    this.parcelas,
    this.codTrans,
    this.dadosCompletos,
  });

  factory MsitefResponse.fromMap(Map<String, dynamic> map) {
    final String codResp = map['CODRESP']?.toString() ?? map['codResp']?.toString() ?? "-1";
    final bool sucesso = codResp == "0";

    return MsitefResponse(
      sucesso: sucesso,
      codResp: codResp,
      mensagem: map['MENSAGEM']?.toString() ?? map['mensagem']?.toString() ?? "",
      nsuHost: map['NSU_HOST']?.toString() ?? map['nsuHost']?.toString(),
      nsuLocal: map['NSU_SITEF']?.toString() ?? map['nsuLocal']?.toString(),
      codAutorizacao: map['COD_AUTORIZACAO']?.toString() ?? map['codAutorizacao']?.toString(),
      bandeira: map['BANDEIRA']?.toString() ?? map['bandeira']?.toString(),
      nomeCartao: map['NOME_CARTAO']?.toString() ?? map['nomeCartao']?.toString(),
      ultimos4Digitos: map['ULTIMOS_4_DIGITOS']?.toString() ?? map['ultimos4Digitos']?.toString(),
      tipoCartao: map['TIPO_CARTAO']?.toString() ?? map['tipoCartao']?.toString(),
      viaCliente: map['VIA_CLIENTE']?.toString() ?? map['viaCliente']?.toString(),
      viaEstabelecimento: map['VIA_ESTABELECIMENTO']?.toString() ?? map['viaEstabelecimento']?.toString(),
      dataHora: map['DATA_HORA']?.toString() ?? map['dataHora']?.toString(),
      valor: map['VALOR']?.toString() ?? map['valor']?.toString(),
      parcelas: map['PARCELAS']?.toString() ?? map['parcelas']?.toString(),
      codTrans: map['COD_TRANS']?.toString() ?? map['codTrans']?.toString(),
      dadosCompletos: map,
    );
  }

  /// Converte para Map (útil para serialização JSON)
  Map<String, dynamic> toMap() {
    return {
      'sucesso': sucesso,
      'codResp': codResp,
      'mensagem': mensagem,
      'nsuHost': nsuHost,
      'nsuLocal': nsuLocal,
      'codAutorizacao': codAutorizacao,
      'bandeira': bandeira,
      'nomeCartao': nomeCartao,
      'ultimos4Digitos': ultimos4Digitos,
      'tipoCartao': tipoCartao,
      'viaCliente': viaCliente,
      'viaEstabelecimento': viaEstabelecimento,
      'dataHora': dataHora,
      'valor': valor,
      'parcelas': parcelas,
      'codTrans': codTrans,
      'dadosCompletos': dadosCompletos,
    };
  }

  @override
  String toString() {
    return 'MsitefResponse(sucesso: $sucesso, codResp: $codResp, mensagem: $mensagem, nsuHost: $nsuHost, codAutorizacao: $codAutorizacao, bandeira: $bandeira)';
  }
}
