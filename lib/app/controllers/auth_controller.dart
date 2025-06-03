import 'package:get/get.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  Future<void> login(String email, String password) async {
    try {
      // TODO: Implémenter la logique de connexion
      await Future.delayed(const Duration(seconds: 1));
      currentUser.value = UserModel(
        id: '1',
        email: email,
        name: 'Utilisateur Test',
      );
      isLoggedIn.value = true;
      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar('Erreur', 'Connexion échouée');
    }
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;

  UserModel({required this.id, required this.email, required this.name});
}
