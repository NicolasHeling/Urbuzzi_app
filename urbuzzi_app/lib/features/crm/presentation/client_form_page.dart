import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/client.dart';
import 'clients_provider.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Formatadores de Máscara
  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );
  
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  String _name = '';
  String _email = '';
  String _address = '';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // Pegamos o valor com ou sem máscara dependendo do que o backend espera.
        // Geralmente salvamos formatado ou apenas números. Aqui vamos salvar formatado para exibição.
        final cpfOrCnpj = _cpfCnpjFormatter.getMaskedText();
        final phone = _phoneFormatter.getMaskedText();

        final newClient = Client(
          id: '', // Backend gera o UUID
          name: _name,
          cpfOrCnpj: cpfOrCnpj,
          email: _email,
          phone: phone,
          address: _address,
          createdAt: DateTime.now(),
        );

        final repo = ref.read(clientsRepositoryProvider);
        await repo.createClient(newClient);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente criado com sucesso!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  onSaved: (val) => _name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'CPF', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfCnpjFormatter],
                  validator: (val) => val == null || val.length < 14 ? 'CPF inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'E-mail', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@') ? 'E-mail inválido' : null,
                  onSaved: (val) => _email = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Telefone (WhatsApp)', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  validator: (val) => val == null || val.length < 14 ? 'Telefone inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Endereço Completo', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onSaved: (val) => _address = val ?? '',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Salvar Cliente'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
