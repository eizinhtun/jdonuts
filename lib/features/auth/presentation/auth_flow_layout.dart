part of 'auth_flow.dart';

mixin _AuthFlowLayout on _AuthFlowHost, _AuthFlowActions, _AuthFlowForms {
  Widget _buildScreen(BuildContext context) {
    final registrationSteps = ['phone', 'otp', 'name', 'dob'];
    final stepIndex = registrationSteps.indexOf(widget.step).clamp(0, 3);
    final phoneError = _phoneBlurred
        ? _validationMessage(validatePhone(_phone.text))
        : null;
    return Scaffold(
      backgroundColor: AppColors.palePink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  if (_isRegistration)
                    _ProgressIndicator(
                      progress: (stepIndex + 1) / 4,
                      done: widget.step == 'dob',
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 34).clamp(
                        0.0,
                        double.infinity,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: AnimatedSwitcher(
                        duration: Motion.duration(context, Motion.standard),
                        switchInCurve: Motion.curve,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(widget.step),
                          child: _buildStep(phoneError),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _legalFooter(context),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    switch (widget.step) {
      case 'phone':
        context.go('/onboarding');
      case 'otp':
        context.go('/auth/${widget.mode}/phone');
      case 'name':
        context.go('/auth/register/otp');
      case 'dob':
        context.go('/auth/register/name');
      default:
        context.go('/onboarding');
    }
  }
}
