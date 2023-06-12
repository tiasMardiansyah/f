import 'package:food_xyz_project/repositories.dart';

class CatatanPembelianViewModel extends ViewModel {

  List<LogTransaksi>? masterData = [];
  late ApiProvider apiCall;
  final tokenStorage = const FlutterSecureStorage();

  bool _isBusy = false;
  bool get isBusy =>_isBusy;
  set isBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  } 
  
  @override
  void init() async{
    apiCall = Get.find<ApiProvider>();
    await getLogTransaksi();
  }

  Future<void> getLogTransaksi() async {
    try {
      isBusy = true;
      final token = await tokenStorage.read(key: 'accessToken');
      if (token == null) {
        final error = {
          'statusCode': 404,
          'statusText': 'Token tidak ditemukan'
        };
        throw error;
      }

      final result = await apiCall.getLogTransaksi(token);
      for (var n = 0; n < result.length; n++) {
        masterData?.add((LogTransaksi.fromJson(result[n])));
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        switch (e['statusCode']) {
          case 401:
            {
              await showWarningDialog(
                title: 'Token sudah kadaluarsa',
                icon: Image.asset('assets/images/warning_sign.png'),
                texts: ['Harap login kembali'],
              );
              Get.offNamed(Routes.login);
            }
            break;

          case 404:
            {
              await showWarningDialog(
                title: 'Tidak ditemukan',
                icon: Image.asset('assets/images/not_found.png'),
                texts: ['Harap login kembali'],
              );
              Get.offNamed(Routes.login);
            }
            break;

          //dan error lain nya
        }
      } else {
        showWarningDialog(
          title: 'Error Besar',
          icon: Image.asset('assets/images/warning_sign.png'),
          texts: ['Hubungi developer apabila anda melihat pesan ini'],
        );
      }
    } finally {
      isBusy = false;
    }

  }
  





  void back() => Get.back();
}
