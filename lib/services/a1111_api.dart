import 'dart:convert';
import 'package:http/http.dart' as http;

class A1111Api {
  // Alterar para o IP do servidor
  static const String _baseUrl = 'http://10.6.18.249:7860/sdapi/v1';

  static Future<String?> gerarImagemTxt2Img({
    required String prompt,
    required String negativePrompt,
    required String modelo,
    double cfgScale = 10,
    int steps = 50,
    int width = 512,
    int height = 512,
    List<String> styles = const ["Bordado de Castelo Branco"],
  }) async {
    final jsonBody = {
      "prompt": prompt,
      "negative_prompt": negativePrompt,
      "steps": steps,
      "width": width,
      "height": height,
      "override_settings": {
        "sd_model_checkpoint": modelo,
      },
      "batch_size": 1,
      "sampler_name": "DPM++ 2M",
      "cfg_scale": cfgScale,
      "seed": -1,
      "styles": styles,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/txt2img'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(jsonBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['images'] != null && data['images'].isNotEmpty) {
        return data['images'][0]; // Base64 da imagem
      }
    }
    throw Exception('Erro ao gerar imagem: ${response.statusCode}');
  }

  static Future<String?> gerarImagemImg2Img({
    required String prompt,
    required String negativePrompt,
    required String modelo,
    required String base64Image,
    double cfgScale = 14,
    double denoisingStrength = 0.6465,
    int steps = 20,
    int width = 512,
    int height = 512,
    List<String> styles = const ["Bordado de Castelo Branco - img-to-img"],
  }) async {
    final jsonBody = {
      "prompt": prompt,
      "negative_prompt": negativePrompt,
      "steps": steps,
      "width": width,
      "height": height,
      "cfg_scale": cfgScale,
      "sampler_name": "DPM++ 2M",
      "restore_faces": true,
      "init_images": [base64Image],
      "denoising_strength": denoisingStrength,
      "override_settings": {
        "sd_model_checkpoint": modelo,
      },
      "styles": styles,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/img2img'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(jsonBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['images'] != null && data['images'].isNotEmpty) {
        return data['images'][0]; // Base64 da imagem
      }
    }
    throw Exception('Erro ao gerar imagem: ${response.statusCode}');
  }
}
