// ============================================================
// CUSTOM ACTIONS PRONTAS PARA FLUTTERFLOW
// ============================================================
// Copie cada bloco abaixo para criar suas Custom Actions
// no FlutterFlow (Custom Code > Actions > + Add Action)
// ============================================================

// ============================================================
// ACTION 1: verificarMsitefInstalado
// ============================================================
// Nome: verificarMsitefInstalado
// Return Type: bool
// Arguments: nenhum
// ============================================================

import 'package:msitef_flutter/msitef_flutter.dart';

Future<bool> verificarMsitefInstalado() async {
  return await MsitefFlutter.isInstalado();
}


// ============================================================
// ACTION 2: realizarVendaTef
// ============================================================
// Nome: realizarVendaTef
// Return Type: String (JSON)
// Arguments:
//   - valorCentavos: int (required)
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
//   - operador: String (default: "0001")
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarVendaTef(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
  String? operador,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado no dispositivo',
      });
    }

    MsitefResponse response = await MsitefFlutter.venda(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
      operador: operador ?? "0001",
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'nsuHost': response.nsuHost ?? '',
      'nsuLocal': response.nsuLocal ?? '',
      'codAutorizacao': response.codAutorizacao ?? '',
      'bandeira': response.bandeira ?? '',
      'nomeCartao': response.nomeCartao ?? '',
      'tipoCartao': response.tipoCartao ?? '',
      'parcelas': response.parcelas ?? '',
      'viaCliente': response.viaCliente ?? '',
      'viaEstabelecimento': response.viaEstabelecimento ?? '',
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 3: realizarVendaCredito
// ============================================================
// Nome: realizarVendaCredito
// Return Type: String (JSON)
// Arguments:
//   - valorCentavos: int (required)
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarVendaCredito(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.vendaCredito(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'nsuHost': response.nsuHost ?? '',
      'codAutorizacao': response.codAutorizacao ?? '',
      'bandeira': response.bandeira ?? '',
      'parcelas': response.parcelas ?? '',
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 4: realizarVendaDebito
// ============================================================
// Nome: realizarVendaDebito
// Return Type: String (JSON)
// Arguments:
//   - valorCentavos: int (required)
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarVendaDebito(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.vendaDebito(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'nsuHost': response.nsuHost ?? '',
      'codAutorizacao': response.codAutorizacao ?? '',
      'bandeira': response.bandeira ?? '',
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 5: realizarPix
// ============================================================
// Nome: realizarPix
// Return Type: String (JSON)
// Arguments:
//   - valorCentavos: int (required)
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarPix(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.pix(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'nsuHost': response.nsuHost ?? '',
      'codAutorizacao': response.codAutorizacao ?? '',
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 6: cancelarTransacao
// ============================================================
// Nome: cancelarTransacao
// Return Type: String (JSON)
// Arguments:
//   - valorCentavos: int (required)
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> cancelarTransacao(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.cancelamento(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 7: abrirMenuAdministrativo
// ============================================================
// Nome: abrirMenuAdministrativo
// Return Type: String (JSON)
// Arguments:
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> abrirMenuAdministrativo(
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.menuAdministrativo(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// ACTION 8: reimprimirComprovante
// ============================================================
// Nome: reimprimirComprovante
// Return Type: String (JSON)
// Arguments:
//   - empresaSitef: String (required)
//   - enderecoSitef: String (required)
//   - cnpjCpf: String (required)
// ============================================================

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> reimprimirComprovante(
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'codResp': '-1',
        'mensagem': 'M-SiTef não está instalado',
      });
    }

    MsitefResponse response = await MsitefFlutter.reimpressao(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
    );

    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'viaCliente': response.viaCliente ?? '',
      'viaEstabelecimento': response.viaEstabelecimento ?? '',
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'codResp': '-1',
      'mensagem': 'Erro: ${e.toString()}',
    });
  }
}


// ============================================================
// CUSTOM FUNCTION: parseResultadoTef
// ============================================================
// Esta é uma Custom Function (não Action) para parsear o JSON
// Nome: parseResultadoTef
// Return Type: CustomTefResult (você precisa criar este tipo)
// Arguments:
//   - jsonString: String (required)
// ============================================================

import 'dart:convert';

// Use este código para extrair campos específicos do JSON
// Adapte conforme necessário para seu Data Type no FlutterFlow

String? getValorJson(String jsonString, String campo) {
  try {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data[campo]?.toString();
  } catch (e) {
    return null;
  }
}

bool isTransacaoAprovada(String jsonString) {
  try {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['sucesso'] == true;
  } catch (e) {
    return false;
  }
}
