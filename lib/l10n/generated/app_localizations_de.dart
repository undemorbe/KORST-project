// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Korst';

  @override
  String get appSubtitle => 'Dienstleistungsmarkt';

  @override
  String get homeTitle => 'Dienste';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeTitle => 'Design';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get systemTheme => 'System';

  @override
  String get serviceDetailsTitle => 'Dienstdetails';

  @override
  String get priceLabel => 'Preis';

  @override
  String priceFormat(Object price, Object currency) {
    return '$price $currency';
  }

  @override
  String get errorLoading => 'Fehler beim Laden';

  @override
  String get emptyList => 'Keine Elemente verfügbar';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get close => 'Schließen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get navHome => 'Startseite';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navChats => 'Chats';

  @override
  String get navBookings => 'Buchungen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navMessages => 'Nachrichten';

  @override
  String get navProfile => 'Profil';

  @override
  String get favoritesTitle => 'Favoriten';

  @override
  String get bookingsTitle => 'Meine Buchungen';

  @override
  String get bookNow => 'Jetzt Buchen';

  @override
  String get bookingSuccess => 'Dienst erfolgreich gebucht!';

  @override
  String get bookingDate => 'Buchungsdatum';

  @override
  String get noFavorites => 'Noch keine Favoriten.';

  @override
  String get noBookings => 'Noch keine Buchungen.';

  @override
  String get searchHint => 'Dienste suchen...';

  @override
  String get searchResults => 'Suchergebnisse';

  @override
  String get noSearchResults => 'Keine Ergebnisse gefunden';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryCleaning => 'Reinigung';

  @override
  String get categoryRepair => 'Reparatur';

  @override
  String get categoryConsulting => 'Beratung';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get categoryDelivery => 'Lieferung';

  @override
  String get categoryTutoring => 'Nachhilfe';

  @override
  String get categoryDesign => 'Design';

  @override
  String get categoryDevelopment => 'Entwicklung';

  @override
  String get authTitle => 'Willkommen';

  @override
  String get authSubtitle => 'Anmelden zum Fortfahren';

  @override
  String get phoneLabel => 'Telefonnummer';

  @override
  String get phoneHint => '+49 ___ ________';

  @override
  String get sendOtp => 'Code Senden';

  @override
  String get verifyOtp => 'Verifizieren';

  @override
  String get otpLabel => 'Bestätigungscode';

  @override
  String get otpHint => '4-stelligen Code eingeben';

  @override
  String otpSent(Object phone) {
    return 'Code gesendet an $phone';
  }

  @override
  String get otpError => 'Ungültiger Code. Bitte erneut versuchen.';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirm => 'Möchtest du dich wirklich abmelden?';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEdit => 'Profil Bearbeiten';

  @override
  String get profileName => 'Name';

  @override
  String get profileSurname => 'Nachname';

  @override
  String get profilePhone => 'Telefon';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDescription => 'Über mich';

  @override
  String get profileRating => 'Bewertung';

  @override
  String get profileReviews => 'Rezensionen';

  @override
  String get profileServices => 'Meine Dienste';

  @override
  String get profileNoServices => 'Du hast noch keine Dienste';

  @override
  String get profileAddService => 'Dienst Hinzufügen';

  @override
  String get serviceCreateTitle => 'Dienst Erstellen';

  @override
  String get serviceEditTitle => 'Dienst Bearbeiten';

  @override
  String get serviceName => 'Dienstname';

  @override
  String get serviceDescription => 'Beschreibung';

  @override
  String get servicePrice => 'Preis';

  @override
  String get serviceCurrency => 'Währung';

  @override
  String get serviceType => 'Typ';

  @override
  String get serviceTags => 'Tags';

  @override
  String get serviceTagsHint => 'Tags durch Kommas getrennt hinzufügen';

  @override
  String get serviceImage => 'Dienstbild';

  @override
  String get serviceAddImage => 'Bild Hinzufügen';

  @override
  String get serviceChangeImage => 'Bild Ändern';

  @override
  String get serviceAuthor => 'Autor';

  @override
  String get serviceYou => 'Du';

  @override
  String get servicePublished => 'Veröffentlicht';

  @override
  String get serviceUpdated => 'Aktualisiert';

  @override
  String get messagesTitle => 'Nachrichten';

  @override
  String get messagesAsBuyer => 'Als Käufer';

  @override
  String get messagesAsSeller => 'Als Verkäufer';

  @override
  String get messagesNoChatsBuyer =>
      'Du hast noch keine Chats als Käufer\nSchreibe einem Verkäufer aus einer Dienstekarte';

  @override
  String get messagesNoChatsSeller =>
      'Du hast noch keine Chats als Verkäufer\nWarte auf Nachrichten von Käufern';

  @override
  String get messagesStart => 'Chat Starten';

  @override
  String get messagesTypeHint => 'Nachricht eingeben...';

  @override
  String get messagesSend => 'Senden';

  @override
  String get messagesEdit => 'Bearbeiten';

  @override
  String get messagesDelete => 'Löschen';

  @override
  String get messagesDeleteConfirm => 'Diese Nachricht löschen?';

  @override
  String get messagesEmpty => 'Noch keine Nachrichten';

  @override
  String get messagesLoadingError => 'Nachrichten konnten nicht geladen werden';

  @override
  String get errorGeneric => 'Etwas ist schief gelaufen';

  @override
  String get errorNetwork => 'Netzwerkfehler. Überprüfe deine Verbindung.';

  @override
  String get errorServer => 'Serverfehler. Bitte später erneut versuchen.';

  @override
  String get errorUnauthorized => 'Sitzung abgelaufen. Bitte erneut anmelden.';

  @override
  String get errorNotFound => 'Nicht gefunden';

  @override
  String get errorValidation => 'Eingegebene Daten überprüfen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get version => 'Version';

  @override
  String get currencyUSD => 'USD';

  @override
  String get currencyEUR => 'EUR';

  @override
  String get currencyRUB => 'RUB';

  @override
  String get currencyKZT => 'KZT';

  @override
  String get share => 'Teilen';

  @override
  String get shareService => 'Schau dir diesen Dienst auf Korst an';

  @override
  String get copied => 'In Zwischenablage kopiert';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sortieren';

  @override
  String get sortByDate => 'Nach Datum';

  @override
  String get sortByPrice => 'Nach Preis';

  @override
  String get sortByRating => 'Nach Bewertung';

  @override
  String get loading => 'Laden...';

  @override
  String get loadMore => 'Mehr Laden';

  @override
  String get noMoreItems => 'Keine weiteren Elemente';

  @override
  String get created => 'Erstellt';

  @override
  String get updated => 'Aktualisiert';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get errorOops => 'Oops! Something went wrong';

  @override
  String get settingsKorstPromo =>
      'Korst — services nearby.\\n\\nOpen app: korst:/// \\n';

  @override
  String get myProfile => 'My Profile';

  @override
  String get publicProfile => 'Public Profile';

  @override
  String get myReviews => 'My Reviews';

  @override
  String get appSettings => 'App Settings';

  @override
  String get russianLanguage => 'Russian';

  @override
  String get additional => 'Additional';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get statistics => 'Statistics';

  @override
  String get services => 'Services';

  @override
  String get earned => 'Earned';

  @override
  String get rating => 'Rating';

  @override
  String get trustFactor => 'Trust Factor';

  @override
  String get trustFactorDesc =>
      'Calculated based on the number of services, reviews, and rating.';

  @override
  String get user => 'User';

  @override
  String get welcomeToKorst => 'Welcome to Korst';

  @override
  String get findServicesNearby =>
      'Find the best beauty and health services near you';

  @override
  String get start => 'Start';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get yourPhoneNumber => 'Your phone number';

  @override
  String get weWillSendVerificationCode =>
      'We will send a verification code to this number';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get continueAction => 'Continue';

  @override
  String get enterSmsCode => 'Enter SMS code';

  @override
  String get weSentCodeTo => 'We sent a code to ';

  @override
  String get profileCreatedButPhotoFailed =>
      'Profile created but photo upload failed: ';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createProfileBtn => 'Create Profile';

  @override
  String get basicData => 'Basic Data';

  @override
  String get firstName => 'First Name';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get aboutMe => 'About Me';

  @override
  String get additionalContact => 'Additional Contact';

  @override
  String get errorLoadingPrefix => 'Loading error: ';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get youHaveNoReviewsYet => 'You have no reviews yet';

  @override
  String get errorLoadingPhotoPrefix => 'Error loading photo: ';

  @override
  String get noMoreData => 'No more data';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get errorUserNotFound => 'Error: user not found';

  @override
  String get task => 'task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get newTask => 'New Task';

  @override
  String get updateTask => 'Update Task';

  @override
  String get createTask => 'Create Task';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get title => 'Title';

  @override
  String get enterTitle => 'Enter title';

  @override
  String get description => 'Description';

  @override
  String get budget => 'Budget';

  @override
  String get enterBudget => 'Enter budget';

  @override
  String get invalidBudget => 'Invalid budget';

  @override
  String get category => 'Category';

  @override
  String get currency => 'Currency';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'repair, fast, urgent';

  @override
  String get failedToCreateChatPrefix => 'Failed to create chat: ';

  @override
  String get serviceCard => 'Service Card';

  @override
  String get openInKorstPrefix => '\\n\\nOpen in Korst: ';

  @override
  String get authorPrefix => 'Author: ';

  @override
  String get you => 'You';

  @override
  String get respondToTask => 'Respond to task';

  @override
  String get errorUpdatingToken => 'Error updating token';

  @override
  String get failedToSendOtp => 'Failed to send OTP';

  @override
  String get failedToVerifyUser => 'Failed to verify user';

  @override
  String get invalidServerResponse => 'Invalid server response';

  @override
  String get failedToConfirmOtp => 'Failed to confirm OTP';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get failedToLoadMessages => 'Failed to load messages';

  @override
  String get failedToCreateChat => 'Failed to create chat';

  @override
  String get failedToSendMessage => 'Failed to send message';

  @override
  String get failedToEditMessage => 'Failed to edit message';

  @override
  String get failedToDeleteMessage => 'Failed to delete message';

  @override
  String get invalidServerResponseInfo => 'Invalid server response (info)';

  @override
  String get failedToLoadUserProfile => 'Failed to load user profile';

  @override
  String get failedToSendReview => 'Failed to send review';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get errorLoadingImage => 'Error loading image';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get service => 'service';

  @override
  String get failedToLoadCards => 'Failed to load cards';

  @override
  String get failedToLoadCard => 'Failed to load card';

  @override
  String get failedToCreateCard => 'Failed to create card';

  @override
  String get failedToUpdateCard => 'Failed to update card';

  @override
  String get failedToLoadCardImage => 'Failed to load card image';
}
