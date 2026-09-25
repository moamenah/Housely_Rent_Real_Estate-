import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// OTP entry as designed: six boxes, one focused (purple) at [code.length].
///
/// One *invisible* [TextField] sits on top of the boxes and owns focus, the
/// keyboard, paste and autofill; the boxes are pure decoration rendered from
/// [code], with a static caret standing in for the real (transparent) one —
/// a permanently visible caret would also mean a repeating animation, which
/// keeps `pumpAndSettle()` from ever settling in tests.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.code,
    required this.length,
    required this.onChanged,
  });

  /// Digits committed so far (never longer than [length]).
  final String code;

  /// Box count — the design's `codeLength`.
  final int length;

  final ValueChanged<String> onChanged;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'otp_input');
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The box that would take the next digit — purple outline + caret.
    final activeIndex = _focused && widget.code.length < widget.length
        ? widget.code.length
        : -1;

    return Stack(
      children: [
        // Boxes first: the transparent input below paints nothing of its own,
        // so the digits stay visible while the input still receives taps.
        Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: _OtpBox(
                  digit: i < widget.code.length ? widget.code[i] : null,
                  active: i == activeIndex,
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: TextField(
            focusNode: _focusNode,
            autofocus: true,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [LengthLimitingTextInputFormatter(widget.length)],
            // Invisible: the boxes carry the visible value and caret.
            style: const TextStyle(color: Colors.transparent, fontSize: 24),
            cursorColor: Colors.transparent,
            // The theme fills text fields with the page color and draws
            // borders — both would hide the boxes painted underneath, so this
            // input opts out at every state.
            decoration: const InputDecoration(
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit, required this.active});

  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppDimensions.radiusLg),
        ),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: active ? 1.5 : AppDimensions.borderWidth,
        ),
      ),
      child: digit != null
          ? Text(
              digit!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            )
          : active
              ? Container(
                  width: 2,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.gray900,
                    borderRadius: BorderRadius.all(Radius.circular(1)),
                  ),
                )
              : null,
    );
  }
}
