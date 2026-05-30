import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils/responsive_utils.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _effectiveDate = 'May 29, 2026';

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: Responsive.sp(context, 14),
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final headingStyle = TextStyle(
      fontSize: Responsive.sp(context, 16),
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.p(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appName, style: headingStyle.copyWith(fontSize: Responsive.sp(context, 20))),
            SizedBox(height: Responsive.h(context, 4)),
            Text('Effective date: $_effectiveDate', style: bodyStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            SizedBox(height: Responsive.h(context, 24)),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Introduction',
              'Elevate ("we", "our", or "the app") is a fitness tracking application that helps you log workouts, manage routines, and view your training progress. This Privacy Policy explains what information we collect, how we use it, and your choices regarding your data.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Information We Collect',
              'We collect the following types of information when you use Elevate:\n\n'
              '• Account information: email address, username, bio, sex, and birthday.\n'
              '• Profile photos: images you upload as your avatar.\n'
              '• Workout and fitness data: exercise names, sets, weight, repetitions, distance, duration, workout notes, and calculated statistics such as volume and personal records.\n'
              '• Post-workout photos: images you optionally attach when saving a workout.\n'
              '• Authentication data: if you sign in with Google, we receive basic profile information provided by Google (such as your name and email) through our authentication provider.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'How We Use Your Information',
              'We use your information to:\n\n'
              '• Create and manage your account.\n'
              '• Store and sync your workouts, routines, and profile across your devices.\n'
              '• Display statistics, history, calendar views, and personal records.\n'
              '• Improve app functionality and fix issues.\n\n'
              'We do not sell your personal information to third parties.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Local Storage',
              'Elevate caches your profile, workouts, and routines on your device using local storage (Hive) so the app can load data quickly and support limited offline reading. Cached data is cleared when you sign out or delete your account.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Third-Party Services',
              'We use the following third-party services to operate Elevate:\n\n'
              '• Supabase: hosts authentication, database, and file storage for your account and workout data. Supabase processes data on our behalf under their privacy and security policies.\n'
              '• Google Sign-In: optional authentication method. Google\'s privacy policy applies to information handled by Google when you choose this sign-in option.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Data Retention',
              'We retain your data for as long as your account is active. When you delete your account, we permanently delete your authentication record, profile, workouts, routines, and uploaded photos from our systems, subject to any legal retention requirements.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Your Choices',
              'You can update your profile information at any time in the app. You can permanently delete your account and all associated data from General Settings → Delete Account. Deletion is irreversible.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Children\'s Privacy',
              'Elevate is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe a child has provided us with personal information, please contact us so we can delete it.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will revise the effective date at the top of this page when changes are made. Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),
            _section(
              context,
              headingStyle,
              bodyStyle,
              'Contact Us',
              'If you have questions about this Privacy Policy or your data, contact us at:\n\n${AppConstants.privacyContactEmail}',
            ),
            SizedBox(height: Responsive.h(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    TextStyle headingStyle,
    TextStyle bodyStyle,
    String title,
    String body,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headingStyle),
          SizedBox(height: Responsive.h(context, 8)),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
