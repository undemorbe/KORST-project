import 'package:flutter_test/flutter_test.dart';
import 'package:korst/features/auth/domain/entities/auth_user_status.dart';
import 'package:korst/features/auth/domain/entities/user_entity.dart';
import 'package:korst/features/auth/domain/repositories/auth_repository.dart';
import 'package:korst/features/auth/presentation/store/auth_store.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthStore store;
  late MockAuthRepository mockAuthRepository;

  final testUser = UserEntity(
    uid: '123',
    name: 'Test User',
    phone: '1234567890',
    contacts: {'email': 'test@example.com'},
    createdCards: [],
    bookings: {},
    created: DateTime.now(),
    updated: DateTime.now(),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    store = AuthStore(mockAuthRepository);
    registerFallbackValue(testUser);
  });

  group('AuthStore', () {
    test('initial values are correct', () {
      expect(store.isLoading, false);
      expect(store.isLoggedIn, false);
      expect(store.userProfile, null);
      expect(store.errorMessage, null);
      expect(store.phoneNumber, null);
    });

    group('checkLoginStatus', () {
      test('sets isLoggedIn and userProfile when logged in', () async {
        when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepository.getUserProfile()).thenAnswer((_) async => testUser);

        await store.checkLoginStatus();

        expect(store.isLoggedIn, true);
        expect(store.userProfile, testUser);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.isLoggedIn()).called(1);
        verify(() => mockAuthRepository.getUserProfile()).called(1);
      });

      test('sets isLoggedIn to false when not logged in', () async {
        when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => false);

        await store.checkLoginStatus();

        expect(store.isLoggedIn, false);
        expect(store.userProfile, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.isLoggedIn()).called(1);
        verifyNever(() => mockAuthRepository.getUserProfile());
      });

      test('handles errors gracefully', () async {
        final exception = Exception('Error checking login status');
        when(() => mockAuthRepository.isLoggedIn()).thenThrow(exception);

        await store.checkLoginStatus();

        expect(store.isLoading, false);
        expect(store.errorMessage, exception.toString());
      });
    });

    group('sendOtp', () {
      const phone = '1234567890';

      test('calls repository and updates state on success', () async {
        when(() => mockAuthRepository.sendOtp(any())).thenAnswer((_) async {});

        await store.sendOtp(phone);

        expect(store.phoneNumber, phone);
        expect(store.errorMessage, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.sendOtp(phone)).called(1);
      });

      test('handles errors gracefully', () async {
        final exception = Exception('Error sending OTP');
        when(() => mockAuthRepository.sendOtp(any())).thenThrow(exception);

        await store.sendOtp(phone);

        expect(store.phoneNumber, phone);
        expect(store.errorMessage, exception.toString());
        expect(store.isLoading, false);
      });
    });

    group('verifyOtp', () {
      const code = '1234';
      const phone = '+79990000000';

      test('returns status and updates state on success', () async {
        store.phoneNumber = phone;
        when(
          () => mockAuthRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => AuthUserStatus.user);
        when(() => mockAuthRepository.getUserProfile()).thenAnswer((_) async => testUser);

        final result = await store.verifyOtp(code);

        expect(result, AuthUserStatus.user);
        expect(store.isLoggedIn, true);
        expect(store.userProfile, testUser);
        expect(store.userStatus, AuthUserStatus.user);
        expect(store.errorMessage, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.verifyOtp(phone: phone, otp: code)).called(1);
        verify(() => mockAuthRepository.getUserProfile()).called(1);
      });

      test('routes to notRegistered status correctly', () async {
        store.phoneNumber = phone;
        when(
          () => mockAuthRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => AuthUserStatus.notRegistered);
        when(() => mockAuthRepository.getUserProfile()).thenAnswer((_) async => testUser);

        final result = await store.verifyOtp(code);

        expect(result, AuthUserStatus.notRegistered);
        expect(store.isLoggedIn, true);
        expect(store.userProfile, testUser);
        expect(store.errorMessage, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.verifyOtp(phone: phone, otp: code)).called(1);
        verify(() => mockAuthRepository.getUserProfile()).called(1);
      });

      test('returns null and sets errorMessage on exception', () async {
        final exception = Exception('Error verifying OTP');
        store.phoneNumber = phone;
        when(
          () => mockAuthRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          ),
        ).thenThrow(exception);

        final result = await store.verifyOtp(code);

        expect(result, null);
        expect(store.errorMessage, exception.toString());
        expect(store.isLoading, false);
      });
    });

    group('register', () {
      const name = 'Test User';
      const contacts = 'test@example.com';
      const phone = '+79990000000';

      test('calls repository and updates state on success', () async {
        when(() => mockAuthRepository.updateProfile(any())).thenAnswer((_) async {});
        store.phoneNumber = phone;
        store.userProfile = testUser;

        await store.register(name, null, contacts);

        expect(store.isLoggedIn, true);
        expect(store.userProfile?.name, name);
        expect(store.errorMessage, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.updateProfile(any())).called(1);
      });

      test('handles errors gracefully', () async {
        final exception = Exception('Error registering');
        when(() => mockAuthRepository.updateProfile(any())).thenThrow(exception);
        store.phoneNumber = phone;
        store.userProfile = testUser;

        await store.register(name, null, contacts);

        expect(store.isLoggedIn, false);
        expect(store.errorMessage, exception.toString());
        expect(store.isLoading, false);
      });
    });

    group('logout', () {
      test('clears state and calls repository', () async {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        store.isLoggedIn = true;
        store.userProfile = testUser;

        await store.logout();

        expect(store.isLoggedIn, false);
        expect(store.userProfile, null);
        verify(() => mockAuthRepository.logout()).called(1);
      });
    });

    group('updateProfile', () {
      test('calls repository and updates state on success', () async {
        when(() => mockAuthRepository.updateProfile(any())).thenAnswer((_) async {});

        await store.updateProfile(testUser);

        expect(store.userProfile, testUser);
        expect(store.errorMessage, null);
        expect(store.isLoading, false);
        verify(() => mockAuthRepository.updateProfile(testUser)).called(1);
      });

      test('handles errors gracefully', () async {
        final exception = Exception('Error updating profile');
        when(() => mockAuthRepository.updateProfile(any())).thenThrow(exception);

        await store.updateProfile(testUser);

        expect(store.errorMessage, exception.toString());
        expect(store.isLoading, false);
      });
    });
  });
}
