import json
import os

with open('l10n_map.json', 'r', encoding='utf-8') as f:
    l10n_map = json.load(f)

files_to_check = [
    "lib/core/widgets/error_state.dart",
    "lib/features/settings/presentation/pages/settings_page.dart",
    "lib/features/settings/presentation/widgets/statistics_widget.dart",
    "lib/features/settings/presentation/widgets/profile_banner.dart",
    "lib/features/auth/presentation/pages/onboarding_page.dart",
    "lib/features/auth/presentation/pages/phone_number_page.dart",
    "lib/features/auth/presentation/pages/otp_page.dart",
    "lib/features/auth/presentation/pages/profile_form_page.dart",
    "lib/features/messenger/presentation/pages/chat_page.dart",
    "lib/features/users/presentation/pages/my_reviews_page.dart",
    "lib/features/users/presentation/pages/user_profile_page.dart",
    "lib/features/services/presentation/pages/services_home_page.dart",
    "lib/features/services/presentation/pages/service_deeplink_page.dart",
    "lib/features/services/presentation/pages/service_editor_page.dart",
    "lib/features/services/presentation/pages/service_details_page.dart",
    "lib/features/services/presentation/pages/my_services_page.dart",
    "lib/core/api/api_client.dart",
    "lib/features/auth/data/repositories/auth_repository_impl.dart",
    "lib/features/messenger/data/repositories/messenger_repository_impl.dart",
    "lib/features/users/data/repositories/user_profile_repository_impl.dart",
    "lib/features/services/data/repositories/service_repository_impl.dart"
]

import_statement = "import 'package:korst/l10n/generated/app_localizations.dart';"
import_statement2 = "import '../../../../l10n/generated/app_localizations.dart';"

# We need to manually adjust some files because AppLocalizations requires context.
# For repositories, we'll just replace the string with the english key string for now, or just english string.
# But wait, user said "перенеси все в l10n, и локализируй". We should use `AppLocalizations.of(context)!.key` if possible, but in repo we don't have context. Let's just put English text in repos, but we added them to arb so they can be localized later if passed context. Actually let's just use `AppLocalizations.of(context)!.key` in widgets.

def replace_in_file(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    is_widget = "presentation" in filepath or "widgets" in filepath
    needs_l10n_decl = False
    
    for key, vals in l10n_map.items():
        ru_text = vals['ru']
        
        # Exact match replacements
        if is_widget:
            # try to replace 'ru_text' with l10n.key
            # if ru_text has interpolation like $e or ${...}, we already stripped them in l10n_map?
            # Wait, in l10n_map we have: "errorLoadingPrefix": "Ошибка загрузки: "
            # So in dart it was: 'Ошибка загрузки: $e' or 'Ошибка загрузки: ${...}'
            
            # This is tricky with simple string replace.
            pass

replace_in_file("lib/features/auth/presentation/pages/onboarding_page.dart")

