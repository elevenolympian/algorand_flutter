import 'package:algorand_flutter/blocs/app_bloc.dart';
import 'package:algorand_flutter/blocs/app_event.dart';
import 'package:algorand_flutter/blocs/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    final s = appBloc.state as SettingsState;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () { appBloc.add(Back());},
          ),
            title: Text('Settings')),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(s.address),
                    subtitle: Text('Address'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Import Seed'),
                    onTap: () { appBloc.add(ShowImportSeed());},
                  ),
                  Divider(),
                ],
              ),
            )
          ],
        ));
  }
}
