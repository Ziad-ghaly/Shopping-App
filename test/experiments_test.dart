import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:full_shopping_app_4/login_page.dart';
import 'package:full_shopping_app_4/signup_page.dart';

void main() {
  testWidgets('Part 5.3 Test 1: push("/signup") then context.pop()',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: "/login",
      routes: [
        GoRoute(
          path: "/login",
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: "/signup",
          builder: (context, state) => const SignupPage(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
    await tester.pumpAndSettle();

    // Verify on Login
    expect(find.text("Login"), findsOneWidget);

    // Push /signup
    testRouter.push("/signup");
    await tester.pumpAndSettle();

    // Verify on Signup
    expect(find.text("Sign Up"), findsWidgets);

    // Pop back to login
    testRouter.pop();
    await tester.pumpAndSettle();

    // Verify back on Login without issue
    expect(find.text("Login"), findsOneWidget);
  });

  testWidgets('Part 5.3 Test 2: go("/signup") then context.pop() causes error',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: "/login",
      routes: [
        GoRoute(
          path: "/login",
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: "/signup",
          builder: (context, state) => const SignupPage(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
    await tester.pumpAndSettle();

    // Go to /signup (replaces the stack)
    testRouter.go("/signup");
    await tester.pumpAndSettle();
    expect(find.text("Sign Up"), findsWidgets);

    // Calling testRouter.canPop() is false because the stack only has /signup
    expect(testRouter.canPop(), isFalse);

    // Attempting to pop() when canPop() is false throws GoError: There is nothing to pop
    expect(() => testRouter.pop(), throwsA(isA<Error>()));
  });

  testWidgets('Part 5.3 Test 3: go("/signup") then go("/login")',
      (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: "/login",
      routes: [
        GoRoute(
          path: "/login",
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: "/signup",
          builder: (context, state) => const SignupPage(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
    await tester.pumpAndSettle();

    testRouter.go("/signup");
    await tester.pumpAndSettle();
    expect(find.text("Sign Up"), findsWidgets);

    testRouter.go("/login");
    await tester.pumpAndSettle();
    expect(find.text("Login"), findsOneWidget);
  });
}
