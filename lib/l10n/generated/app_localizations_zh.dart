// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Korst';

  @override
  String get appSubtitle => '服务市场';

  @override
  String get homeTitle => '服务';

  @override
  String get settingsTitle => '设置';

  @override
  String get themeTitle => '主题';

  @override
  String get languageTitle => '语言';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get systemTheme => '系统';

  @override
  String get serviceDetailsTitle => '服务详情';

  @override
  String get priceLabel => '价格';

  @override
  String priceFormat(Object price, Object currency) {
    return '$price $currency';
  }

  @override
  String get errorLoading => '加载错误';

  @override
  String get emptyList => '没有可用项目';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get close => '关闭';

  @override
  String get confirm => '确认';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get navHome => '首页';

  @override
  String get navFavorites => '收藏';

  @override
  String get navChats => '聊天';

  @override
  String get navBookings => '预订';

  @override
  String get navSettings => '设置';

  @override
  String get navMessages => '消息';

  @override
  String get navProfile => '个人资料';

  @override
  String get favoritesTitle => '收藏';

  @override
  String get bookingsTitle => '我的预订';

  @override
  String get bookNow => '立即预订';

  @override
  String get bookingSuccess => '服务预订成功！';

  @override
  String get bookingDate => '预订日期';

  @override
  String get noFavorites => '还没有收藏。';

  @override
  String get noBookings => '还没有预订。';

  @override
  String get searchHint => '搜索服务...';

  @override
  String get searchResults => '搜索结果';

  @override
  String get noSearchResults => '未找到结果';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryCleaning => '清洁';

  @override
  String get categoryRepair => '维修';

  @override
  String get categoryConsulting => '咨询';

  @override
  String get categoryOther => '其他';

  @override
  String get categoryDelivery => '配送';

  @override
  String get categoryTutoring => '辅导';

  @override
  String get categoryDesign => '设计';

  @override
  String get categoryDevelopment => '开发';

  @override
  String get authTitle => '欢迎';

  @override
  String get authSubtitle => '登录以继续';

  @override
  String get phoneLabel => '手机号码';

  @override
  String get phoneHint => '+86 ___ ____ ____';

  @override
  String get sendOtp => '发送验证码';

  @override
  String get verifyOtp => '验证';

  @override
  String get otpLabel => '验证码';

  @override
  String get otpHint => '输入4位验证码';

  @override
  String otpSent(Object phone) {
    return '验证码已发送至 $phone';
  }

  @override
  String get otpError => '验证码无效，请重试。';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '确定要退出登录吗？';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileName => '姓名';

  @override
  String get profileSurname => '姓氏';

  @override
  String get profilePhone => '电话';

  @override
  String get profileEmail => '邮箱';

  @override
  String get profileDescription => '关于';

  @override
  String get profileRating => '评分';

  @override
  String get profileReviews => '评价';

  @override
  String get profileServices => '我的服务';

  @override
  String get profileNoServices => '您还没有服务';

  @override
  String get profileAddService => '添加服务';

  @override
  String get serviceCreateTitle => '创建服务';

  @override
  String get serviceEditTitle => '编辑服务';

  @override
  String get serviceName => '服务名称';

  @override
  String get serviceDescription => '描述';

  @override
  String get servicePrice => '价格';

  @override
  String get serviceCurrency => '货币';

  @override
  String get serviceType => '类型';

  @override
  String get serviceTags => '标签';

  @override
  String get serviceTagsHint => '添加标签，用逗号分隔';

  @override
  String get serviceImage => '服务图片';

  @override
  String get serviceAddImage => '添加图片';

  @override
  String get serviceChangeImage => '更换图片';

  @override
  String get serviceAuthor => '作者';

  @override
  String get serviceYou => '您';

  @override
  String get servicePublished => '已发布';

  @override
  String get serviceUpdated => '已更新';

  @override
  String get messagesTitle => '消息';

  @override
  String get messagesAsBuyer => '作为买家';

  @override
  String get messagesAsSeller => '作为卖家';

  @override
  String get messagesNoChatsBuyer => '您还没有作为买家的聊天\n从服务卡片中给卖家发消息';

  @override
  String get messagesNoChatsSeller => '您还没有作为卖家的聊天\n等待买家的消息';

  @override
  String get messagesStart => '开始聊天';

  @override
  String get messagesTypeHint => '输入消息...';

  @override
  String get messagesSend => '发送';

  @override
  String get messagesEdit => '编辑';

  @override
  String get messagesDelete => '删除';

  @override
  String get messagesDeleteConfirm => '删除此消息？';

  @override
  String get messagesEmpty => '还没有消息';

  @override
  String get messagesLoadingError => '加载消息失败';

  @override
  String get errorGeneric => '出了点问题';

  @override
  String get errorNetwork => '网络错误，请检查连接。';

  @override
  String get errorServer => '服务器错误，请稍后重试。';

  @override
  String get errorUnauthorized => '会话已过期，请重新登录。';

  @override
  String get errorNotFound => '未找到';

  @override
  String get errorValidation => '请检查输入的数据';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfUse => '使用条款';

  @override
  String get aboutApp => '关于应用';

  @override
  String get version => '版本';

  @override
  String get currencyUSD => '美元';

  @override
  String get currencyEUR => '欧元';

  @override
  String get currencyRUB => '卢布';

  @override
  String get currencyKZT => '坚戈';

  @override
  String get share => '分享';

  @override
  String get shareService => '在 Korst 上查看此服务';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get filter => '筛选';

  @override
  String get sort => '排序';

  @override
  String get sortByDate => '按日期';

  @override
  String get sortByPrice => '按价格';

  @override
  String get sortByRating => '按评分';

  @override
  String get loading => '加载中...';

  @override
  String get loadMore => '加载更多';

  @override
  String get noMoreItems => '没有更多项目';

  @override
  String get created => '创建';

  @override
  String get updated => '更新';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

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
