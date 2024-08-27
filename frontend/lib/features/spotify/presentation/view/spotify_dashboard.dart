import 'package:clean_spotify_connec/core/common/my_snackbar.dart';
import 'package:clean_spotify_connec/features/spotify/presentation/viewmodel/spotify_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  bool isObscure = true;
  late TextEditingController promptController;

  @override
  void initState() {
    super.initState();
    promptController = TextEditingController();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotifyState = ref.watch(spotifyViewModelProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (spotifyState.showMessage && spotifyState.message != null) {
        showSnackBar(
            message: spotifyState.message!,
            context: context,
            color: spotifyState.isError ? Colors.red : Colors.green);
        ref.read(spotifyViewModelProvider.notifier).resetState();
      }
    });

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/background.jpg"),
                    fit: BoxFit.cover),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 90,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create Playlist",
                                style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Enter the title that best describes the type of playlist you want",
                                style: TextStyle(
                                    color: Color(0xffD99BFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: promptController,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            maxLines: null,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "prompt is invalid";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xff4D2161),
                              errorStyle: TextStyle(color: Colors.red[900]),
                              labelText: "prompt...",
                              labelStyle: const TextStyle(
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none, // Remove border
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () async {
                                String promptText =
                                    promptController.text.trim();
                                if (promptText.isEmpty) {
                                  showSnackBar(
                                      message: "Prompt can't be empty",
                                      context: context,
                                      color: Colors.red);
                                } else {
                                  ref
                                      .read(spotifyViewModelProvider.notifier)
                                      .sendPrompt(promptController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color(0xff4D2161), // Text color
                              ),
                              child: const SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    'Send prompt',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Brand Bold',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (spotifyState.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff4D2161),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
