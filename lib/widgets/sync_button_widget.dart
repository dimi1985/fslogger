import 'package:flutter/material.dart';
import 'package:fslogger/utils/sync_data_service.dart';
import 'package:provider/provider.dart';

class SyncButtonWidget extends StatelessWidget {
  const SyncButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var syncService = Provider.of<SyncDataService>(context, listen: false);
        await syncService.fetchAircraftFromFirebase();
        await syncService.fetchFlightLogsFromFirebase();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synchronization complete')),
        );
      },
      child: const Text('Sync Data'),
    );
  }
}
