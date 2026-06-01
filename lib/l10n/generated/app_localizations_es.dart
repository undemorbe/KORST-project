// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Korst';

  @override
  String get appSubtitle => 'Mercado de Servicios';

  @override
  String get homeTitle => 'Servicios';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get themeTitle => 'Tema';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get serviceDetailsTitle => 'Detalles del Servicio';

  @override
  String get priceLabel => 'Precio';

  @override
  String priceFormat(Object price, Object currency) {
    return '$price $currency';
  }

  @override
  String get errorLoading => 'Error al cargar';

  @override
  String get emptyList => 'No hay elementos disponibles';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Hecho';

  @override
  String get navHome => 'Inicio';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navChats => 'Chats';

  @override
  String get navBookings => 'Reservas';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get navProfile => 'Perfil';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get bookingsTitle => 'Mis Reservas';

  @override
  String get bookNow => 'Reservar Ahora';

  @override
  String get bookingSuccess => '¡Servicio reservado con éxito!';

  @override
  String get bookingDate => 'Fecha de Reserva';

  @override
  String get noFavorites => 'No hay favoritos aún.';

  @override
  String get noBookings => 'No hay reservas aún.';

  @override
  String get searchHint => 'Buscar servicios...';

  @override
  String get searchResults => 'Resultados de Búsqueda';

  @override
  String get noSearchResults => 'No se encontraron resultados';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryCleaning => 'Limpieza';

  @override
  String get categoryRepair => 'Reparación';

  @override
  String get categoryConsulting => 'Consultoría';

  @override
  String get categoryOther => 'Otros';

  @override
  String get categoryDelivery => 'Entrega';

  @override
  String get categoryTutoring => 'Tutoría';

  @override
  String get categoryDesign => 'Diseño';

  @override
  String get categoryDevelopment => 'Desarrollo';

  @override
  String get authTitle => 'Bienvenido';

  @override
  String get authSubtitle => 'Inicia sesión para continuar';

  @override
  String get phoneLabel => 'Número de Teléfono';

  @override
  String get phoneHint => '+34 ___ ___ ___';

  @override
  String get sendOtp => 'Enviar Código';

  @override
  String get verifyOtp => 'Verificar';

  @override
  String get otpLabel => 'Código de Verificación';

  @override
  String get otpHint => 'Ingresa el código de 4 dígitos';

  @override
  String otpSent(Object phone) {
    return 'Código enviado a $phone';
  }

  @override
  String get otpError => 'Código inválido. Inténtalo de nuevo.';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEdit => 'Editar Perfil';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileSurname => 'Apellido';

  @override
  String get profilePhone => 'Teléfono';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDescription => 'Acerca de';

  @override
  String get profileRating => 'Calificación';

  @override
  String get profileReviews => 'Reseñas';

  @override
  String get profileServices => 'Mis Servicios';

  @override
  String get profileNoServices => 'No tienes servicios aún';

  @override
  String get profileAddService => 'Agregar Servicio';

  @override
  String get serviceCreateTitle => 'Crear Servicio';

  @override
  String get serviceEditTitle => 'Editar Servicio';

  @override
  String get serviceName => 'Nombre del Servicio';

  @override
  String get serviceDescription => 'Descripción';

  @override
  String get servicePrice => 'Precio';

  @override
  String get serviceCurrency => 'Moneda';

  @override
  String get serviceType => 'Tipo';

  @override
  String get serviceTags => 'Etiquetas';

  @override
  String get serviceTagsHint => 'Agrega etiquetas separadas por comas';

  @override
  String get serviceImage => 'Imagen del Servicio';

  @override
  String get serviceAddImage => 'Agregar Imagen';

  @override
  String get serviceChangeImage => 'Cambiar Imagen';

  @override
  String get serviceAuthor => 'Autor';

  @override
  String get serviceYou => 'Tú';

  @override
  String get servicePublished => 'Publicado';

  @override
  String get serviceUpdated => 'Actualizado';

  @override
  String get messagesTitle => 'Mensajes';

  @override
  String get messagesAsBuyer => 'Как работник';

  @override
  String get messagesAsSeller => 'Как работодатель';

  @override
  String get messagesNoChatsBuyer =>
      'No tienes chats como comprador aún\nEscribe a un vendedor desde una tarjeta de servicio';

  @override
  String get messagesNoChatsSeller =>
      'No tienes chats como vendedor aún\nEspera mensajes de compradores';

  @override
  String get messagesStart => 'Iniciar Chat';

  @override
  String get messagesTypeHint => 'Escribe un mensaje...';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesEdit => 'Editar';

  @override
  String get messagesDelete => 'Eliminar';

  @override
  String get messagesDeleteConfirm => '¿Eliminar este mensaje?';

  @override
  String get messagesEmpty => 'No hay mensajes aún';

  @override
  String get messagesLoadingError => 'Error al cargar mensajes';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get errorNetwork => 'Error de red. Verifica tu conexión.';

  @override
  String get errorServer => 'Error del servidor. Inténtalo más tarde.';

  @override
  String get errorUnauthorized => 'Sesión expirada. Inicia sesión de nuevo.';

  @override
  String get errorNotFound => 'No encontrado';

  @override
  String get errorValidation => 'Verifica los datos ingresados';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get aboutApp => 'Acerca de la App';

  @override
  String get version => 'Versión';

  @override
  String get currencyUSD => 'USD';

  @override
  String get currencyEUR => 'EUR';

  @override
  String get currencyRUB => 'RUB';

  @override
  String get currencyKZT => 'KZT';

  @override
  String get share => 'Compartir';

  @override
  String get shareService => 'Mira este servicio en Korst';

  @override
  String get copied => 'Copiado al portapapeles';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortByDate => 'Por Fecha';

  @override
  String get sortByPrice => 'Por Precio';

  @override
  String get sortByRating => 'Por Calificación';

  @override
  String get loading => 'Cargando...';

  @override
  String get loadMore => 'Cargar Más';

  @override
  String get noMoreItems => 'No hay más elementos';

  @override
  String get created => 'Creado';

  @override
  String get updated => 'Actualizado';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

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
  String get onboardSlide1Title => 'Bienvenido a Korst';

  @override
  String get onboardSlide1Subtitle =>
      'Encuentra a los mejores especialistas y tareas cerca de ti';

  @override
  String get onboardSlide2Title => 'Publica tus servicios';

  @override
  String get onboardSlide2Subtitle =>
      'Crea tarjetas de servicio y encuentra clientes sin intermediarios';

  @override
  String get onboardSlide3Title => 'Responde y chatea';

  @override
  String get onboardSlide3Subtitle =>
      'Un clic — el chat con el cliente se abre al instante en la app';

  @override
  String get onboardSlide4Title => 'Calificaciones y confianza';

  @override
  String get onboardSlide4Subtitle =>
      'Las reseñas reales te ayudan a elegir a los mejores ejecutores';

  @override
  String get onboardSlide5Title => 'Todo en tiempo real';

  @override
  String get onboardSlide5Subtitle =>
      'Chat WebSocket sin retrasos y notificaciones instantáneas de nuevos mensajes';
}
