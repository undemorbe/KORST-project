import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('de'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Korst'**
  String get appTitle;

  /// The subtitle of the application
  ///
  /// In en, this message translates to:
  /// **'Freelance Platform'**
  String get appSubtitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get homeTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @serviceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetailsTitle;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @priceFormat.
  ///
  /// In en, this message translates to:
  /// **'{price} {currency}'**
  String priceFormat(Object price, Object currency);

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get errorLoading;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get emptyList;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service booked successfully!'**
  String get bookingSuccess;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get bookingDate;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get noFavorites;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get noBookings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get categoryCleaning;

  /// No description provided for @categoryRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get categoryRepair;

  /// No description provided for @categoryConsulting.
  ///
  /// In en, this message translates to:
  /// **'Consulting'**
  String get categoryConsulting;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categoryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get categoryDelivery;

  /// No description provided for @categoryTutoring.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get categoryTutoring;

  /// No description provided for @categoryDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get categoryDesign;

  /// No description provided for @categoryDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get categoryDevelopment;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+7 (___) ___-__-__'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get otpLabel;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit code'**
  String get otpHint;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String otpSent(Object phone);

  /// No description provided for @otpError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get otpError;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileSurname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get profileSurname;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileDescription;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRating;

  /// No description provided for @profileReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileReviews;

  /// No description provided for @profileServices.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get profileServices;

  /// No description provided for @profileNoServices.
  ///
  /// In en, this message translates to:
  /// **'You have no tasks yet'**
  String get profileNoServices;

  /// No description provided for @profileAddService.
  ///
  /// In en, this message translates to:
  /// **'Post Task'**
  String get profileAddService;

  /// No description provided for @serviceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get serviceCreateTitle;

  /// No description provided for @serviceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get serviceEditTitle;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get serviceName;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get serviceDescription;

  /// No description provided for @servicePrice.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get servicePrice;

  /// No description provided for @serviceCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get serviceCurrency;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get serviceType;

  /// No description provided for @serviceTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get serviceTags;

  /// No description provided for @serviceTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Add tags separated by commas'**
  String get serviceTagsHint;

  /// No description provided for @serviceImage.
  ///
  /// In en, this message translates to:
  /// **'Task Image'**
  String get serviceImage;

  /// No description provided for @serviceAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get serviceAddImage;

  /// No description provided for @serviceChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get serviceChangeImage;

  /// No description provided for @serviceAuthor.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get serviceAuthor;

  /// No description provided for @serviceYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get serviceYou;

  /// No description provided for @servicePublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get servicePublished;

  /// No description provided for @serviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get serviceUpdated;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesAsBuyer.
  ///
  /// In en, this message translates to:
  /// **'Как работник'**
  String get messagesAsBuyer;

  /// No description provided for @messagesAsSeller.
  ///
  /// In en, this message translates to:
  /// **'Как работодатель'**
  String get messagesAsSeller;

  /// No description provided for @messagesNoChatsBuyer.
  ///
  /// In en, this message translates to:
  /// **'You have no chats as a buyer yet\nWrite to a seller from a service card'**
  String get messagesNoChatsBuyer;

  /// No description provided for @messagesNoChatsSeller.
  ///
  /// In en, this message translates to:
  /// **'You have no chats as a seller yet\nWait for messages from buyers'**
  String get messagesNoChatsSeller;

  /// No description provided for @messagesStart.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get messagesStart;

  /// No description provided for @messagesTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messagesTypeHint;

  /// No description provided for @messagesSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get messagesSend;

  /// No description provided for @messagesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get messagesEdit;

  /// No description provided for @messagesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get messagesDelete;

  /// No description provided for @messagesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get messagesDeleteConfirm;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// No description provided for @messagesLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get messagesLoadingError;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Check entered data'**
  String get errorValidation;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'EUR'**
  String get currencyEUR;

  /// No description provided for @currencyRUB.
  ///
  /// In en, this message translates to:
  /// **'RUB'**
  String get currencyRUB;

  /// No description provided for @currencyKZT.
  ///
  /// In en, this message translates to:
  /// **'KZT'**
  String get currencyKZT;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareService.
  ///
  /// In en, this message translates to:
  /// **'Check out this task on Korst'**
  String get shareService;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get sortByDate;

  /// No description provided for @sortByPrice.
  ///
  /// In en, this message translates to:
  /// **'By Price'**
  String get sortByPrice;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'By Rating'**
  String get sortByRating;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @noMoreItems.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get noMoreItems;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @errorOops.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get errorOops;

  /// No description provided for @settingsKorstPromo.
  ///
  /// In en, this message translates to:
  /// **'Korst — services nearby.\\n\\nOpen app: korst:/// \\n'**
  String get settingsKorstPromo;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @publicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get publicProfile;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russianLanguage;

  /// No description provided for @additional.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get additional;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @trustFactor.
  ///
  /// In en, this message translates to:
  /// **'Trust Factor'**
  String get trustFactor;

  /// No description provided for @trustFactorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculated based on the number of services, reviews, and rating.'**
  String get trustFactorDesc;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @welcomeToKorst.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Korst'**
  String get welcomeToKorst;

  /// No description provided for @findServicesNearby.
  ///
  /// In en, this message translates to:
  /// **'Find the best tasks and performers nearby!'**
  String get findServicesNearby;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @yourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get yourPhoneNumber;

  /// No description provided for @weWillSendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to this number'**
  String get weWillSendVerificationCode;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @enterSmsCode.
  ///
  /// In en, this message translates to:
  /// **'Enter SMS code'**
  String get enterSmsCode;

  /// No description provided for @weSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to '**
  String get weSentCodeTo;

  /// No description provided for @profileCreatedButPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile created but photo upload failed: '**
  String get profileCreatedButPhotoFailed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @createProfileBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfileBtn;

  /// No description provided for @basicData.
  ///
  /// In en, this message translates to:
  /// **'Basic Data'**
  String get basicData;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @additionalContact.
  ///
  /// In en, this message translates to:
  /// **'Additional Contact'**
  String get additionalContact;

  /// No description provided for @errorLoadingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Loading error: '**
  String get errorLoadingPrefix;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @youHaveNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no reviews yet'**
  String get youHaveNoReviewsYet;

  /// No description provided for @errorLoadingPhotoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error loading photo: '**
  String get errorLoadingPhotoPrefix;

  /// No description provided for @noMoreData.
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMoreData;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: user not found'**
  String get errorUserNotFound;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'task'**
  String get task;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @updateTask.
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTask;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @enterBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter budget'**
  String get enterBudget;

  /// No description provided for @invalidBudget.
  ///
  /// In en, this message translates to:
  /// **'Invalid budget'**
  String get invalidBudget;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'repair, fast, urgent'**
  String get tagsHint;

  /// No description provided for @failedToCreateChatPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat: '**
  String get failedToCreateChatPrefix;

  /// No description provided for @serviceCard.
  ///
  /// In en, this message translates to:
  /// **'Service Card'**
  String get serviceCard;

  /// No description provided for @openInKorstPrefix.
  ///
  /// In en, this message translates to:
  /// **'\\n\\nOpen in Korst: '**
  String get openInKorstPrefix;

  /// No description provided for @authorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Author: '**
  String get authorPrefix;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @respondToTask.
  ///
  /// In en, this message translates to:
  /// **'Respond to task'**
  String get respondToTask;

  /// No description provided for @errorUpdatingToken.
  ///
  /// In en, this message translates to:
  /// **'Error updating token'**
  String get errorUpdatingToken;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @failedToVerifyUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify user'**
  String get failedToVerifyUser;

  /// No description provided for @invalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get invalidServerResponse;

  /// No description provided for @failedToConfirmOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm OTP'**
  String get failedToConfirmOtp;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @failedToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// No description provided for @failedToCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat'**
  String get failedToCreateChat;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @failedToEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to edit message'**
  String get failedToEditMessage;

  /// No description provided for @failedToDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete message'**
  String get failedToDeleteMessage;

  /// No description provided for @invalidServerResponseInfo.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response (info)'**
  String get invalidServerResponseInfo;

  /// No description provided for @failedToLoadUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user profile'**
  String get failedToLoadUserProfile;

  /// No description provided for @failedToSendReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to send review'**
  String get failedToSendReview;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get errorLoadingImage;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'service'**
  String get service;

  /// No description provided for @failedToLoadCards.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cards'**
  String get failedToLoadCards;

  /// No description provided for @failedToLoadCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load card'**
  String get failedToLoadCard;

  /// No description provided for @failedToCreateCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to create card'**
  String get failedToCreateCard;

  /// No description provided for @failedToUpdateCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to update card'**
  String get failedToUpdateCard;

  /// No description provided for @failedToLoadCardImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load card image'**
  String get failedToLoadCardImage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
