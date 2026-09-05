import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clients_repository.dart';
import '../models/client.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) => ClientsRepository());

final clientsProvider = StateNotifierProvider<ClientsNotifier, AsyncValue<List<Client>>>((ref) {
  return ClientsNotifier(ref.watch(clientsRepositoryProvider));
});

class ClientsNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientsRepository _repository;

  ClientsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      state = const AsyncValue.loading();
      final clients = await _repository.getClients();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStage(String clientId, String newStage) async {
    final previousState = state;
    try {
      // Atualização otimista
      state = state.whenData((clients) => clients.map((c) {
            if (c.id == clientId) {
              return Client(
                id: c.id,
                name: c.name,
                cpfOrCnpj: c.cpfOrCnpj,
                email: c.email,
                phone: c.phone,
                address: c.address,
                createdAt: c.createdAt,
                funnelStage: newStage,
              );
            }
            return c;
          }).toList());

      await _repository.updateClientStage(clientId, newStage);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}
