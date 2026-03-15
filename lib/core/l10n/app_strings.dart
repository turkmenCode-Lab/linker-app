enum AppLocale { en, ru, tk }

abstract class AppStrings {
  static AppStrings of(AppLocale locale) => switch (locale) {
    AppLocale.en => _En(),
    AppLocale.ru => _Ru(),
    AppLocale.tk => _Tk(),
  };

  String get appName;
  String get welcomeBack;
  String get createAccount;
  String get signInSubtitle;
  String get registerSubtitle;
  String get email;
  String get password;
  String get age;
  String get ageOptional;
  String get signIn;
  String get signUp;
  String get noAccount;
  String get alreadyHaveAccount;
  String get emailRequired;
  String get emailInvalid;
  String get passwordTooShort;
  String get editor;
  String get convert;
  String get bulk;
  String get formatJson;
  String get minifyJson;
  String get clearEditor;
  String get signOut;
  String get cancel;
  String get options;
  String get pasteLink;
  String get supportedProtocols;
  String get convertToConfig;
  String get bulkImportTitle;
  String get bulkImportSubtitle;
  String get importAll;
  String get imported;
  String get failed;
  String get exportAsLink;
  String get copied;
  String get copy;
  String get settings;
  String get language;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get appearance;
  String get general;
  String get autoDetect;
  String get autoCopy;
  String get autoCopySubtitle;
  String get undo;
  String get redo;
  String get paste;
}

class _En extends AppStrings {
  String get appName => 'Linker';
  String get welcomeBack => 'Welcome back.';
  String get createAccount => 'Create account.';
  String get signInSubtitle => 'Sign in to manage your XRay configs';
  String get registerSubtitle => 'Join to start building configs';
  String get email => 'Email';
  String get password => 'Password';
  String get age => 'Age';
  String get ageOptional => 'Age (optional)';
  String get signIn => 'Sign in';
  String get signUp => 'Sign up';
  String get noAccount => 'No account? ';
  String get alreadyHaveAccount => 'Already got one? ';
  String get emailRequired => 'Email is required';
  String get emailInvalid => 'Enter a valid email';
  String get passwordTooShort => 'Min 6 characters bestie';
  String get editor => 'Editor';
  String get convert => 'Convert';
  String get bulk => 'Bulk';
  String get formatJson => 'Format';
  String get minifyJson => 'Minify';
  String get clearEditor => 'Clear Editor';
  String get signOut => 'Sign Out';
  String get cancel => 'Cancel';
  String get options => 'Options';
  String get pasteLink => 'Paste a share link';
  String get supportedProtocols =>
      'Supports vless://, vmess://, trojan://, ss://, hysteria2://';
  String get convertToConfig => 'Convert to Config';
  String get bulkImportTitle => 'Bulk import links';
  String get bulkImportSubtitle =>
      'One link per line — bad ones get flagged, no drama';
  String get importAll => 'Import All';
  String get imported => 'Imported';
  String get failed => 'Failed';
  String get exportAsLink => 'Export as Share Link';
  String get copied => 'Copied to clipboard ✓';
  String get copy => 'Copy';
  String get settings => 'Settings';
  String get language => 'Language';
  String get theme => 'Theme';
  String get themeSystem => 'System';
  String get themeLight => 'Light';
  String get themeDark => 'Dark';
  String get appearance => 'Appearance';
  String get general => 'General';
  String get autoDetect => 'Auto detect';
  String get autoCopy => 'Auto Copy';
  String get autoCopySubtitle =>
      'Copy config to clipboard after link conversion';
  String get undo => 'Undo';
  String get redo => 'Redo';
  String get paste => 'Paste';
}

