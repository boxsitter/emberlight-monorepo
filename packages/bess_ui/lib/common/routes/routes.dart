class BessRoutes {
  static const home = '/';

  //static const secondScreen = '/second-screen';
  //static const secondScreenWithUID = '/second-screen/:userId';
  static const responsiveDesignExample = '/responsive-design/';
  static const console = '/console';
  static const sessionRoster = '/session-roster';

  static const activityPreferencesCabins = '/activity-preferences-cabins';
  static const activityPreferencesCampers = '/activity-preferences-campers';

  static List sideMenuItems = [
    console,
    sessionRoster,
    home,
    responsiveDesignExample
  ];

  static const login = '/login';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';
}
