import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/a1111_api.dart';
import '../widgets/build_interface.dart';

class Img2ImgTab extends StatefulWidget {
  const Img2ImgTab({super.key});

  @override
  State<Img2ImgTab> createState() => _Img2ImgTabState();
}

class _Img2ImgTabState extends State<Img2ImgTab> {
  double _steps = 20;
  double _denoisingStrength = 0.6465;
  String _modeloSelecionado = 'modelo_estilos';

  static const Map<String, String> modelosDisponiveis = {
    'modelo_original': 'modelo_bordadoCasteloBranco.safetensors [963c5aa9aa]',
    'modelo_melhores': 'modelo_melhores.safetensors [bf0b0ccefd]',
    'modelo_estilos': 'modelo_style.safetensors [6d0e871e03]',
  };

  final TextEditingController _promptPositivoController = TextEditingController();
  final TextEditingController _promptNegativoController = TextEditingController();
  String _imageUrl = '';
  String? _base64Image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _ultimoJsonEnviado;

  Future<void> _selecionarImagem() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _gerarImagem() async {
    if (_base64Image == null) return;

    setState(() {
      _isLoading = true;
      _imageUrl = '';
    });

    try {
      final base64Img = await A1111Api.gerarImagemImg2Img(
        prompt: _promptPositivoController.text,
        negativePrompt: _promptNegativoController.text,
        modelo: modelosDisponiveis[_modeloSelecionado]!,
        base64Image: _base64Image!,
        steps: _steps.round(),
        denoisingStrength: _denoisingStrength,
      );
      setState(() => _imageUrl = base64Img!);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxImageSize = screenWidth < 500 ? screenWidth * 0.8 : 400;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BuildInterface(
            isLoading: _isLoading,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 20, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _modeloSelecionado,
                      decoration: InputDecoration(
                        labelText: 'Selecione o Modelo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: modelosDisponiveis.keys.map((String nome) {
                        return DropdownMenuItem<String>(
                          value: nome,
                          child: Text(nome),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _modeloSelecionado = newValue!;
                        });
                      },
                    ),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(
                            text: 'Aqui vai poder escolher o modelo a ser utilizado, tendo as seguintes opções\n\n'
                                '• modelo_original - Primeira versão do modelo\n'
                                '• modelo_melhores - Segunda versão do modelo treinado apenas com as melhores imagens\n'
                                '• modelo_estilos - Última versão com aprendizagem baseada no estilo\n\n',
                          ),
                          TextSpan(
                            text: 'NOTA: ',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'A troca de modelos pode aumentar o tempo necessário para a geração da imagem devido ao carregamento dos novos pesos \n',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_base64Image == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5),
                  child: ElevatedButton(
                    onPressed: _selecionarImagem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2E5E),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Selecionar Imagem Base'),
                  ),
                ),
              if (_base64Image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: maxImageSize,
                            maxHeight: maxImageSize,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.memory(
                              base64Decode(_base64Image!),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _selecionarImagem,
                        child: const Text('Trocar Imagem Base'),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número de passos (steps)',
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Slider(
                        value: _steps,
                        min: 20,
                        max: 100,
                        divisions: 75,
                        label: _steps.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _steps = value;
                          });
                        },
                        activeColor: Color(0xFFC5A02B),
                        inactiveColor: Colors.grey[300]
                    ),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: 'Número de passos: ${_steps.round()}\n',
                          ),
                          TextSpan(
                            text: 'NOTA: ',
                            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Quanto maior o número de passos, maior o tempo necessário para a geração',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Presença do Bordado de Castelo Branco',
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Slider(
                        value: _denoisingStrength,
                        min: 0.50,
                        max: 0.75,
                        divisions: 10000,
                        label: _denoisingStrength.toStringAsFixed(3),
                        onChanged: (double value) {
                          setState(() {
                            _denoisingStrength = value;
                          });
                        },
                        activeColor: Color(0xFFC5A02B),
                        inactiveColor: Colors.grey[300]
                    ),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: 'Valor: ${_denoisingStrength.toStringAsFixed(3)}\n',
                          ),
                          TextSpan(
                            text: 'NOTA: ',
                            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Quanto maior, mais o resultado se parece com um bordado e menos com a imagem original.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_imageUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxImageSize,
                        maxHeight: maxImageSize,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.memory(
                          base64Decode(_imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _imageUrl = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2E5E),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Nova imagem'),
                  ),
                ],
              ),
            ),
          ],
          if (_imageUrl.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _gerarImagem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2E5E),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Processar Imagem'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptPositivoController.dispose();
    _promptNegativoController.dispose();
    super.dispose();
  }
}
