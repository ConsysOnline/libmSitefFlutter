package br.com.consys.msitef_flutter

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class MsitefFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    
    companion object {
        private const val CHANNEL_NAME = "msitef_flutter"
        private const val MSITEF_REQUEST_CODE = 4321
        private const val MSITEF_ACTION = "br.com.softwareexpress.sitef.msitef.ACTIVITY_CLISITEF"
        private const val MSITEF_PACKAGE = "br.com.softwareexpress.sitef.msitef"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "executarTransacao" -> {
                if (activity == null) {
                    result.error("NO_ACTIVITY", "Activity não disponível", null)
                    return
                }
                
                if (pendingResult != null) {
                    result.error("BUSY", "Já existe uma transação em andamento", null)
                    return
                }
                
                pendingResult = result
                executarTransacao(call)
            }
            "isInstalado" -> {
                result.success(isMsitefInstalado())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun executarTransacao(call: MethodCall) {
        try {
            val intent = Intent(MSITEF_ACTION)
            
            // Parâmetros obrigatórios
            intent.putExtra("empresaSitef", call.argument<String>("empresaSitef") ?: "")
            intent.putExtra("enderecoSitef", call.argument<String>("enderecoSitef") ?: "")
            intent.putExtra("CNPJ_CPF", call.argument<String>("cnpjCpf") ?: "")
            intent.putExtra("modalidade", call.argument<String>("modalidade") ?: "0")
            
            // Argumentos para executar pagamento crédito a vista
            val tipoCartao = call.argument<String>("tipoCartao") ?: ""
            if (tipoCartao == "C") {
                intent.putExtra("numParcelas", "1")
                intent.putExtra("restricoes", "TransacoesHabilitadas=26")
            }

            // Argumentos para executar pagamento débito a vista
            val tipoCartao = call.argument<String>("tipoCartao") ?: ""
            if (tipoCartao == "D") {
                intent.putExtra("numParcelas", "1")
                intent.putExtra("restricoes", "TransacoesHabilitadas=16")
            }

            // Valor (em centavos, formato string)
            val valor = call.argument<String>("valor") ?: "0"
            intent.putExtra("valor", valor)
            
            // Parâmetros opcionais
            val operador = call.argument<String>("operador")
            if (!operador.isNullOrEmpty()) {
                intent.putExtra("operador", operador)
            }
            
            val numeroCupom = call.argument<String>("numeroCupom")
            if (!numeroCupom.isNullOrEmpty()) {
                intent.putExtra("numeroCupom", numeroCupom)
            }
            
            val comExterna = call.argument<String>("comExterna")
            if (!comExterna.isNullOrEmpty()) {
                intent.putExtra("comExterna", comExterna)
            }
            
            if (tipoCartao == "") {
                val restricoes = call.argument<String>("restricoes")
                if (!restricoes.isNullOrEmpty()) {
                    intent.putExtra("restricoes", restricoes)
                }
            }
            
            val isDoubleValidation = call.argument<String>("isDoubleValidation")
            if (isDoubleValidation == "1") {
                intent.putExtra("isDoubleValidation", "1")
            }
            
            val timeout = call.argument<String>("timeout")
            if (!timeout.isNullOrEmpty()) {
                intent.putExtra("timeout", timeout)
            }
            
            // Configurações adicionais comuns
            intent.putExtra("isExibeMenu", "1") // Exibe menu quando necessário
            
            // Verifica se o M-SiTef está instalado
            if (!isMsitefInstalado()) {
                pendingResult?.error("NOT_INSTALLED", "M-SiTef não está instalado no dispositivo", null)
                pendingResult = null
                return
            }
            
            activity?.startActivityForResult(intent, MSITEF_REQUEST_CODE)
            
        } catch (e: Exception) {
            pendingResult?.error("ERROR", "Erro ao iniciar M-SiTef: ${e.message}", null)
            pendingResult = null
        }
    }

    private fun isMsitefInstalado(): Boolean {
        return try {
            activity?.packageManager?.getPackageInfo(MSITEF_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            // Tenta verificar se consegue resolver o intent
            val intent = Intent(MSITEF_ACTION)
            val resolveInfo = activity?.packageManager?.resolveActivity(intent, 0)
            resolveInfo != null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != MSITEF_REQUEST_CODE) {
            return false
        }
        
        val result = pendingResult
        pendingResult = null
        
        if (result == null) {
            return true
        }
        
        if (data == null) {
            result.success(mapOf(
                "CODRESP" to "-1",
                "MENSAGEM" to "Transação cancelada ou sem resposta"
            ))
            return true
        }
        
        // Extrai todos os extras do Intent de retorno
        val response = mutableMapOf<String, Any?>()
        
        data.extras?.let { extras ->
            for (key in extras.keySet()) {
                response[key] = extras.get(key)?.toString()
            }
        }
        
        // Campos específicos do M-SiTef que sempre tentamos extrair
        val camposMsitef = listOf(
            "CODRESP", "MENSAGEM", "COMP_DADOS_CONF", "CODTRANS",
            "NSU_HOST", "NSU_SITEF", "COD_AUTORIZACAO",
            "BANDEIRA", "NOME_CARTAO", "TIPO_CARTAO",
            "VIA_CLIENTE", "VIA_ESTABELECIMENTO", "DATA_HORA",
            "VALOR", "PARCELAS", "REDE_AUT", "TIPO_PARC",
            "NUM_PARC", "DATA_TRANSACAO", "HORA_TRANSACAO",
            "CARTAO_BIN", "ULTIMOS_4_DIGITOS"
        )
        
        for (campo in camposMsitef) {
            if (!response.containsKey(campo)) {
                val valor = data.getStringExtra(campo)
                if (valor != null) {
                    response[campo] = valor
                }
            }
        }
        
        // Se não tiver CODRESP, tenta inferir do resultCode
        if (!response.containsKey("CODRESP")) {
            response["CODRESP"] = if (resultCode == Activity.RESULT_OK) "0" else "-1"
        }
        
        if (!response.containsKey("MENSAGEM")) {
            response["MENSAGEM"] = if (resultCode == Activity.RESULT_OK) "Transação realizada" else "Transação não realizada"
        }
        
        result.success(response)
        return true
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
