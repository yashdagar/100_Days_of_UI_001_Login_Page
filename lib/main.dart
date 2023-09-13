import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rive/rive.dart';
import 'dart:io' show Platform;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  bool get isPlaying => _controller?.isActive ?? false;

  Artboard? _riveArtboard;
  Timer? timer, timer2;
  StateMachineController? _controller;
  SMIBool? _check;
  SMIBool? _handsUp;
  SMITrigger? _failure;
  SMITrigger? _success;

  bool showPass = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final FocusNode fn1 = FocusNode(), fn2 = FocusNode();

  BoxDecoration decoration = BoxDecoration(
    borderRadius: BorderRadius.circular(28.0),
    color: const Color(0xFFFAFAFA),
    boxShadow: const [
      BoxShadow(
        color: Color(0x66AED2FF),
        blurRadius: 8,
        offset: Offset(4, 4),
      ),
      BoxShadow(
        color: Color(0x66E4F1FF),
        blurRadius: 8,
        offset: Offset(-4, -4),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();

    rootBundle.load('animation/login.riv').then(
          (data) async {
        final file = RiveFile.import(data);

        final artBoard = file.mainArtboard;
        var controller =
        StateMachineController.fromArtboard(artBoard, 'State Machine 1');
        if (controller != null) {
          artBoard.addController(controller);

          _check = controller.findSMI('Check');
          _handsUp = controller.findSMI('hands_up');
          _failure = controller.findSMI('fail');
          _success = controller.findSMI('success');
        }
        setState(() => _riveArtboard = artBoard);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Container(
        alignment: Alignment.center,
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100)),
                    constraints: const BoxConstraints(
                      minHeight: 160,
                      minWidth: 160,
                      maxHeight: 200,
                      maxWidth: 200,
                    ),
                    child: _riveArtboard == null
                        ? const SizedBox()
                        : Rive(
                      artboard: _riveArtboard!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: decoration,
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 72),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    child: TextFormField(
                      validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (value != null && !isValidEmail(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                      focusNode: fn1,
                      controller: emailController,
                      onChanged: (_) {textChanged(fn1);},
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Color(0xFF848484)),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: decoration,
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 72),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                    child: TextFormField(
                      focusNode: fn2,
                      controller: passController,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value != null && value.length < 6) {
                          return 'The password should be longer than 6 characters';
                        }
                        return null;
                      },
                      onChanged: (_) {textChanged(fn2);},
                      obscureText: !showPass,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      decoration: InputDecoration(
                                suffix:
                                IconButton(
                                  onPressed: () {showPassPressed();},
                                  icon:
                                  Icon(showPass? Ionicons.eye: Ionicons.eye_off),
                                ),
                                border: InputBorder.none,
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Color(0xFF848484)),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x449400FF),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                  child: FilledButton(
                    onPressed: (){
                      _formKey.currentState != null && _formKey.currentState!.validate()?
                      success():
                      failure();
                      },
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9400FF),
                        textStyle: const TextStyle(fontSize: 16,),
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: Platform.isAndroid || Platform.isIOS? 16: 24)
                    ),
                    child: const Text("Login"),
                  ),
                ),
              ]),
            ),
          ),
      ),
    );
  }

  void showPassPressed(){
    setState(() => showPass = !showPass);
    _handsUp?.change(!_handsUp!.value);
  }

  void success(){
    _handsUp?.change(false);
    _check?.change(false);
    _success?.fire();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  void failure(){
    _handsUp?.change(false);
    _check?.change(false);
    _failure?.fire();
  }

  void textChanged(FocusNode fn){
    if(!_check!.value) {
      _check!.change(true);
    }
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 4000), () => setState(() =>
        _check!.change(false)
    ));

    if(!fn.hasFocus) {
      fn.requestFocus();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();

    super.dispose();
  }
}