/// Ember Core - The core logic and business layer for Emberlight software
///
/// This package contains the core business logic, data models, and service interfaces
/// for Emberlight software. It is completely platform-agnostic and does not directly
/// depend on any frontend or backend specific code. All backend operations are
/// abstracted within the backend repository layer.
///
/// Usage:
/// Import this package in your UI layer to access business logic and service methods.
library;

// Export any additional modules intended for public use.
export 'src/data/abstract/bess_object.dart';
export 'src/data/abstract/schedule_block.dart';

export 'src/data/bess_objects/dependent/cabin_in_use.dart';
export 'src/data/bess_objects/dependent/scheduled_activity.dart';

export 'src/data/bess_objects/domains/branch.dart';
export 'src/data/bess_objects/domains/session.dart';
export 'src/data/bess_objects/domains/organization.dart';
export 'src/data/bess_objects/domains/season.dart';

export 'src/data/bess_objects/principal/activity_type.dart';
export 'src/data/bess_objects/principal/branch_cabin.dart';

export 'src/data/bess_objects/assigned_multi_activity_block.dart';
export 'src/data/bess_objects/camper.dart';
export 'src/data/bess_objects/camper_preference.dart';
export 'src/data/bess_objects/schedule.dart';
export 'src/data/bess_objects/user.dart';

export 'src/exceptions/bess_exceptions.dart';
export 'src/exceptions/firebase_auth_exceptions.dart';
export 'src/exceptions/firebase_exceptions.dart';
export 'src/exceptions/format_exceptions.dart';
export 'src/exceptions/platform_exceptions.dart';
export 'src/exceptions/t_exceptions.dart';

export 'src/feature_utils/pdf_utils.dart';
export 'src/feature_utils/roster_utils.dart';

export 'src/services/activity_signup_service.dart';
export 'src/services/cabin_service.dart';
export 'src/services/client_context_service.dart';
export 'src/services/console_service.dart';
export 'src/services/database_repair_service.dart';
export 'src/services/deletion_service.dart';
export 'src/services/exception_handler_service.dart';
export 'src/services/logging_service.dart';
export 'src/services/path_service.dart';
export 'src/services/request_service.dart';
export 'src/services/schedule_service.dart';
export 'src/services/session_roster_service.dart';

export 'src/validators/bess_id_validation.dart';


void initializeEmberCore () {

}