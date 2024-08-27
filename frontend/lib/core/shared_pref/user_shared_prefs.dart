import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userSharedPrefsProvider = Provider<UserSharedPrefs>((ref) {
  return UserSharedPrefs();
});

class UserSharedPrefs {
  late SharedPreferences _sharedPreferences;

  Future<Either<Failure, bool>> setAcessToken(String acessToken) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.setString('acess_token', acessToken);
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, String?>> getAcessToken() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      final token = _sharedPreferences.getString('acess_token');
      return right(token);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteAcessToken() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('acess_token');
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> setRefreshToken(String refreshToken) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      // Serialize the mentee data to JSON string
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.setString('refresh_token', refreshToken);
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      final token = _sharedPreferences.getString('refresh_token');
      return right(token);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteUserDetails() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('refresh_token');
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

 Future<Either<Failure, bool>> setExpiryDate(DateTime expiryDate) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      // Convert DateTime to string before saving
      String expiryDateString = expiryDate.toIso8601String();
      await _sharedPreferences.setString('expiry_date', expiryDateString);
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

    Future<Either<Failure, DateTime?>> getExpiryDate() async {
      try {
        _sharedPreferences = await SharedPreferences.getInstance();
        final expiryDateString = _sharedPreferences.getString('expiry_date');
        if (expiryDateString != null) {
          // Convert string back to DateTime
          DateTime expiryDate = DateTime.parse(expiryDateString);
          return right(expiryDate);
        } else {
          return right(null);
        }
      } catch (e) {
        return left(Failure(error: e.toString()));
      }
    }


  Future<Either<Failure, bool>> deleteExpDate() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('expiry_date');
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

    Future<Either<Failure, bool>> setUserId(String userId) async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.setString('userId', userId);
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, String?>> getUserId() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      final token = _sharedPreferences.getString('userId');
      return right(token);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteUserId() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      await _sharedPreferences.remove('userId');
      return right(true);
    } catch (e) {
      return left(Failure(error: e.toString()));
    }
  }

  
}
