import 'package:bessie/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConstRouteMiddleware extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {
    print('MIDDLEWARE CALLED');
    const isAuthenticated = true;
    return isAuthenticated ? null : const RouteSettings(name: BessRoutes.home);
  }
}