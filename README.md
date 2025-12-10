# M-SiTef Flutter Plugin

Plugin Flutter para integração com M-SiTef (Software Express) - TEF para Android.

## Funcionalidades

- ✅ Venda (crédito, débito, voucher)
- ✅ Venda Crédito
- ✅ Venda Débito
- ✅ PIX
- ✅ Cancelamento
- ✅ Menu Administrativo
- ✅ Reimpressão de comprovante
- ✅ Verificação se M-SiTef está instalado

## Instalação

### Opção 1: Via GitHub (recomendado para FlutterFlow)

No seu `pubspec.yaml`:

```yaml
dependencies:
  msitef_flutter:
    git:
      url: https://github.com/SEU-USUARIO/msitef_flutter.git
      ref: main
```

### Opção 2: Path local

```yaml
dependencies:
  msitef_flutter:
    path: ../msitef_flutter
```

## Configuração Android

Adicione no `AndroidManifest.xml` do seu app (dentro de `<manifest>`):

```xml
<queries>
    <package android:name="br.com.softwareexpress.sitef.msitef" />
    <intent>
        <action android:name="br.com.softwareexpress.sitef.msitef.ACTIVITY_CLISITEF" />
    </intent>
</queries>
```

## Uso Básico (Dart)

```dart
import 'package:msitef_flutter/msitef_flutter.dart';

// Verificar se M-SiTef está instalado
bool instalado = await MsitefFlutter.isInstalado();

// Realizar uma venda
MsitefResponse response = await MsitefFlutter.venda(
  empresaSitef: "00000000",      // Código da empresa no SiTef
  enderecoSitef: "192.168.0.1",  // IP do servidor SiTef
  cnpjCpf: "12345678901234",     // CNPJ do estabelecimento
  valor: 1000,                    // R$ 10,00 (valor em centavos)
  operador: "0001",
);

if (response.sucesso) {
  print("Transação aprovada!");
  print("NSU: ${response.nsuHost}");
  print("Autorização: ${response.codAutorizacao}");
} else {
  print("Erro: ${response.mensagem}");
}
```

---

# Uso no FlutterFlow

## Passo 1: Adicionar o Plugin como Dependência

1. No FlutterFlow, vá em **Settings > Project Dependencies**
2. Clique em **Add Dependency**
3. Selecione **GitHub** e adicione:
   - URL: `https://github.com/SEU-USUARIO/msitef_flutter.git`
   - Ref: `main`

## Passo 2: Configurar o AndroidManifest.xml

1. Vá em **Custom Code > Configuration Files**
2. Selecione `AndroidManifest.xml`
3. Adicione o snippet de queries (veja seção acima)

## Passo 3: Criar Custom Action para Venda

1. Vá em **Custom Code > Actions**
2. Clique em **+ Add Action**
3. Nome: `realizarVendaTef`
4. Cole o código abaixo:

```dart
// Custom Action: realizarVendaTef
// Argumentos de entrada:
//   - valorCentavos (int) - Valor em centavos
//   - empresaSitef (String) - Código da empresa
//   - enderecoSitef (String) - IP do servidor
//   - cnpjCpf (String) - CNPJ do estabelecimento
// Retorno: JSON (String) com resultado da transação

import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarVendaTef(
  int valorCentavos,
  String empresaSitef,
  String enderecoSitef,
  String cnpjCpf,
) async {
  try {
    // Verifica se M-SiTef está instalado
    bool instalado = await MsitefFlutter.isInstalado();
    if (!instalado) {
      return jsonEncode({
        'sucesso': false,
        'erro': 'M-SiTef não está instalado no dispositivo'
      });
    }

    // Realiza a venda
    MsitefResponse response = await MsitefFlutter.venda(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
      operador: "0001",
    );

    // Retorna o resultado como JSON
    return jsonEncode({
      'sucesso': response.sucesso,
      'codResp': response.codResp,
      'mensagem': response.mensagem,
      'nsuHost': response.nsuHost,
      'nsuLocal': response.nsuLocal,
      'codAutorizacao': response.codAutorizacao,
      'bandeira': response.bandeira,
      'nomeCartao': response.nomeCartao,
      'tipoCartao': response.tipoCartao,
      'viaCliente': response.viaCliente,
      'viaEstabelecimento': response.viaEstabelecimento,
    });
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'erro': e.toString()
    });
  }
}
```

