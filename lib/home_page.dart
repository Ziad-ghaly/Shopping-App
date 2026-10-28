import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'test.dart';

/*
 * ============================================================================
 * PART 5.4: THE HIDDEN BUG EXPLANATION & FIX
 * ============================================================================
 * What was the bug?
 * - On the Login page, logging in calls `context.go("/home")`.
 * - `context.go` replaces the existing navigation stack with only `['/home']`.
 * - In the original HomePage, the button called `context.pop()`.
 * - Pressing `context.pop()` when there are no routes underneath `/home` in the stack
 *   throws an unhandled exception ("GoError: There is nothing to pop") because there
 *   is no previous screen on the stack to return to!
 *
 * How we fixed it:
 * - We converted the button into a "Logout" button.
 * - Logging out sets `Database.isLoggedIn = false;` and navigates via `context.go("/login");`.
 *   This properly transitions the app back to the login screen and resets the stack.
 * ============================================================================
 */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    print(" start Home");
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    print(" finish Home");
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("welcome to Home Page"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.push("/home/products");
              },
              child: const Text("View Products"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Fix for Part 5.4: Logout clears session and redirects cleanly to /login
                Database.isLoggedIn = false;
                context.go("/login");
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
