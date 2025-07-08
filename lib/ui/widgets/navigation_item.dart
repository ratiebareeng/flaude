import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  final bool drawerIsOpen;
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const NavigationItem(
      {super.key,
      required this.drawerIsOpen,
      required this.icon,
      required this.title,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: drawerIsOpen
          ? ListTile(
              leading: Icon(
                icon,
                color: isSelected ? Color(0xffbd5d3a) : Colors.grey[400],
                size: 20,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedTileColor: Color(0xFF2d2d2d),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: onTap,
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            )
          : Container(
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF2d2d2d) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? Color(0xffbd5d3a) : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
