import 'package:aewallet/application/connectivity_status.dart';
import 'package:aewallet/application/settings/settings.dart';
import 'package:aewallet/application/settings/version.dart';
import 'package:aewallet/model/available_language.dart';
import 'package:aewallet/ui/figma_components/buttons/btn_footer_primary.dart';
import 'package:aewallet/ui/figma_components/custom_styles.dart';
import 'package:aewallet/ui/themes/archethic_theme.dart';
import 'package:aewallet/ui/themes/styles.dart';
import 'package:aewallet/ui/views/intro/layouts/intro_import_seed.dart';
import 'package:aewallet/ui/views/intro/layouts/intro_new_wallet_get_first_infos.dart';
import 'package:aewallet/ui/widgets/components/sheet_skeleton.dart';
import 'package:aewallet/ui/widgets/components/sheet_skeleton_interface.dart';
import 'package:aewallet/ui/widgets/dialogs/environment_dialog.dart';
import 'package:archethic_dapp_framework_flutter/archethic_dapp_framework_flutter.dart'
    as aedappfm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class IntroWelcome extends ConsumerStatefulWidget {
  const IntroWelcome({super.key});

  static const routerPage = '/intro_welcome';
  @override
  ConsumerState<IntroWelcome> createState() => _IntroWelcomeState();
}

class _IntroWelcomeState extends ConsumerState<IntroWelcome>
    implements SheetSkeletonInterface {
  @override
  Widget build(BuildContext context) {
    return SheetSkeleton(
      appBar: getAppBar(context, ref),
      floatingActionButton: getFloatingActionButton(context, ref),
      sheetContent: getSheetContent(context, ref),
      backgroundImage: ArchethicTheme.backgroundWelcome,
    );
  }

  @override
  Widget getFloatingActionButton(BuildContext context, WidgetRef ref) {
    final connectivityStatusProvider = ref.watch(connectivityStatusProviders);
    return _Footer(
      isConnectivityAvailable:
          connectivityStatusProvider == ConnectivityStatus.isConnected,
    );
  }

  @override
  PreferredSizeWidget getAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      systemOverlayStyle: ArchethicTheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: const [
        LanguageToggleButton(),
      ],
    );
  }

  @override
  Widget getSheetContent(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 30,
                child: SvgPicture.asset(
                  '${ArchethicTheme.assetsFolder}Archethic - Logo.svg',
                  colorFilter:
                      ColorFilter.mode(ArchethicTheme.text, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({
    required this.isConnectivityAvailable,
  });

  final bool isConnectivityAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _ButtonNewWallet(),
        SizedBox(
          height: 10,
        ),
        _ButtonImportWallet(),
        SizedBox(
          height: 10,
        ),
        _VersionInfo(),
      ],
    );
  }
}

class _VersionInfo extends ConsumerWidget {
  const _VersionInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Consumer(
            builder: (context, ref, child) {
              final asyncVersionString = ref.watch(
                versionStringProvider(
                  AppLocalizations.of(context)!,
                ),
              );

              return Text(
                asyncVersionString.asData?.value ?? '',
                textAlign: TextAlign.left,
                style: ArchethicThemeStyles.textStyleSize10W100Primary,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ButtonNewWallet extends ConsumerWidget {
  const _ButtonNewWallet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return BtnFooterPrimary(
      buttonText: localizations.newWallet,
      onTap: () async {
        await ref
            .read(SettingsProviders.settings.notifier)
            .setEnvironment(aedappfm.Environment.mainnet);

        context.go(
          IntroNewWalletGetFirstInfos.routerPage,
        );
      },
      key: const Key('newWallet'),
    );
  }
}

class _ButtonImportWallet extends ConsumerWidget {
  const _ButtonImportWallet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return BtnFooterPrimary(
      buttonText: localizations.importWallet,
      onTap: () async {
        final environment = await context.push(EnvironmentDialog.routerPage);
        if (environment != null) {
          await ref
              .read(SettingsProviders.settings.notifier)
              .setEnvironment(environment as aedappfm.Environment);
        }
        context.go(IntroImportSeedPage.routerPage);
      },
      key: const Key('importWallet'),
      btnPrimaryType: BtnFooterPrimaryType.outlinePrimary,
    );
  }
}

class LanguageToggleButton extends ConsumerStatefulWidget {
  const LanguageToggleButton({
    super.key,
  });

  @override
  ConsumerState<LanguageToggleButton> createState() =>
      LanguageToggleButtonState();
}

class LanguageToggleButtonState extends ConsumerState<LanguageToggleButton> {
  bool isEnglishSelected = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context);
      setState(() {
        isEnglishSelected = locale.languageCode != 'fr';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 10),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isEnglishSelected = !isEnglishSelected;
          });

          if (isEnglishSelected) {
            await ref
                .read(SettingsProviders.settings.notifier)
                .selectLanguage(AvailableLanguage.english);
          } else {
            await ref
                .read(SettingsProviders.settings.notifier)
                .selectLanguage(AvailableLanguage.french);
          }
        },
        child: Container(
          width: 120,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF363346),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: isEnglishSelected ? 0 : 60,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: ArchethicGradients.gradientArchethic,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    localizations.languageEnglish,
                    style: isEnglishSelected
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .color!
                                  .withValues(alpha: 0.5),
                            ),
                  ),
                  Text(
                    localizations.languageFrancais,
                    style: !isEnglishSelected
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .color!
                                  .withValues(alpha: 0.5),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