class _Ru extends AppStrings {
  String get appName => 'Linker';
  String get welcomeBack => 'С возвращением.';
  String get createAccount => 'Создать аккаунт.';
  String get signInSubtitle => 'Войдите для управления конфигами XRay';
  String get registerSubtitle => 'Зарегистрируйтесь чтобы начать';
  String get email => 'Эл. почта';
  String get password => 'Пароль';
  String get age => 'Возраст';
  String get ageOptional => 'Возраст (необязательно)';
  String get signIn => 'Войти';
  String get signUp => 'Регистрация';
  String get noAccount => 'Нет аккаунта? ';
  String get alreadyHaveAccount => 'Уже есть? ';
  String get emailRequired => 'Введите почту';
  String get emailInvalid => 'Неверный формат почты';
  String get passwordTooShort => 'Минимум 6 символов';
  String get editor => 'Редактор';
  String get convert => 'Конвертер';
  String get bulk => 'Массово';
  String get formatJson => 'Формат';
  String get minifyJson => 'Сжать';
  String get clearEditor => 'Очистить редактор';
  String get signOut => 'Выйти';
  String get cancel => 'Отмена';
  String get options => 'Настройки';
  String get pasteLink => 'Вставьте ссылку';
  String get supportedProtocols =>
      'Поддерживает vless://, vmess://, trojan://, ss://, hysteria2://';
  String get convertToConfig => 'Конвертировать в конфиг';
  String get bulkImportTitle => 'Массовый импорт';
  String get bulkImportSubtitle =>
      'Одна ссылка на строку — плохие будут отмечены';
  String get importAll => 'Импортировать всё';
  String get imported => 'Импортировано';
  String get failed => 'Ошибок';
  String get exportAsLink => 'Экспортировать как ссылку';
  String get copied => 'Скопировано ✓';
  String get copy => 'Копия';
  String get settings => 'Настройки';
  String get language => 'Язык';
  String get theme => 'Тема';
  String get themeSystem => 'Системная';
  String get themeLight => 'Светлая';
  String get themeDark => 'Тёмная';
  String get appearance => 'Внешний вид';
  String get general => 'Основное';
  String get autoDetect => 'Авто';
  String get autoCopy => 'Авто-копирование';
  String get autoCopySubtitle => 'Копировать конфиг в буфер после конвертации';
  String get undo => 'Назад';
  String get redo => 'Вперёд';
  String get paste => 'Вставь';
}

class _Tk extends AppStrings {
  String get appName => 'Linker';
  String get welcomeBack => 'Hoş geldiňiz.';
  String get createAccount => 'Hasap döret.';
  String get signInSubtitle => 'XRay konfigurlary dolandyrmak üçin giriň';
  String get registerSubtitle => 'Başlamak üçin goşulyň';
  String get email => 'E-poçta';
  String get password => 'Açar söz';
  String get age => 'Ýaş';
  String get ageOptional => 'Ýaş (hökmany däl)';
  String get signIn => 'Giriş';
  String get signUp => 'Hasap döret';
  String get noAccount => 'Hasabyň ýokmy? ';
  String get alreadyHaveAccount => 'Hasabyň barmy? ';
  String get emailRequired => 'E-poçta girizmeli';
  String get emailInvalid => 'Dogry e-poçta girizmeli';
  String get passwordTooShort => 'Iň az 6 nyşan gerek';
  String get editor => 'Redaktor';
  String get convert => 'Öwür';
  String get bulk => 'Uly';
  String get formatJson => 'Format';
  String get minifyJson => 'Gysga';
  String get clearEditor => 'Redaktory arassala';
  String get signOut => 'Çykmak';
  String get cancel => 'Ýatyr';
  String get options => 'Sazlamalar';
  String get pasteLink => 'Paýlaşma salgysy goý';
  String get supportedProtocols =>
      'Goldanýar: vless://, vmess://, trojan://, ss://, hysteria2://';
  String get convertToConfig => 'Konfiga öwür';
  String get bulkImportTitle => 'Uly import';
  String get bulkImportSubtitle =>
      'Her setirde bir salgy — ýalňyşlar belleniler';
  String get importAll => 'Hemmesini import et';
  String get imported => 'Import edildi';
  String get failed => 'Ýalňyş';
  String get exportAsLink => 'Salgy hökmünde eksport';
  String get copied => 'Kopyalandi ✓';
  String get copy => 'Göçür';
  String get settings => 'Sazlamalar';
  String get language => 'Dil';
  String get theme => 'Tema';
  String get themeSystem => 'Ulgam';
  String get themeLight => 'Ýagty';
  String get themeDark => 'Garaňky';
  String get appearance => 'Görnüş';
  String get general => 'Esasy';
  String get autoDetect => 'Awtomatik';
  String get autoCopy => 'Awtomatik göçürme';
  String get autoCopySubtitle => 'Öwürmeden soň konfigi sahna göçür';
  String get undo => 'Yza';
  String get redo => 'Öňe';
  String get paste => 'Goý';
}
