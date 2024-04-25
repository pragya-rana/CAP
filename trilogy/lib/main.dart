import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:trilogy/admin_approvals.dart';
import 'package:trilogy/admin_find_partnerships.dart';
import 'package:trilogy/admin_partner_info.dart';
import 'package:trilogy/admin_settings.dart';
import 'package:trilogy/admin_tab_bar.dart';
=======
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:trilogy/authentication/log_in.dart';
import 'package:trilogy/all/pdf_viewer.dart';
import 'package:trilogy/providers/chats_provider.dart';
import 'package:trilogy/providers/models_provider.dart';
import 'package:firebase_core/firebase_core.dart';
>>>>>>> Stashed changes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return MaterialApp(
        title: 'Flutter Demo',
=======
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
>>>>>>> Stashed changes
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
<<<<<<< Updated upstream
        home: AdminTabBar(
          currentPage: 0,
        ));
=======
        home: LoginPage(),
        // home: PDFViewer(),
      ),
    );
>>>>>>> Stashed changes
  }
}
