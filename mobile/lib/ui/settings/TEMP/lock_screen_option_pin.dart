import "package:flutter/material.dart";
import "package:photos/theme/ente_theme.dart";
import "package:photos/ui/components/buttons/button_widget.dart";
import "package:photos/ui/components/buttons/icon_button_widget.dart";
import "package:photos/ui/components/models/button_type.dart";
import "package:photos/ui/settings/TEMP/lock_screen_option_confirm_pin.dart";
import "package:pinput/pin_put/pin_put.dart";

class LockScreenOptionPin extends StatefulWidget {
  const LockScreenOptionPin({
    super.key,
    this.isAuthenticating = false,
    this.authPin,
  });

  final bool isAuthenticating;
  final String? authPin;
  @override
  State<LockScreenOptionPin> createState() => _LockScreenOptionPinState();
}

class _LockScreenOptionPinState extends State<LockScreenOptionPin> {
  final _pinController = TextEditingController(text: null);
  String _code = "";
  final _focusNode = FocusNode();

  final _pinPutDecoration = BoxDecoration(
    border: Border.all(color: const Color.fromRGBO(45, 194, 98, 1.0)),
    borderRadius: BorderRadius.circular(15.0),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
    _focusNode.dispose();
  }

  Future<bool> confirmPinAuth(String code) async {
    if (widget.authPin == code) {
      Navigator.of(context).pop(true);
      return true;
    }
    Navigator.of(context).pop(false);
    return false;
  }

  Future<void> _confirmPin(String code) async {
    if (widget.isAuthenticating) {
      await confirmPinAuth(code);
      return;
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              LockScreenOptionConfirmPin(pin: code),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = getEnteColorScheme(context);
    final textTheme = getEnteTextTheme(context);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 120,
            ),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 75,
                      width: 75,
                      child: ValueListenableBuilder(
                        valueListenable: _pinController,
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            backgroundColor: colorTheme.fillStrong,
                            value: _pinController.text.length / 4,
                            color: colorTheme.primary400,
                            strokeWidth: 1.5,
                          );
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IconButtonWidget(
                      size: 30,
                      icon: Icons.lock_outline,
                      iconButtonType: IconButtonType.primary,
                      iconColor: colorTheme.tabIcon,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.isAuthenticating
                  ? 'Enter the pin to change Lockscreen settings.'
                  : 'Enter the pin to lock the app',
              style: textTheme.bodyBold,
            ),
            const Padding(padding: EdgeInsets.all(12)),
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
              child: PinPut(
                focusNode: _focusNode,
                fieldsCount: 4,
                controller: _pinController,
                submittedFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                selectedFieldDecoration: _pinPutDecoration,
                followingFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: const Color.fromRGBO(45, 194, 98, 0.5),
                  ),
                ),
                inputDecoration: const InputDecoration(
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  counterText: '',
                ),
                textStyle: textTheme.h3,
                obscureText: '*',
                onChanged: (String pin) {
                  setState(() {
                    _code = pin;
                  });
                },
                onSubmit: (value) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ButtonWidget(
                labelText: 'Next',
                buttonType: _code.length == 4
                    ? ButtonType.primary
                    : ButtonType.secondary,
                buttonSize: ButtonSize.large,
                onTap: () => _confirmPin(_code),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}