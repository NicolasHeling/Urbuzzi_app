import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clients_repository.dart';
import '../models/client.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) => ClientsRepository());

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final repository = ref.watch(clientsRepositoryProvider);
  return repository.getClients();
});

final createClientProvider = FutureProvider.family<Client, Client>((ref, client) async {
  final repository = ref.watch(clientsRepositoryProvider);
  return repository.createClient(client);
});
