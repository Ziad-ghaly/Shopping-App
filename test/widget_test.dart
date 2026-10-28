import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_shopping_app_4/main.dart';
import 'package:full_shopping_app_4/test.dart';

void main() {
  setUp(() {
    Database.isLoggedIn = false;
    Database.username = "Atef";
    Database.password = "Atef12345";
  });

  testWidgets('Initial screen is LoginPage with form and navigation button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text("Login"), findsOneWidget);
    expect(find.text("go to home "), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('Signup validation tests and successful registration flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap "Don't have an account? Sign up"
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();

    // Verify on Signup page
    expect(find.text("Sign Up"), findsWidgets);

    // Tap "Sign Up" button with empty fields
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();

    // Verify all validation errors appear
    expect(find.text("Username must be at least 3 characters"), findsOneWidget);
    expect(find.text("Please enter a valid email"), findsOneWidget);
    expect(find.text("Password must be at least 6 characters"), findsOneWidget);

    // Enter username with < 3 characters
    await tester.enterText(
        find.widgetWithText(TextFormField, "Username"), "ab");
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();
    expect(find.text("Username must be at least 3 characters"), findsOneWidget);

    // Enter valid username
    await tester.enterText(
        find.widgetWithText(TextFormField, "Username"), "newuser");

    // Enter invalid email (no dot)
    await tester.enterText(
        find.widgetWithText(TextFormField, "Email"), "test@domain");
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();
    expect(find.text("Please enter a valid email"), findsOneWidget);

    // Enter valid email
    await tester.enterText(
        find.widgetWithText(TextFormField, "Email"), "test@domain.com");

    // Enter short password (< 6 chars)
    await tester.enterText(
        find.widgetWithText(TextFormField, "Password"), "123");
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();
    expect(find.text("Password must be at least 6 characters"), findsOneWidget);

    // Enter valid password and mismatched confirm password
    await tester.enterText(
        find.widgetWithText(TextFormField, "Password"), "secret123");
    await tester.enterText(
        find.widgetWithText(TextFormField, "Confirm Password"), "secret456");
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();
    expect(find.text("Passwords do not match"), findsOneWidget);

    // Enter matching confirm password
    await tester.enterText(
        find.widgetWithText(TextFormField, "Confirm Password"), "secret123");
    await tester.tap(find.widgetWithText(ElevatedButton, "Sign Up"));
    await tester.pumpAndSettle();

    // Verify Database was updated
    expect(Database.username, "newuser");
    expect(Database.password, "secret123");

    // Verify SnackBar message is shown
    expect(find.text("Account created, please login"), findsOneWidget);

    // Verify we are back on the Login page
    expect(find.text("Login"), findsOneWidget);
  });

  testWidgets('Login with updated credentials and logout flow',
      (WidgetTester tester) async {
    // Set custom credentials
    Database.username = "flutter_dev";
    Database.password = "pass1234";
    Database.isLoggedIn = false;

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter valid credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, "Username"), "flutter_dev");
    await tester.enterText(
        find.widgetWithText(TextFormField, "Password"), "pass1234");
    await tester.tap(find.text("go to home "));
    await tester.pumpAndSettle();

    // Verify we navigated to HomePage
    expect(Database.isLoggedIn, isTrue);
    expect(find.text("welcome to Home Page"), findsOneWidget);
    expect(find.text("Logout"), findsOneWidget);

    // Tap Logout button
    await tester.tap(find.text("Logout"));
    await tester.pumpAndSettle();

    // Verify logged out and returned to Login
    expect(Database.isLoggedIn, isFalse);
    expect(find.text("Login"), findsOneWidget);
  });
}
