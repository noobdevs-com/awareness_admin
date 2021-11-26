import 'package:flutter/material.dart';

const kTextFieldDecoration = InputDecoration(
  labelStyle: TextStyle(color: Color(0xFF29357c)),
  hintStyle: TextStyle(color: Colors.grey),
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF29357c), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
);
