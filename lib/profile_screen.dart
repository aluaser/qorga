import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _oldPasswordFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String? _userId;
  final String _baseUrl = "http://localhost:5000";

  bool _isLoading = false;
  bool _isDataLoaded = false;
  bool _isPasswordSectionVisible = false;

  bool _isOldPasswordObscured = true;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _oldPasswordController.dispose();
    _oldPasswordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userId = prefs.getString('userId');
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _isLoading = false;
      _isDataLoaded = true;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userId == null) {
      _showSnackBar("Барлық өрістерді тексеріңіз.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse("$_baseUrl/user/$_userId");
    final body = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
    };

    if (_passwordController.text.isNotEmpty) {
      body["password"] = _passwordController.text;
      body["oldPassword"] = _oldPasswordController.text;
    }

    try {
      final res = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', responseData['user']['name'] ?? '');
        await prefs.setString('email', responseData['user']['email'] ?? '');

        if (!mounted) return;
        _showSnackBar("Профиль сәтті жаңартылды!", isError: false);
        _passwordController.clear();
        _oldPasswordController.clear();
        _confirmPasswordController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _isPasswordSectionVisible = false;
          _isPasswordObscured = true;
          _isOldPasswordObscured = true;
          _isConfirmPasswordObscured = true; 
        });
      } else {
        _showSnackBar(responseData['message'] ?? "Жаңарту мүмкін болмады",
            isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Серверге қосылу қатесі.", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('name');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      String? Function(String?)? validator,
      FocusNode? focusNode,
      Widget? suffixIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        focusNode: focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Профильді өзгерту",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: _updateProfile,
                ),
        ],
      ),
      body: _isDataLoaded
          ? Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: "Аты",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Атыңызды енгізіңіз";
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return "Дұрыс email енгізіңіз";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isPasswordSectionVisible)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Құпия сөзді өзгерту",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _oldPasswordController,
                          label: "Ескі құпия сөз",
                          obscureText: _isOldPasswordObscured,
                          focusNode: _oldPasswordFocusNode,
                          validator: (value) {
                            if (_passwordController.text.isNotEmpty &&
                                (value == null || value.isEmpty)) {
                              return "Ескі құпия сөзді енгізіңіз";
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isOldPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isOldPasswordObscured =
                                    !_isOldPasswordObscured;
                              });
                            },
                          ),
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          label: "Жаңа құпия сөз",
                          obscureText: _isPasswordObscured,
                          focusNode: _passwordFocusNode,
                          validator: (value) {
                            if (_oldPasswordController.text.isNotEmpty) {
                              if (value == null || value.isEmpty) {
                                return "Жаңа құпия сөзді енгізіңіз";
                              }
                              if (value.length < 6) {
                                return "Кемінде 6 таңба болуы керек";
                              }
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                              });
                            },
                          ),
                        ),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: "Жаңа құпия сөзді растаңыз",
                          obscureText: _isConfirmPasswordObscured,
                          focusNode: _confirmPasswordFocusNode,
                          validator: (value) {
                            if (_passwordController.text.isNotEmpty) {
                              if (value == null || value.isEmpty) {
                                return "Құпия сөзді растаңыз";
                              }
                              if (value != _passwordController.text) {
                                return "Құпия сөздер сәйкес келмейді";
                              }
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordObscured =
                                    !_isConfirmPasswordObscured;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            "Жаңа құпия сөзіңіз кемінде 6 таңбадан тұруы керек.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                        ),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            alignment: Alignment.centerLeft,
                            foregroundColor: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            _isPasswordSectionVisible = true;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _oldPasswordFocusNode.requestFocus();
                          });
                        },
                        child: const Text(
                          "Құпия сөзді өзгерту...",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 48), 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                        ),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent, 
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: _logout, 
                        child: const Text(
                          "Шығу", 
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.redAccent, 
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), 
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}


