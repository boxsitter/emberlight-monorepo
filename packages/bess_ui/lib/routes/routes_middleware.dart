import 'package:bessie/data/repositories.authentication/authentication_repository.dart';
import 'package:bessie/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BessRouteMiddleware extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {
    return AuthenticationRepository.instance.isAuthenticated ? null : const RouteSettings(name: BessRoutes.login);
  }
}