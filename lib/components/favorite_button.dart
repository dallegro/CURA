// favorite_button.dart

import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onPressed;

  const FavoriteButton(
      {Key? key, required this.isFavorited, required this.onPressed})
      : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.isFavorited ? Icons.favorite : Icons.favorite_border,
        color: widget.isFavorited ? Colors.red : null,
      ),
      onPressed: widget.onPressed,
    );
  }
}
