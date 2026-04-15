import 'package:flutter/material.dart';

const List<IconData> taskListAvailableIcons = [
  Icons.list,
  Icons.work,
  Icons.school,
  Icons.person,
  Icons.home,
  Icons.fitness_center,
  Icons.shopping_cart,
  Icons.book,
  Icons.flight,
  Icons.download,
  Icons.favorite,
  Icons.music_note,
];

final Map<int, IconData> _taskListIconByCodePoint = {
  for (final icon in taskListAvailableIcons) icon.codePoint: icon,
};

IconData taskListIconFromCodePoint(int codePoint) {
  return _taskListIconByCodePoint[codePoint] ?? Icons.list;
}