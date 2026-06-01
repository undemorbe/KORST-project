// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Korst';

  @override
  String get appSubtitle => 'Freelance Platform';

  @override
  String get homeTitle => 'Tasks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Theme';

  @override
  String get languageTitle => 'Language';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get serviceDetailsTitle => 'Service Details';

  @override
  String get priceLabel => 'Price';

  @override
  String priceFormat(Object price, Object currency) {
    return '$price $currency';
  }

  @override
  String get errorLoading => 'Error loading';

  @override
  String get emptyList => 'No items available';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navChats => 'Chats';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get bookingsTitle => 'My Bookings';

  @override
  String get bookNow => 'Book Now';

  @override
  String get bookingSuccess => 'Service booked successfully!';

  @override
  String get bookingDate => 'Booking Date';

  @override
  String get noFavorites => 'No favorites yet.';

  @override
  String get noBookings => 'No bookings yet.';

  @override
  String get searchHint => 'Search tasks...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noSearchResults => 'No results found';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryCleaning => 'Cleaning';

  @override
  String get categoryRepair => 'Repair';

  @override
  String get categoryConsulting => 'Consulting';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryDelivery => 'Delivery';

  @override
  String get categoryTutoring => 'Tutoring';

  @override
  String get categoryDesign => 'Design';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get authTitle => 'Welcome';

  @override
  String get authSubtitle => 'Sign in to continue';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => '+7 (___) ___-__-__';

  @override
  String get sendOtp => 'Send Code';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get otpLabel => 'Verification Code';

  @override
  String get otpHint => 'Enter 4-digit code';

  @override
  String otpSent(Object phone) {
    return 'Code sent to $phone';
  }

  @override
  String get otpError => 'Invalid code. Please try again.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileSurname => 'Surname';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDescription => 'About';

  @override
  String get profileRating => 'Rating';

  @override
  String get profileReviews => 'Reviews';

  @override
  String get profileServices => 'My Tasks';

  @override
  String get profileNoServices => 'You have no tasks yet';

  @override
  String get profileAddService => 'Post Task';

  @override
  String get serviceCreateTitle => 'Create Task';

  @override
  String get serviceEditTitle => 'Edit Task';

  @override
  String get serviceName => 'Task Name';

  @override
  String get serviceDescription => 'Description';

  @override
  String get servicePrice => 'Budget';

  @override
  String get serviceCurrency => 'Currency';

  @override
  String get serviceType => 'Type';

  @override
  String get serviceTags => 'Tags';

  @override
  String get serviceTagsHint => 'Add tags separated by commas';

  @override
  String get serviceImage => 'Task Image';

  @override
  String get serviceAddImage => 'Add Image';

  @override
  String get serviceChangeImage => 'Change Image';

  @override
  String get serviceAuthor => 'Client';

  @override
  String get serviceYou => 'You';

  @override
  String get servicePublished => 'Published';

  @override
  String get serviceUpdated => 'Updated';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesAsBuyer => 'Как работник';

  @override
  String get messagesAsSeller => 'Как работодатель';

  @override
  String get messagesNoChatsBuyer =>
      'You have no chats as a buyer yet\nWrite to a seller from a service card';

  @override
  String get messagesNoChatsSeller =>
      'You have no chats as a seller yet\nWait for messages from buyers';

  @override
  String get messagesStart => 'Start Chat';

  @override
  String get messagesTypeHint => 'Type a message...';

  @override
  String get messagesSend => 'Send';

  @override
  String get messagesEdit => 'Edit';

  @override
  String get messagesDelete => 'Delete';

  @override
  String get messagesDeleteConfirm => 'Delete this message?';

  @override
  String get messagesEmpty => 'No messages yet';

  @override
  String get messagesLoadingError => 'Failed to load messages';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorUnauthorized => 'Session expired. Please login again.';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorValidation => 'Check entered data';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get aboutApp => 'About App';

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
  String get share => 'Share';

  @override
  String get shareService => 'Check out this task on Korst';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get sortByDate => 'By Date';

  @override
  String get sortByPrice => 'By Price';

  @override
  String get sortByRating => 'By Rating';

  @override
  String get loading => 'Loading...';

  @override
  String get loadMore => 'Load More';

  @override
  String get noMoreItems => 'No more items';

  @override
  String get created => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

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
  String get findServicesNearby => 'Find the best tasks and performers nearby!';

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

  @override
  String get onboardSlide1Title => 'Welcome to Korst';

  @override
  String get onboardSlide1Subtitle =>
      'Find the best specialists and interesting tasks near you';

  @override
  String get onboardSlide2Title => 'Post Your Services';

  @override
  String get onboardSlide2Subtitle =>
      'Create service cards and find clients without intermediaries';

  @override
  String get onboardSlide3Title => 'Reply & Chat';

  @override
  String get onboardSlide3Subtitle =>
      'One click — chat with the client opens instantly. Discuss details right in the app';

  @override
  String get onboardSlide4Title => 'Ratings & Trust';

  @override
  String get onboardSlide4Subtitle =>
      'Real reviews and ratings help you choose the best performers';

  @override
  String get onboardSlide5Title => 'Everything in Real Time';

  @override
  String get onboardSlide5Subtitle =>
      'WebSocket chat with no delays and instant notifications for new messages';
}
