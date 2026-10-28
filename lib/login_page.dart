/*
================================================================================
PART 1: super.key (Keys)
================================================================================
1. What does `super.key` do? Where does the key go?
   - `super.key` is Dart constructor shorthand (introduced in Dart 2.17) that passes
     the optional `Key? key` named parameter directly to the superclass constructor `super(key: key)`.
   - Where does the key go?
     The key is passed up to the base Flutter `Widget` class constructor and stored in
     the widget's `key` property (`Widget.key`). Flutter's element tree diffing algorithm
     uses this key (via `Widget.canUpdate(oldWidget, newWidget)`) to uniquely identify
     widgets across rebuilds, preserve state when widgets move in the tree or collection,
     and decide whether an existing element can be reused or must be recreated.

2. What's the difference between `Key? key` passed through `super.key` and `GlobalKey<FormState>` (_keyForm)?
   - `Key? key` (passed via `super.key`):
     Usually a `LocalKey` (e.g. `ValueKey`, `ObjectKey`, `UniqueKey`) or `null`. Its scope
     is local among sibling widgets in a parent's children list. It helps the framework
     know which widget matches which element during reconciliation, but does not provide
     external programmatic access to the widget's internal state.
   - `GlobalKey<FormState>` (`_keyForm`):
     A globally unique key across the entire application widget tree. It provides direct
     programmatic access to the associated `State` object (`_keyForm.currentState`),
     allowing methods like `validate()`, `save()`, and `reset()` to be called from outside
     the Form widget. It also allows an element to retain its state when reparented to a
     different location in the widget tree. It is much heavier and more resource-intensive
     than local keys.

================================================================================
PART 2: const usage
================================================================================
- Why does `const` make Flutter faster? (Hint: rebuilds.)
  In Flutter, widgets instantiated with `const` constructors are canonicalized at compile
  time by Dart. Dart allocates only a single immutable instance in memory, which is reused
  everywhere across rebuilds.
  During rebuilds, Flutter checks `identical(oldWidget, newWidget)`. When a widget instance
  is `const`, its memory reference is identical to the previous one, so Flutter knows with
  absolute certainty that neither the widget nor its configuration has changed. Flutter
  completely short-circuits (skips) rebuilding, diffing, and layout for that widget and
  its subtree. This significantly lowers CPU cycles, avoids unnecessary garbage collection
  (GC) pressure, and ensures steady 60/120 FPS performance.

================================================================================
PART 3: Make every State private
================================================================================
- What does the `_` do in Dart, and why should State classes be private?
  - In Dart, an underscore `_` prefix at the beginning of an identifier marks it as
    library-private (accessible only within the single `.dart` file where it is declared).
    Dart does not use `public`, `protected`, or `private` keywords; privacy is lexical at
    the file/library boundary.
  - Why should State classes be private?
    1. Encapsulation: The `State` object holds internal mutable variables (e.g., controllers,
       form keys, and business logic methods) that are internal implementation details.
       External files should not touch or mutate them directly.
    2. Framework Contract: Flutter's element tree manages the creation and lifecycle of
       `State` objects via `StatefulElement`. External widgets should interact only with
       the public `StatefulWidget` interface and its constructor parameters.
    3. API Hygiene: It prevents polluting the library's public API surface with classes
       that are solely internal implementations.

================================================================================
PART 5: Navigation with push, pop, and go
================================================================================
5.1 Routing:
    Why keep "/signup" top-level and NOT under "/home"?
    - The redirect callback checks:
        if (path.startsWith("/home") && !Database.isLoggedIn) { return "/login"; }
      If "/signup" were declared as a child route under "/home" (e.g., "/home/signup"),
      any unauthenticated user (where `!Database.isLoggedIn` is true) would trigger the
      redirect rule and be bounced back to "/login", making signup completely inaccessible.
    - Logically, signup is an unauthenticated root-level screen alongside "/login", not
      a child screen of the authenticated home section.

5.3 Experiment: go vs push results
    - Test 1:
      Login to Signup using: context.push("/signup")
      Signup back using: context.pop()
      What happened?
      `context.push` pushes `/signup` on top of `/login` in the navigation stack ([/login, /signup]).
      When `context.pop()` is pressed, `/signup` is popped off the stack, cleanly revealing
      the existing `LoginPage` underneath. `LoginPage` remained alive the entire time.
    - Test 2:
      Login to Signup using: context.go("/signup")
      Signup back using: context.pop()
      What happened?
      `context.go("/signup")` clears the previous stack and sets the new stack to only `[/signup]`.
      `LoginPage` is disposed ("finish Login"). When `context.pop()` is called on Signup,
      there is no prior route on the stack to pop to! GoRouter throws an error:
      "GoError: There is nothing to pop", and the app cannot pop back.
    - Test 3:
      Login to Signup using: context.go("/signup")
      Signup back using: context.go("/login")
      What happened?
      `context.go("/signup")` replaces the stack with `[/signup]`, disposing Login ("finish Login").
      Then `context.go("/login")` replaces the stack with `[/login]`, disposing Signup
      ("finish Signup") and mounting a fresh new Login page ("start Login"). It works without
      errors, but creates a brand new Login instance rather than returning to the previous one.
    - Test 4:
      Login to Signup using: context.push("/signup")
      Signup back using: the phone / AppBar back arrow
      What happened?
      Since `push` placed `/signup` on top of `/login` in the Navigator stack, the AppBar
      back button / system back arrow pops the top route off the stack, smoothly returning
      to the existing `LoginPage` underneath, exactly like `context.pop()`.

    initState / dispose prints observations:
    - With `push`: Is Login disposed when you open Signup?
      NO. `LoginPage` remains alive in memory on the stack underneath `SignupPage`. "finish Login"
      is NOT called.
    - With `go`: Is Login disposed?
      YES. `context.go` replaces the stack, unmounting `LoginPage` and triggering "finish Login".

5.4 Find the hidden bug & Difference between go and push using the word "stack":
    - Pressing "go back" on HomePage threw "GoError: There is nothing to pop" because
      Login navigated using `context.go("/home")`, which replaced the navigation stack
      with only `['/home']`. Since `/login` was destroyed and removed from the **stack**,
      calling `context.pop()` found no route underneath to pop back to.
    - Fix: We changed the button into a "Logout" button that resets `Database.isLoggedIn = false;`
      and navigates with `context.go("/login");`.
    - Difference between `go` and `push` using the word "stack":
      `push` adds a new page on TOP of the existing navigation **stack** while preserving
      all underlying pages in memory, allowing you to `pop` back down the **stack**.
      `go` replaces or reconstructs the entire navigation **stack** according to the router
      definition, discarding any previous routes from the **stack**, meaning you cannot `pop`
      unless parent routes exist in the new **stack**.
================================================================================
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'test.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _keyForm = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _inputCheck() {
    if (_keyForm.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      if (username == Database.username && password == Database.password) {
        Database.isLoggedIn = true;
        context.go("/home");
      } else {
        _usernameController.clear();
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong info")),
        );
      }
    }
  }

  @override
  void initState() {
    print(" start Login");
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    print(" finish Login");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _keyForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "please enter valid username ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) {
                    if (((value?.length) ?? 0) < 6) {
                      return "please enter valid password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _inputCheck,
                  child: const Text("go to home "),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    context.push("/signup");
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
