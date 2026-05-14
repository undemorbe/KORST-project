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
  String get messagesAsBuyer => 'Как работник';

  @override
  String get messagesAsSeller => 'Как работодатель';

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
  String get errorOops => '糟糕！出了点问题';

  @override
  String get settingsKorstPromo => 'Korst — 附近的服务。\\n\\n打开应用：korst:/// \\n';

  @override
  String get myProfile => '我的个人资料';

  @override
  String get publicProfile => '公开个人资料';

  @override
  String get myReviews => '我的评论';

  @override
  String get appSettings => '应用设置';

  @override
  String get russianLanguage => '俄语';

  @override
  String get additional => '附加';

  @override
  String get rateApp => '评价应用';

  @override
  String get shareApp => '分享应用';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get statistics => '统计';

  @override
  String get services => '服务';

  @override
  String get earned => '已赚取';

  @override
  String get rating => '评分';

  @override
  String get trustFactor => '信任因子';

  @override
  String get trustFactorDesc => '基于服务数量、评论和评分计算。';

  @override
  String get user => '用户';

  @override
  String get welcomeToKorst => '欢迎来到 Korst';

  @override
  String get findServicesNearby => '寻找附近最好的任务和执行者！';

  @override
  String get start => '开始';

  @override
  String get pleaseEnterValidNumber => '请输入有效的号码';

  @override
  String get yourPhoneNumber => '您的手机号码';

  @override
  String get weWillSendVerificationCode => '我们将向此号码发送验证码';

  @override
  String get phoneNumber => '手机号码';

  @override
  String get continueAction => '继续';

  @override
  String get enterSmsCode => '输入短信验证码';

  @override
  String get weSentCodeTo => '我们向...发送了验证码：';

  @override
  String get profileCreatedButPhotoFailed => '个人资料创建成功但照片上传失败：';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get createProfile => '创建个人资料';

  @override
  String get saveChanges => '保存更改';

  @override
  String get createProfileBtn => '创建个人资料';

  @override
  String get basicData => '基本信息';

  @override
  String get firstName => '名字';

  @override
  String get enterFirstName => '输入名字';

  @override
  String get lastName => '姓氏';

  @override
  String get aboutMe => '关于我';

  @override
  String get additionalContact => '附加联系方式';

  @override
  String get errorLoadingPrefix => '加载错误：';

  @override
  String get profileNotFound => '未找到个人资料';

  @override
  String get youHaveNoReviewsYet => '您还没有评论';

  @override
  String get errorLoadingPhotoPrefix => '加载照片错误：';

  @override
  String get noMoreData => '没有更多数据';

  @override
  String get taskNotFound => '未找到任务';

  @override
  String get errorUserNotFound => '错误：未找到用户';

  @override
  String get task => '任务';

  @override
  String get editTask => '编辑任务';

  @override
  String get newTask => '新任务';

  @override
  String get updateTask => '更新任务';

  @override
  String get createTask => '创建任务';

  @override
  String get addPhoto => '添加照片';

  @override
  String get taskDetails => '任务详情';

  @override
  String get title => '标题';

  @override
  String get enterTitle => '输入标题';

  @override
  String get description => '描述';

  @override
  String get budget => '预算';

  @override
  String get enterBudget => '输入预算';

  @override
  String get invalidBudget => '无效预算';

  @override
  String get category => '类别';

  @override
  String get currency => '货币';

  @override
  String get tags => '标签';

  @override
  String get tagsHint => '维修，快速，紧急';

  @override
  String get failedToCreateChatPrefix => '创建聊天失败：';

  @override
  String get serviceCard => '服务卡片';

  @override
  String get openInKorstPrefix => '\n\n在 Korst 中打开：';

  @override
  String get authorPrefix => '作者：';

  @override
  String get you => '您';

  @override
  String get respondToTask => '回应任务';

  @override
  String get errorUpdatingToken => '更新令牌错误';

  @override
  String get failedToSendOtp => '发送 OTP 失败';

  @override
  String get failedToVerifyUser => '验证用户失败';

  @override
  String get invalidServerResponse => '无效的服务器响应';

  @override
  String get failedToConfirmOtp => '确认 OTP 失败';

  @override
  String get failedToUpdateProfile => '更新个人资料失败';

  @override
  String get failedToLoadChats => '加载聊天失败';

  @override
  String get failedToLoadMessages => '加载消息失败';

  @override
  String get failedToCreateChat => '创建聊天失败';

  @override
  String get failedToSendMessage => '发送消息失败';

  @override
  String get failedToEditMessage => '编辑消息失败';

  @override
  String get failedToDeleteMessage => '删除消息失败';

  @override
  String get invalidServerResponseInfo => '无效的服务器响应（信息）';

  @override
  String get failedToLoadUserProfile => '加载用户个人资料失败';

  @override
  String get failedToSendReview => '发送评论失败';

  @override
  String get failedToLoadProfile => '加载个人资料失败';

  @override
  String get errorLoadingImage => '加载图片错误';

  @override
  String get failedToLoadImage => '加载图片失败';

  @override
  String get service => '服务';

  @override
  String get failedToLoadCards => '加载卡片失败';

  @override
  String get failedToLoadCard => '加载卡片失败';

  @override
  String get failedToCreateCard => '创建卡片失败';

  @override
  String get failedToUpdateCard => '更新卡片失败';

  @override
  String get failedToLoadCardImage => '加载卡片图片失败';
}