## Passo 4: Criar Custom Action para PIX

```dart
// Custom Action: realizarPixTef
import 'dart:convert';
import 'package:msitef_flutter/msitef_flutter.dart';

Future<String> realizarPixTef(
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
        'erro': 'M-SiTef não está instalado'
      });
    }

    MsitefResponse response = await MsitefFlutter.pix(
      empresaSitef: empresaSitef,
      enderecoSitef: enderecoSitef,
      cnpjCpf: cnpjCpf,
      valor: valorCentavos,
    );

    return jsonEncode(response.toMap());
  } catch (e) {
    return jsonEncode({
      'sucesso': false,
      'erro': e.toString()
    });
  }
}
```

## Passo 5: Criar Custom Action para Verificar Instalação

```dart
// Custom Action: verificarMsitefInstalado
import 'package:msitef_flutter/msitef_flutter.dart';

Future<bool> verificarMsitefInstalado() async {
  return await MsitefFlutter.isInstalado();
}
```

## Passo 6: Usar no Action Flow

1. No seu botão de pagamento, adicione uma **Action**
2. Selecione **Custom Action > realizarVendaTef**
3. Preencha os parâmetros:
   - `valorCentavos`: Use uma variável ou valor fixo
   - `empresaSitef`: Seu código de empresa
   - `enderecoSitef`: IP do servidor SiTef
   - `cnpjCpf`: CNPJ do estabelecimento
4. Capture o retorno em uma **Action Output Variable**
5. Use **Conditional Actions** para verificar o resultado

### Exemplo de Action Flow:

```
1. [Custom Action] verificarMsitefInstalado
   ↓
2. [Conditional] Se instalado == false
   → [Show Snackbar] "M-SiTef não instalado"
   → [Stop]
   ↓
3. [Custom Action] realizarVendaTef
   - valorCentavos: FFAppState().valorCarrinho
   - empresaSitef: "00000000"
   - enderecoSitef: "192.168.0.1"
   - cnpjCpf: "12345678901234"
   → Output: resultadoTef
   ↓
4. [Custom Function] parseJson(resultadoTef)
   ↓
5. [Conditional] Se sucesso == true
   → [Navigate] Tela de Sucesso
   → [Update State] limpar carrinho
   ↓
6. [Show Dialog] Erro: ${mensagem}
```

---

## Modalidades Disponíveis

| Modalidade | Código | Método |
|------------|--------|--------|
| Venda (todas formas) | 0 | `MsitefFlutter.venda()` |
| Débito | 2 | `MsitefFlutter.vendaDebito()` |
| Crédito | 3 | `MsitefFlutter.vendaCredito()` |
| PIX | 122 | `MsitefFlutter.pix()` |
| Menu Administrativo | 110 | `MsitefFlutter.menuAdministrativo()` |
| Reimpressão | 114 | `MsitefFlutter.reimpressao()` |
| Cancelamento | 200 | `MsitefFlutter.cancelamento()` |

## Tipos de Comunicação (comExterna)

| Valor | Descrição |
|-------|-----------|
| 0 | TLS Software Express (padrão) |
| 1 | TCP |
| 2 | Com Externa |
| 3 | GSurf |
| 4 | TLSGWP |

## Códigos de Resposta Comuns

| Código | Significado |
|--------|-------------|
| 0 | Transação aprovada |
| -1 | Erro genérico |
| 2 | Transação negada |
| 6 | Transação cancelada pelo operador |
| 9 | Erro de comunicação |

## Requisitos

- Android SDK 21+ (Android 5.0)
- M-SiTef instalado no dispositivo
- Servidor SiTef configurado

## Suporte

Para dúvidas sobre o M-SiTef, consulte a documentação oficial:
https://dev.softwareexpress.com.br/docs/m-sitef/

## Licença

MIT License
