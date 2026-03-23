import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'widgets/foodai_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.api,
    required this.auth,
    required this.onSignInRequested,
  });

  final ApiService api;
  final AuthService auth;
  final Future<void> Function() onSignInRequested;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  File? _image;
  ScanResponse? _result;
  bool _loading = false;
  String? _errorMessage;
  int _servings = 2;
  double _minConfidence = 0.7;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _image = File(file.path);
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _scan() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final data = await widget.api.scanImage(
        _image!,
        servings: _servings,
        minConfidence: _minConfidence,
      );
      setState(() {
        _result = data;
        _errorMessage = null;
      });
    } on DioException catch (error) {
      final detail = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['detail'] as String?)
          : null;
      setState(() {
        _errorMessage = detail ?? 'Impossible de contacter le serveur d’analyse.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('FoodAI Lab', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (!widget.auth.isLoggedIn)
          FoodAiCard(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Connecte-toi avec Google pour enregistrer ton historique, tes favoris et ton profil.',
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: widget.onSignInRequested,
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        if (!widget.auth.isLoggedIn) const SizedBox(height: 12),
        FoodAiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Scan un plat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              Text('Portions: $_servings'),
              Slider(
                value: _servings.toDouble(),
                min: 1,
                max: 8,
                divisions: 7,
                label: '$_servings',
                onChanged: (value) => setState(() => _servings = value.round()),
              ),
              Text('Seuil de confiance: ${_minConfidence.toStringAsFixed(2)}'),
              Slider(
                value: _minConfidence,
                min: 0.1,
                max: 0.95,
                divisions: 17,
                label: _minConfidence.toStringAsFixed(2),
                onChanged: (value) => setState(() => _minConfidence = value),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(ImageSource.camera),
                      child: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pick(ImageSource.gallery),
                      child: const Text('Galerie'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _scan,
                  child: Text(_loading ? 'Analyse...' : 'Lancer l\'analyse'),
                ),
              ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FoodAiCard(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          ),
        if (_result != null)
          FoodAiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Résultat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                if (_result!.warning != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_result!.warning!, style: const TextStyle(color: Colors.orangeAccent)),
                  ),
                const SizedBox(height: 8),
                ..._result!.predictions.map((p) => Text('${p.label} — ${(p.confidence * 100).toStringAsFixed(1)}%')),
                if (_result!.recipe != null) ...[
                  const SizedBox(height: 8),
                  Text('Recette: ${_result!.recipe!.name} (${_result!.recipe!.servings} portions)'),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
