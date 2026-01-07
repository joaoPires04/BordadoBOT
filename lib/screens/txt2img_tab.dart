import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/a1111_api.dart';
import '../widgets/build_interface.dart';

class Txt2ImgTab extends StatefulWidget {
  const Txt2ImgTab({super.key});

  @override
  State<Txt2ImgTab> createState() => _Txt2ImgTabState();
}

class _Txt2ImgTabState extends State<Txt2ImgTab> {
  final TextEditingController _promptPositivoController = TextEditingController();
  final TextEditingController _promptNegativoController = TextEditingController();
  String _imageUrl = '';
  String _modeloSelecionado = 'modelo_estilos';
  double _cfgScale = 7.0;
  bool _isLoading = false;
  String? _ultimoJsonEnviado;

  static const Map<String, String> modelosDisponiveis = {
    'modelo_original': 'modelo_bordadoCasteloBranco.safetensors [963c5aa9aa]',
    'modelo_melhores': 'modelo_melhores.safetensors [bf0b0ccefd]',
    'modelo_estilos': 'modelo_style.safetensors [6d0e871e03]',
  };

  Future<void> _gerarImagem() async {
    if (_promptPositivoController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _imageUrl = '';
    });

    try {
      final base64Img = await A1111Api.gerarImagemTxt2Img(
        prompt: _promptPositivoController.text,
        negativePrompt: _promptNegativoController.text,
        modelo: modelosDisponiveis[_modeloSelecionado]!,
        cfgScale: _cfgScale,
        steps: 50,
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                    items: modelosDisponiveis.keys
                        .map((String nome) => DropdownMenuItem<String>(
                      value: nome,
                      child: Text(nome),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _modeloSelecionado = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      children: [
                        TextSpan(
                          text:
                          'Aqui vai poder escolher o modelo a ser utilizado, tendo as seguintes opções\n\n'
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
                          text:
                          '• A troca de modelos pode aumentar o tempo necessário para a geração da imagem devido ao carregamento dos novos pesos \n\n'
                              '• O uso de prompts em inglês irá aumentar drasticamente a qualidade dos resultados \n',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildPromptField(
              'Prompt positivo',
              _promptPositivoController,
              "Aqui vai inserir o que deseja ver na imagem",
            ),
            const SizedBox(height: 16),
            _buildPromptField(
              'Prompt negativo',
              _promptNegativoController,
              "Aqui vai inserir o que não deseja ver na imagem",
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Quanta criatividade deve o modelo ter?',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _cfgScale = 12.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cfgScale == 12.0
                                ? const Color(0xFFC5A02B)
                                : Colors.grey[300],
                            foregroundColor: _cfgScale == 12.0
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Baixa',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.tight,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _cfgScale = 10.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cfgScale == 10.0
                                ? const Color(0xFFC5A02B)
                                : Colors.grey[300],
                            foregroundColor: _cfgScale == 10.0
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Média',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.tight,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _cfgScale = 7.0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cfgScale == 7.0
                                ? const Color(0xFFC5A02B)
                                : Colors.grey[300],
                            foregroundColor: _cfgScale == 7.0
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Alta',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_imageUrl.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _gerarImagem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2E5E),
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Gerar Imagem'),
            ),
          ),
        if (_imageUrl.isNotEmpty) ...[
          const SizedBox(height: 24),
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxImageSize,
                maxHeight: maxImageSize,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(
                    base64Decode(_imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _imageUrl = '';
                _ultimoJsonEnviado = null;
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
      ]),
    );
  }

  Widget _buildPromptField(
      String label,
      TextEditingController controller,
      String textoExplicativo,
      ) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              helperText: textoExplicativo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              helperStyle: GoogleFonts.montserrat(
                  fontSize: 12, color: Colors.grey[600]),
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
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
