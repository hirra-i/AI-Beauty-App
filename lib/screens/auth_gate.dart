import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// screens
import 'onboarding_pager.dart';
import 'introduction_screen.dart';
import 'preferences_screen.dart';
import 'profile_loading_screen.dart'; // or affirmation loading screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //Not logged in, onboarding
        if (!snapshot.hasData) {
          return const OnboardingPager();
        }

        //Logged in, check Firestore progress
        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snap.data!.data() as Map<String, dynamic>?;
                        //Prints
                        
            print('--- AUTHGATE DEBUG ---');
            print('introCompleted: ${data?['introCompleted']}');
            print('preferences: ${data?['preferences']}');
            print('----------------------');

            

            final bool introDone = data?['introCompleted'] == true;
            final bool prefsDone = data?['preferences'] != null;

          
            if (!introDone) {
              return const IntroduceYourselfScreen();
            }

            if (!prefsDone) {
              return const PreferencesScreen();
            }

            //everything done so go to profile flow
            return const PersonalisedLoadingScreen(name: '',);
          },
        );
      },
    );
  }
}
