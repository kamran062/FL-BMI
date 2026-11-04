import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/coach/ai_client.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Explains what is sent before the first AI request. True if accepted.
Future<bool> ensureAiConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(AiClient.consentKey) == true) return true;
  if (!context.mounted) return false;
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l.aiConsentTitle),
      content: Text(l.aiConsentBody),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
        TextButton(onPressed: () => Navigator.pop(d, true), child: Text(l.aiAgree)),
      ],
    ),
  );
  if (ok == true) await prefs.setBool(AiClient.consentKey, true);
  return ok == true;
}

/// Chat with the AI coach (ROADMAP 4.5). The conversation lives only in
/// memory for this screen.
class CoachScreen extends StatefulWidget {
  final VoidCallback onBack;
  const CoachScreen({super.key, required this.onBack});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _turns = <ChatTurn>[];
  bool _waiting = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _waiting) return;
    if (!await ensureAiConsent(context) || !mounted) return;
    final l = context.l10n;
    final ai = context.read<AiClient>();
    final profile = AiClient.profileSummary(
      context.read<ProfileProvider>().profile,
      context.read<BodyProvider>().latestWeight?.weightKg,
    );
    setState(() {
      _turns.add((fromUser: true, text: text));
      _waiting = true;
      _input.clear();
    });
    _toBottom();
    String reply;
    try {
      reply = (await ai.ask(_turns, profile)).reply;
    } on AiLimitReached {
      reply = l.aiLimit;
      _turns.removeLast(); // keep the history valid for the next try
    } on AiUnavailable {
      reply = l.aiUnavailable;
      _turns.removeLast();
    }
    if (!mounted) return;
    setState(() {
      _turns.add((fromUser: false, text: reply));
      _waiting = false;
    });
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final bubble = isDark ? AppColors.darkBgSurface : AppColors.bgSunken;

    Widget msg(String text, bool fromUser) => Align(
          alignment: fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: fromUser ? brand : bubble,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(text,
                style: GoogleFonts.inter(
                    fontSize: 15, height: 1.4, color: fromUser ? Colors.white : null)),
          ),
        );

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: widget.onBack), title: Text(l.coachTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                msg(l.coachWelcome, false),
                for (final t in _turns) msg(t.text, t.fromUser),
                if (_waiting) msg(l.coachThinking, false),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    maxLength: 1000,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(hintText: l.coachHint, counterText: ''),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  tooltip: l.coachHint,
                  icon: Icon(Icons.send_rounded, color: brand),
                  onPressed: _waiting ? null : _send,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
