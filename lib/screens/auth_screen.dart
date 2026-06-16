import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _cadastroFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginSenhaController = TextEditingController();

  final _nomeController = TextEditingController();
  final _cadastroEmailController = TextEditingController();
  final _cadastroSenhaController = TextEditingController();

  bool _loadingLogin = false;
  bool _loadingCadastro = false;
  bool _loadingGoogle = false;
  String? _erroLogin;
  String? _erroCadastro;
  String? _infoLogin;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginSenhaController.dispose();
    _nomeController.dispose();
    _cadastroEmailController.dispose();
    _cadastroSenhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _loadingLogin = true;
      _erroLogin = null;
      _infoLogin = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginSenhaController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _erroLogin = _mensagemErroLogin(e));
    } catch (_) {
      setState(() => _erroLogin = 'Não foi possível entrar agora.');
    } finally {
      if (mounted) {
        setState(() => _loadingLogin = false);
      }
    }
  }

  Future<void> _recuperarSenha() async {
    final email = _loginEmailController.text.trim();
    final emailValido = email.contains('@') && email.contains('.');
    if (!emailValido) {
      setState(() {
        _erroLogin = 'Informe um e-mail válido para recuperar a senha.';
        _infoLogin = null;
      });
      return;
    }

    try {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _erroLogin = null;
        _infoLogin = 'E-mail de recuperação enviado para $email.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail de recuperação enviado para $email.')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erroLogin = _mensagemErroRecuperacao(e);
        _infoLogin = null;
      });
    } catch (_) {
      setState(() {
        _erroLogin = 'Não foi possível enviar o e-mail de recuperação.';
        _infoLogin = null;
      });
    }
  }

  Future<void> _cadastrar() async {
    if (!_cadastroFormKey.currentState!.validate()) return;

    setState(() {
      _loadingCadastro = true;
      _erroCadastro = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      final cred = await auth.createUserWithEmailAndPassword(
        email: _cadastroEmailController.text.trim(),
        password: _cadastroSenhaController.text,
      );

      final nome = _nomeController.text.trim();
      if (nome.isNotEmpty) {
        await cred.user?.updateDisplayName(nome);
        await cred.user?.reload();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _erroCadastro = _mensagemErroCadastro(e));
    } catch (_) {
      setState(() => _erroCadastro = 'Não foi possível concluir o cadastro.');
    } finally {
      if (mounted) {
        setState(() => _loadingCadastro = false);
      }
    }
  }

  Future<void> _entrarComGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _erroLogin = null;
      _infoLogin = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        await auth.signInWithPopup(provider);
      } else {
        await GoogleSignIn.instance.initialize();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-id-token',
            message: 'Não foi possível obter o token do Google.',
          );
        }

        final credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        await auth.signInWithCredential(credential);
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        setState(() {
          _erroLogin = 'Login com Google cancelado.';
        });
      } else {
        setState(() {
          _erroLogin = 'Falha no login com Google.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erroLogin = e.message ?? 'Falha ao autenticar com Google.';
      });
    } catch (_) {
      setState(() {
        _erroLogin = 'Não foi possível entrar com Google agora.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingGoogle = false;
        });
      }
    }
  }

  String _mensagemErroLogin(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return e.message ?? 'Falha ao entrar.';
    }
  }

  String _mensagemErroCadastro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'weak-password':
        return 'A senha é fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Ative o provedor Email/Senha no Firebase Auth.';
      default:
        return e.message ?? 'Falha ao cadastrar usuário.';
    }
  }

  String _mensagemErroRecuperacao(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return e.message ?? 'Falha ao enviar e-mail de recuperação.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DefaultTabController(
              length: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Grilo',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Entre ou crie sua conta.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const TabBar(
                        tabs: [
                          Tab(text: 'Entrar'),
                          Tab(text: 'Cadastrar'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 320,
                        child: TabBarView(
                          children: [
                            Form(
                              key: _loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _loginEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) return 'Informe o e-mail.';
                                      if (!v.contains('@') || !v.contains('.')) return 'Informe um e-mail válido.';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _loginSenhaController,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _loadingLogin ? null : _entrar(),
                                    decoration: const InputDecoration(
                                      labelText: 'Senha',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      final v = value ?? '';
                                      if (v.isEmpty) return 'Informe a senha.';
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _loadingLogin ? null : _recuperarSenha,
                                      child: const Text('Esqueci minha senha'),
                                    ),
                                  ),
                                  if (_erroLogin != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _erroLogin!,
                                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  if (_infoLogin != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                                        ),
                                      ),
                                      child: Text(
                                        _infoLogin!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  SizedBox(
                                    height: 46,
                                    child: FilledButton(
                                      onPressed: (_loadingLogin || _loadingGoogle) ? null : _entrar,
                                      child: _loadingLogin
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Entrar'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 46,
                                    child: OutlinedButton.icon(
                                      onPressed: (_loadingLogin || _loadingGoogle) ? null : _entrarComGoogle,
                                      icon: _loadingGoogle
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.login),
                                      label: const Text('Entrar com Google'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              key: _cadastroFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _nomeController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome de usuário',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) return 'Informe o nome de usuário.';
                                      if (v.length < 3) return 'Use pelo menos 3 caracteres.';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _cadastroEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) return 'Informe o e-mail.';
                                      if (!v.contains('@') || !v.contains('.')) return 'Informe um e-mail válido.';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _cadastroSenhaController,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _loadingCadastro ? null : _cadastrar(),
                                    decoration: const InputDecoration(
                                      labelText: 'Senha',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      final v = value ?? '';
                                      if (v.isEmpty) return 'Informe a senha.';
                                      if (v.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                                      return null;
                                    },
                                  ),
                                  if (_erroCadastro != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      _erroCadastro!,
                                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  const Spacer(),
                                  SizedBox(
                                    height: 46,
                                    child: FilledButton(
                                      onPressed: _loadingCadastro ? null : _cadastrar,
                                      child: _loadingCadastro
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Criar conta'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}