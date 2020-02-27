import 'package:algorand_flutter/blocs/app_bloc.dart';
import 'package:algorand_flutter/blocs/app_event.dart';
import 'package:algorand_flutter/blocs/app_state.dart';
import 'package:algorand_flutter/ui/send_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manta_dart/messages.dart';
import 'package:algo_explorer_api/algo_explorer_api.dart';

import 'manta_sheet.dart';

class HomePage extends StatelessWidget {
  static GlobalKey sendKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);

    showSendSheet({int amount, String address}) async {
      if (sendKey.currentWidget != null) {
        return;
      }

      final result = await showModalBottomSheet(
          context: context,
          builder: (context) => BlocProvider.value(
              value: appBloc,
              child: SendSheet(
                key: sendKey,
                destAmount: amount,
                destAddress: address,
              )));

      // This is not the best as breaking logic of events to change state
      appBloc.add(AppSendSheetDismissed());
    }

    showMantaSheet({Merchant merchant, Destination destination}) async {
      final result = await showModalBottomSheet(
          context: context,
          builder: (context) => BlocProvider.value(
              value: appBloc,
              child: MantaSheet(
                destination: destination,
                merchant: merchant,
              )));

      // This is not the best as breaking logic of
      appBloc.add(AppMantaSheetDismissed());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Algorand'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                appBloc.add(AppSettingsShow());
              },
            )
          ],
        ),
        body: BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppHomeInitial) {
              // Ensure we are on InitialAppState
              Navigator.popUntil(context, (route) => route.isFirst);
            }

            if (state is AppHomeSendSheet) {
              showSendSheet(
                  amount: state.destAmount, address: state.destAddress);
            }

            if (state is AppHomeMantaSheet) {
              showMantaSheet(
                  merchant: state.merchant, destination: state.destination);
            }
          },
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text((appBloc.state as AppHome).balance.toString()),
                  assetDropdown(
                      current: (appBloc.state as AppHome).currentAsset,
                      assets: (appBloc.state as AppHome).assets,
                      onChanged: (value) {
                        appBloc.add(AppAssetChanged(value));
                      })
                ]),
          )),
              ),
              Expanded(
            child: transactionList(
                onRefresh: () =>
                    appBloc.addAsync(AppTransactionsUpdate()),
                address: appBloc.state.base.account.address,
                transactions: (appBloc.state as AppHome).transactions)),
              Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: const Text('SEND'),
            onPressed: () {
              appBloc.add(AppSendSheetShow());
            },
          ),
              )
            ]),
        ));
  }
}

assetDropdown(
    {int current,
    Map<String, int> assets,
    void Function(int value) onChanged}) {
  return DropdownButton<int>(
      hint: Text('Select currency'),
      value: current,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      items: assets.keys
          .map((e) => DropdownMenuItem(
                value: assets[e],
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged);
}

transactionList(
    {List transactions, String address, Future<void> Function() onRefresh}) {
  transactions = transactions.reversed.toList();

  final pts = transactions.whereType<TransactionPay>();
  final apts = transactions.whereType<TransactionAssetTransfer>();

  final listIter = pts.map((entry) => transactionEntry(
      destination: entry.to,
      amount: entry.amount,
      sent: entry.to != address,
      index: entry.index));

  final aListIter = apts.map((entry) => transactionEntry(
      destination: entry.to,
      amount: entry.amount,
      sent: entry.to != address,
      index: entry.index));

  final entries = listIter.toList();
  entries.addAll(aListIter);

  return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: entries,
      ));
}

Widget transactionEntry(
    {String destination, int amount, bool sent, int index}) {
  return Card(
      child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Column(
        children: <Widget>[
          Text(index.toString()),
          Text(
            sent ? 'Sent' : 'Received',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            amount.toString(),
          ),
        ],
      ),
      Flexible(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(destination, overflow: TextOverflow.ellipsis,),
      ))
    ],
  ));
}
