
class BessRoutes {
  static const home = '/';
  static const secondScreen = '/second-screen';
  static const secondScreenWithUID = '/second-screen/:userId';
  static const responsiveDesignExample = '/responsive-design/';

  static List sideMenuItems = [
    home,
    secondScreen,
    responsiveDesignExample
  ];

  static const login = '/login';
  static const forgotPassword  = '/forgotPassword';
  static const resetPassword  = '/resetPassword';

  static const settings = '/settings';

  static const sessionManager = '/sessionManager';
  static const sessionRoster = '/sessionRoster';
}