import 'package:algorand_flutter/blocs/utils.dart';

import 'app_event.dart';
import 'app_state.dart';
import 'mapper.dart';

class AppHomeInitialMapper with Mapper {
  Stream<AppState> mapAppHomeInitialToState(
      AppEvent event, AppHomeInitial state) async* {
    if (event is AppAccountInfoUpdated) {
      yield* _mapAccountInfoUpdateToState(event, state);
    } else if (event is AppAssetChanged) {
      final asset = event.asset;

      await this.appBloc.txSubscription.cancel();

      appBloc.subscribeTX(
          address: state.base.account.address, asset: event.asset);

      yield state.copyWith(
          balance: getBalance(asset: asset, account: state.base.accountInfo),
          currentAsset: asset);
    } else if (event is AppTransactionsUpdated) {
      yield state.copyWith(transactions: event.transactions);
    } else if (event is AppSettingsShow) {
      yield AppSettings(base: state.base, pstate: state);
    } else if (event is AppSendSheetShow) {
      yield state.toSendSheet();
    } else if (event is AppReceiveSheetShow) {
      yield state.toReceiveSheet();
    } else if (event is AppReceiveSheetDismissed) {
      // Ignore: sheet has been already closed
    } else if (event is AppSendSheetDismissed) {
      // Ignore: sheet has been already closed
    } else if (event is AppMantaSheetDismissed) {
      // Ignore: sheet has been already closed
    } else if (event is AppTransactionsUpdate) {
      this.appBloc.updating.complete();
    } else {
      throw UnimplementedError('$event not handled in $state');
    }
  }

  Stream<AppState> _mapAccountInfoUpdateToState(
      AppAccountInfoUpdated event, AppHomeInitial state) async* {
    final assets = {'algo': -1};

    if (event.account.assets != null) {
      for (String index in event.account.assets.keys) {
        final assetInfo =
            await this.appBloc.repository.getAssetInformation(int.parse(index));
        assets[assetInfo.unitname] = int.parse(index);
      }
    }

    // assets.addAll(getAssets(event.account));
    final newBase = state.base.copyWith(accountInfo: event.account);

    yield state.copyWith(
        base: newBase,
        balance: getBalance(asset: state.currentAsset, account: event.account),
        assets: assets);
  }
}
