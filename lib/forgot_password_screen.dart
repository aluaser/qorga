// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _sent = false;
  bool _loading = false;
  String? _msg;
  String? _testCode;

  bool _isNewPassObscured = true;
  bool _isConfirmPassObscured = true;

  final String _baseUrl = "http://localhost:5000"; 

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate() || _emailController.text.isEmpty) {
      return;
    }
    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _loading = true;
      _msg = null;
      _testCode = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && (data["ok"] == true || data["testCode"] != null)) {
        final codeFromServer = data["testCode"]?.toString();

        setState(() {
          _sent = true;
          _msg = "Код жіберілді ✅";
          if (codeFromServer != null && codeFromServer.isNotEmpty) {
            _testCode = codeFromServer;
          }
        });
      } else {
        setState(() {
          _msg = data["message"] ?? "Қате орын алды";
        });
      }
    } catch (e) {
      setState(() {
        _msg = "Серверге қосылу мүмкін болмады: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _msg = "Барлық өрістерді толтырыңыз");
      return;
    }
    
    if (_newPassController.text != _confirmPassController.text) {
      setState(() => _msg = "Құпия сөздер сәйкес келмейді");
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim();
    final pass = _newPassController.text.trim();

    setState(() {
      _loading = true;
      _msg = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": code,
          "newPassword": pass,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["ok"] == true) {
        setState(() {
          _msg = "Құпия сөз өзгертілді";
        });

        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          _msg = data["message"] ?? "Қате орын алды";
        });
      }
    } catch (e) {
      setState(() {
        _msg = "Серверге қосылу мүмкін болмады: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C50AF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Құпия сөзді ұмыттыңыз ба?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: _sent, 
                      validator: (value) {
                        if (value == null || !value.contains("@")) {
                          return "Дұрыс email енгізіңіз";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_sent) ...[
                      TextFormField(
                        controller: _codeController,
                        decoration: _buildInputDecoration("Код"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Код енгізіңіз";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPassController,
                        decoration: _buildInputDecoration("Жаңа құпия сөз")
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPassObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPassObscured = !_isNewPassObscured;
                              });
                            },
                          ),
                        ),
                        obscureText: _isNewPassObscured,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Кемінде 6 таңба болуы керек";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPassController,
                        decoration: _buildInputDecoration("Жаңа құпия сөзді растаңыз")
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPassObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPassObscured = !_isConfirmPassObscured;
                              });
                            },
                          ),
                        ),
                        obscureText: _isConfirmPassObscured,
                        validator: (value) {
                          if (value != _newPassController.text) {
                            return "Құпия сөздер сәйкес келмейді";
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_msg != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _msg!,
                        style: TextStyle(
                          color: _msg!.contains('✅') ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : _sent
                              ? _resetPassword
                              : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3E4FF),
                        foregroundColor: const Color(0xFF4C50AF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Color(0xFF4C50AF),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _sent ? "Құпия сөзді өзгерту" : "Код жіберу",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

