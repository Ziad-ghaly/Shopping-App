import 'package:go_router/go_router.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'products_page.dart';
import 'signup_page.dart';
import 'test.dart';

/*
 * ============================================================================
 * PART 5.1: ROUTING & REDIRECT EXPLANATION
 * ============================================================================
 * Why keep "/signup" as a top-level route and NOT under "/home"?
 *
 * 1. Redirect Guard Protection:
 *    The redirect callback checks:
 *      if (path.startsWith("/home") && !Database.isLoggedIn) { return "/login"; }
 *    If "/signup" were nested under "/home" (i.e. "/home/signup"), any user who
 *    is not logged in (!Database.isLoggedIn) would immediately be caught by the
 *    condition `path.startsWith("/home")` and bounced back to "/login". They
 *    would never be able to open the sign up page!
 *
 * 2. Logical Screen Hierarchy:
 *    Signup is an unauthenticated onboarding screen that belongs alongside
 *    "/login" at the root level of navigation, not as a sub-page of the
 *    authenticated home dashboard.
 * ============================================================================
 */

final router = GoRouter(
  initialLocation: "/login",
  redirect: (context, state) {
    var path = state.matchedLocation;
    if (path.startsWith("/home") && !Database.isLoggedIn) {
      return "/login";
    }
    return null;
  },
  routes: [
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/signup",
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'products',
          builder: (context, state) => const ProductsPage(),
        ),
      ],
    ),
  ],
);
