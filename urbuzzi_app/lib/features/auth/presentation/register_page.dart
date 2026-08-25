import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _doRegister() async {
    final success = await ref.read(authControllerProvider.notifier).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cadastro realizado com sucesso!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.green.shade800,
      ));
      Navigator.pushReplacementNamed(context, '/app'); // Roteia para o AppShell
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), backgroundColor: Colors.blue.shade50),
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Criar Conta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${authState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _doRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Já tem uma conta? Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
