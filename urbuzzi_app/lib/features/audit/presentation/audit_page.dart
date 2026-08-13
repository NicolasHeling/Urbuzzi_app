import 'package:flutter/material.dart';

class AuditPage extends StatelessWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico / Auditoria')),
      body: const Center(
        child: Text('Timeline de auditoria de alterações de status dos lotes'),
      ),
    );
  }
}
