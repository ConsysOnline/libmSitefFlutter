# 🚀 Guia Passo a Passo: M-SiTef no FlutterFlow

## Visão Geral

Este guia mostra como integrar pagamentos TEF (M-SiTef) no seu app FlutterFlow **sem precisar compilar localmente**.

---

## PARTE 1: Publicar o Plugin no GitHub

### Passo 1.1: Criar Repositório no GitHub

1. Acesse https://github.com/new
2. Nome do repositório: `msitef_flutter`
3. Deixe como **Public** (ou Private se preferir)
4. Clique em **Create repository**

### Passo 1.2: Fazer Upload dos Arquivos

**Opção A: Via interface web**
1. Clique em "uploading an existing file"
2. Arraste a pasta `msitef_flutter` descompactada
3. Commit: "Initial commit"

**Opção B: Via Git**
```bash
cd msitef_flutter
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/msitef_flutter.git
git push -u origin main
```

---

## PARTE 2: Configurar no FlutterFlow

### Passo 2.1: Adicionar Dependência do Plugin

1. No FlutterFlow, vá em: **Settings** (⚙️) > **Project Dependencies**
2. Clique em **+ Add Dependency**
3. Selecione **From Git Repository**
4. Preencha:
   - **Repository URL**: `https://github.com/SEU-USUARIO/msitef_flutter.git`
   - **Branch/Tag**: `main`
   - **Path**: deixe vazio
5. Clique em **Add**

### Passo 2.2: Configurar AndroidManifest.xml

1. Vá em: **Custom Code** > **Configuration Files**
2. Selecione **AndroidManifest.xml**
3. Clique no 🔒 para desbloquear edição
4. Adicione dentro de `<manifest>`, ANTES de `<application>`:

```xml
<queries>
    <package android:name="br.com.softwareexpress.sitef.msitef" />
    <intent>
        <action android:name="br.com.softwareexpress.sitef.msitef.ACTIVITY_CLISITEF" />
    </intent>
</queries>
```

5. Salve as alterações

---

## PARTE 3: Criar Custom Actions

### Passo 3.1: Criar Action "verificarMsitefInstalado"

1. Vá em: **Custom Code** > **Actions**
2. Clique em **+ Add** > **Action**
3. Configure:
   - **Name**: `verificarMsitefInstalado`
   - **Return Type**: `bool`
   - **Arguments**: nenhum

4. Cole o código:

```dart
import 'package:msitef_flutter/msitef_flutter.dart';

Future<bool> verificarMsitefInstalado() async {
  return await MsitefFlutter.isInstalado();
}
```

5. Clique em **Save** e depois em **Compile**

### Passo 3.2: Criar Action "realizarVendaTef"

1. Clique em **+ Add** > **Action**
2. Configure:
   - **Name**: `realizarVendaTef`
   - **Return Type**: `String`
   
3. Adicione **Arguments**:
   | Nome | Tipo | Nullable |
   |------|------|----------|
   | valorCentavos | int | No |
   | empresaSitef | String | No |
   | enderecoSitef | String | No |
   | cnpjCpf | String | No |
   | operador | String | Yes |

4. Cole o código:

```dart
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
```

5. **Save** e **Compile**

---

## PARTE 4: Criar Custom Functions para Parsear JSON

### Passo 4.1: Criar Function "isTransacaoAprovada"

1. Vá em: **Custom Code** > **Functions**
2. Clique em **+ Add** > **Function**
3. Configure:
   - **Name**: `isTransacaoAprovada`
   - **Return Type**: `bool`
   - **Arguments**: `jsonString` (String)

4. Cole o código:

```dart
import 'dart:convert';

bool isTransacaoAprovada(String jsonString) {
  try {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['sucesso'] == true;
  } catch (e) {
    return false;
  }
}
```

### Passo 4.2: Criar Function "getMensagemTef"

1. **+ Add** > **Function**
2. Configure:
   - **Name**: `getMensagemTef`
   - **Return Type**: `String`
   - **Arguments**: `jsonString` (String)

```dart
import 'dart:convert';

String getMensagemTef(String jsonString) {
  try {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['mensagem']?.toString() ?? 'Erro desconhecido';
  } catch (e) {
    return 'Erro ao processar resposta';
  }
}
```

---

## PARTE 5: Usar no Action Flow

### Exemplo: Botão de Pagamento

1. Selecione seu botão de "Pagar"
2. Adicione as Actions:

```
┌─────────────────────────────────────────┐
│ 1. Custom Action                        │
│    verificarMsitefInstalado             │
│    → Output: instalado                  │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 2. Conditional Actions                  │
│    IF: instalado == false               │
│    THEN:                                │
│      → Show Snackbar: "Instale o        │
│        M-SiTef para continuar"          │
│      → Terminate                        │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 3. Custom Action                        │
│    realizarVendaTef                     │
│    Parameters:                          │
│      - valorCentavos: [sua variável]    │
│      - empresaSitef: "00000000"         │
│      - enderecoSitef: "192.168.0.1"     │
│      - cnpjCpf: "12345678901234"        │
│      - operador: "0001"                 │
│    → Output: resultadoJson              │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ 4. Conditional Actions                  │
│    IF: isTransacaoAprovada(resultadoJson)│
│    THEN:                                │
│      → Show Dialog: "Pagamento OK!"     │
│      → Navigate to: SuccessPage         │
│    ELSE:                                │
│      → Show Dialog: getMensagemTef(     │
│          resultadoJson)                 │
└─────────────────────────────────────────┘
```

---

## PARTE 6: Configurações do Terminal

### Parâmetros que você precisa obter:

| Parâmetro | Descrição | Exemplo |
|-----------|-----------|---------|
| empresaSitef | Código da empresa no SiTef | "00000000" |
| enderecoSitef | IP do servidor SiTef | "192.168.0.100" |
| cnpjCpf | CNPJ do estabelecimento | "12345678000199" |

> ⚠️ Esses dados são fornecidos pela Software Express quando você contrata o serviço.

---

## PARTE 7: Testar

### No SK210 da Gertec:

1. Instale o M-SiTef no terminal (APK fornecido pela Software Express)
2. Configure o M-SiTef com os dados do servidor
3. Faça o build do seu app FlutterFlow
4. Instale no terminal
5. Teste uma venda!

### Debug:

Se algo não funcionar, verifique:
- [ ] M-SiTef está instalado?
- [ ] Servidor SiTef está acessível na rede?
- [ ] Dados de empresa/CNPJ estão corretos?
- [ ] Permissões de rede no AndroidManifest?

---

## Dúvidas Frequentes

**P: Posso testar no emulador?**
R: Não, você precisa do hardware físico com M-SiTef instalado.

**P: Funciona com outros terminais além do SK210?**
R: Sim! Qualquer terminal Android que rode M-SiTef.

**P: Como obtenho o M-SiTef?**
R: Entre em contato com a Software Express: https://softwareexpress.com.br

**P: Posso usar em produção?**
R: Sim, após homologação com a Software Express.

---

## Suporte

- Documentação M-SiTef: https://dev.softwareexpress.com.br/docs/m-sitef/
- FlutterFlow Docs: https://docs.flutterflow.io/

---

✅ **Pronto!** Agora você tem pagamentos TEF no seu app FlutterFlow!
