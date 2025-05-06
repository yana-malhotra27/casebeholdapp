import 'package:casebehold/appflow/pages/auth/login_page.dart';
import 'package:casebehold/appflow/pages/auth/role_selection_page.dart';
import 'package:casebehold/appflow/pages/forms/post_case/post_case_form.dart';
import 'package:flutter/material.dart';
import '../pages/home/user_home_page.dart';
import '../pages/home/lawyer_home_page.dart';
import '../pages/home/influencer_home_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginPage(),
  '/role-selection': (context) => const RoleSelectionPage(),
  '/user-home': (context) => const UserHomePage(),       // ✅ Add this
  '/lawyer-home': (context) => const LawyerHomePage(),   // (for later)
  '/influencer-home': (context) => const InfluencerHomePage(), // (for later)
  '/post-case': (context) => const PostCaseFormPage(),

};
