import 'package:flutter/material.dart';
import '../../constants/styles.dart';

class FilledTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;

  const FilledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<FilledTextField> createState() => _FilledTextFieldState();
}

class _FilledTextFieldState extends State<FilledTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText ? _obscureText : false,
      decoration: InputDecoration(
        labelText: widget.label + (widget.required ? ' *' : ''),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '${widget.label}을(를) 입력해주세요.';
              }
              return null;
            }
          : null,
    );
  }
} 