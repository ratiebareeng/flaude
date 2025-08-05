import 'package:flutter/material.dart';

class ActionButton {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

class ExpandableFab extends StatefulWidget {
  final List<ActionButton> actions;
  final IconData icon;
  final Color? backgroundColor;

  const ExpandableFab({
    super.key,
    required this.actions,
    this.icon = Icons.add,
    this.backgroundColor,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56 + (widget.actions.length * 56.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...widget.actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;

            return ScaleTransition(
              scale: _expandAnimation,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 8,
                  top: index == 0 ? 8 : 0,
                ),
                child: FloatingActionButton.small(
                  onPressed: () {
                    action.onPressed();
                    _toggle();
                  },
                  heroTag: action.label,
                  child: Icon(action.icon),
                ),
              ),
            );
          }),
          FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: widget.backgroundColor,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(widget.icon),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
}
