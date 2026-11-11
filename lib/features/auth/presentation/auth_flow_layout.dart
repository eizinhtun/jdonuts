part of 'auth_flow.dart';

mixin _AuthFlowLayout on _AuthFlowHost, _AuthFlowActions, _AuthFlowForms {
  Widget _buildScreen(BuildContext context) {
    final registrationSteps = ['phone', 'otp', 'name', 'dob'];
    final stepIndex = registrationSteps.indexOf(widget.step).clamp(0, 3);
    final phoneError = _phoneBlurred
        ? _validationMessage(validatePhone(_phone.text))
        : null;
    final referenceLayout = _useReferenceAuthLayout;
    final phoneLayout = referenceLayout && widget.step == 'phone';
    final contentLeft = phoneLayout ? 40.0 : 36.0;
    final contentRight = phoneLayout ? 30.0 : 36.0;
    return Scaffold(
      backgroundColor: AppColors.palePink,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: referenceLayout ? null : AppColors.palePink,
          gradient: referenceLayout
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFEFF5),
                    Color(0xFFFFFAFC),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0, .58, 1],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: referenceLayout ? contentLeft : AppSpace.md,
                  right: referenceLayout ? contentRight : AppSpace.md,
                  top: referenceLayout ? 5 : AppSpace.sm,
                  bottom: referenceLayout ? 5 : AppSpace.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 24,
                      constraints: referenceLayout
                          ? const BoxConstraints.tightFor(width: 44, height: 44)
                          : null,
                      padding: EdgeInsets.zero,
                      style: referenceLayout
                          ? IconButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.ink,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          : null,
                    ),
                    const Spacer(),
                    if (_isRegistration)
                      _ProgressIndicator(
                        progress: (stepIndex + 1) / 4,
                        done: widget.step == 'dob',
                        compact: referenceLayout,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      referenceLayout ? contentLeft : 24,
                      referenceLayout ? 30 : 20,
                      referenceLayout ? contentRight : 24,
                      referenceLayout ? 57 : 14,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            (constraints.maxHeight -
                                    (referenceLayout ? 87 : 34))
                                .clamp(0.0, double.infinity),
                      ),
                      child: IntrinsicHeight(
                        child: AnimatedSwitcher(
                          duration: Motion.duration(context, Motion.standard),
                          switchInCurve: Motion.curve,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
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
