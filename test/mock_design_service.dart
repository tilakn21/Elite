import 'package:mocktail/mocktail.dart';
import 'package:elite_signboard_app/Dashboards/Design/services/design_service.dart';
import 'package:elite_signboard_app/Dashboards/Design/models/user.dart';
import 'package:elite_signboard_app/Dashboards/Design/models/job.dart';
import 'package:elite_signboard_app/Dashboards/Design/models/chat.dart';

// Mock classes for models if they are used in DesignService method signatures
// and require specific mock behavior (e.g. if they have methods that are called).
// If they are just data containers, direct instantiation might be fine in tests.
class MockUser extends Mock implements User {}
class MockJob extends Mock implements Job {}
class MockChat extends Mock implements Chat {}

class MockDesignService extends Mock implements DesignService {}
