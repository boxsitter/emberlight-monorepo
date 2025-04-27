import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../constants/enums.dart';

class BessHelperFunctions {
  static DateTime getStartOfWeek(DateTime date) {
    final int daysUntilMonday = date.weekday - 1;
    final DateTime startOfWeek = date.subtract(Duration(days: daysUntilMonday));
    return DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0, 0, 0);
  }

  static Color getOrderStatusColor(OrderStatus value) {
    if (OrderStatus.pending == value) {
      return Colors.blue;
    } else if (OrderStatus.processing == value) {
      return Colors.orange;
    } else if (OrderStatus.shipped == value) {
      return Colors.purple;
    } else if (OrderStatus.delivered == value) {
      return Colors.green;
    } else if (OrderStatus.cancelled == value) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static Color? getColor(String value) {
    /// Define your product specific colors here and it will match the attribute colors and show specific 🟠🟡🟢🔵🟣🟤

    if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Red') {
      return Colors.red;
    } else if (value == 'Blue') {
      return Colors.blue;
    } else if (value == 'Pink') {
      return Colors.pink;
    } else if (value == 'Grey') {
      return Colors.grey;
    } else if (value == 'Purple') {
      return Colors.purple;
    } else if (value == 'Black') {
      return Colors.black;
    } else if (value == 'White') {
      return Colors.white;
    } else if (value == 'Yellow') {
      return Colors.yellow;
    } else if (value == 'Orange') {
      return Colors.deepOrange;
    } else if (value == 'Brown') {
      return Colors.brown;
    } else if (value == 'Teal') {
      return Colors.teal;
    } else if (value == 'Indigo') {
      return Colors.indigo;
    } else {
      return null;
    }
  }

  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
          i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }

  static Map<V, K> transposeMap<K, V>(Map<K, V> originalMap) {
    final transposedMap = <V, K>{};
    originalMap.forEach((key, value) {
      // Be cautious: If the original map has duplicate values,
      // only the last key associated with that value will be kept in the transposed map.
      transposedMap[value] = key;
    });
    return transposedMap;
  }

  static Color blendColors(Color color1, Color color2, int alpha) {
    final int effectiveAlphaInt = alpha.clamp(0, 255);
    final double foregroundOpacity = effectiveAlphaInt / 255.0; // Opacity 0.0-1.0

    // Use the doubles directly, assuming they are [0.0, 1.0]
    final double backgroundAlpha = color1.a;
    final double backgroundRed = color1.r;
    final double backgroundGreen = color1.g;
    final double backgroundBlue = color1.b;

    final double foregroundRed = color2.r;
    final double foregroundGreen = color2.g;
    final double foregroundBlue = color2.b;

    // Blend using [0.0, 1.0] doubles
    final double resultRedNorm = foregroundRed * foregroundOpacity + backgroundRed * (1.0 - foregroundOpacity);
    final double resultGreenNorm = foregroundGreen * foregroundOpacity + backgroundGreen * (1.0 - foregroundOpacity);
    final double resultBlueNorm = foregroundBlue * foregroundOpacity + backgroundBlue * (1.0 - foregroundOpacity);
    final double resultAlphaNorm = foregroundOpacity + backgroundAlpha * (1.0 - foregroundOpacity);

    // Convert results [0.0, 1.0] back to ints [0, 255]
    final int resultAlphaInt = (resultAlphaNorm * 255.0).round().clamp(0, 255);
    final int resultRedInt = (resultRedNorm * 255.0).round().clamp(0, 255);
    final int resultGreenInt = (resultGreenNorm * 255.0).round().clamp(0, 255);
    final int resultBlueInt = (resultBlueNorm * 255.0).round().clamp(0, 255);

    // Construct color using ints
    return Color.fromARGB(
      resultAlphaInt,
      resultRedInt,
      resultGreenInt,
      resultBlueInt,
    );
  }
}
