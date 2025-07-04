import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_event.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_state.dart';

import 'package:inventory_tsth2/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:inventory_tsth2/features/profile/presentation/bloc/profile_event.dart';
import 'package:inventory_tsth2/features/profile/presentation/bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch event to get user data if not already loaded by another process
    context.read<ProfileBloc>().add(GetCurrentUserEvent());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileActionInProgress) {
                // Show loading dialog
              } else if (state is ProfileActionSuccess) {
                // Hide dialog, show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is ProfileActionFailure) {
                // Hide dialog, show error snackbar
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
           BlocListener<UserBloc, UserState>(
             listener: (context, state) {
                if (state is UserLoggedOut) {
                  // Navigate to login screen
                }
             },
           )
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ProfileLoaded) {
              final user = state.user;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CircleAvatar(radius: 50, child: Text(user.name.substring(0, 1))),
                  const SizedBox(height: 16),
                  Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text(user.email ?? 'No Email'),
                  // Add more profile details here
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to EditProfilePage, passing the user
                    },
                    child: const Text('Edit Profil'),
                  ),
                   ElevatedButton(
                    onPressed: () {
                      // Show change password dialog, on confirm:
                      // context.read<ProfileBloc>().add(ChangePasswordEvent(...));
                    },
                    child: const Text('Ubah Password'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog, on confirm:
                      context.read<UserBloc>().add(UserLogoutEvent());
                    },
                    child: const Text('Logout'),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}