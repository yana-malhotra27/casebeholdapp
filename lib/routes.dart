import 'package:casebehold/presentation/pages/auth/login_page.dart';
import 'package:casebehold/presentation/pages/auth/role_selection_page.dart';
import 'package:casebehold/presentation/pages/post_case/post_case_form.dart';
import 'package:flutter/material.dart';
import 'presentation/pages/home/user_home_page.dart';
import 'presentation/pages/home/lawyer_home_page.dart';
import 'presentation/pages/home/influencer_home_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginPage(),
  '/role-selection': (context) => const RoleSelectionPage(),
  '/user-home': (context) => const UserHomePage(),       // ✅ Add this
  '/lawyer-home': (context) => const LawyerHomePage(),   // (for later)
  '/influencer-home': (context) => const InfluencerHomePage(), // (for later)
  '/post-case': (context) => const PostCaseFormPage(),

};
