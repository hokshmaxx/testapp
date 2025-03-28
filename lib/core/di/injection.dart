import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/task/data/datasources/task_remote_data_source.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/create_task.dart';
import '../../features/task/domain/usecases/delete_task.dart';
import '../../features/task/domain/usecases/get_tasks.dart';
import '../../features/task/domain/usecases/update_task.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../services/notification_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(FlutterLocalNotificationsPlugin());

  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerSingleton<SignIn>(SignIn(getIt<AuthRepository>()));
  getIt.registerSingleton<SignUp>(SignUp(getIt<AuthRepository>()));
  getIt.registerSingleton<SignOut>(SignOut(getIt<AuthRepository>()));

  getIt.registerSingleton<TaskRemoteDataSource>(
    TaskRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(getIt<TaskRemoteDataSource>()),
  );

  getIt.registerSingleton<GetTasks>(GetTasks(getIt<TaskRepository>()));
  getIt.registerSingleton<CreateTask>(CreateTask(getIt<TaskRepository>()));
  getIt.registerSingleton<UpdateTask>(UpdateTask(getIt<TaskRepository>()));
  getIt.registerSingleton<DeleteTask>(DeleteTask(getIt<TaskRepository>()));

  getIt.registerSingleton<NotificationService>(
    NotificationService(
      getIt<FirebaseMessaging>(),
      getIt<FlutterLocalNotificationsPlugin>(),
      getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: getIt<AuthRepository>(),
      signIn: getIt<SignIn>(),
      signUp: getIt<SignUp>(),
      signOut: getIt<SignOut>(),
    ),
  );

  getIt.registerFactory<TaskBloc>(
    () => TaskBloc(
      getTasks: getIt<GetTasks>(),
      createTask: getIt<CreateTask>(),
      updateTask: getIt<UpdateTask>(),
      deleteTask: getIt<DeleteTask>(),
      notificationService: getIt<NotificationService>(),
    ),
  );
} 