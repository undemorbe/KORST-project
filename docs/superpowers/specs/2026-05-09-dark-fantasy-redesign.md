# Dark Fantasy Redesign — Plague & Gold

## Summary

Full visual overhaul of the KORST Flutter app. Dark-only theme. Aesthetic: Plague & Gold — near-black backgrounds, tarnished gold accents, Cinzel serif headings, relic-panel cards with gold glow. Standard navigation labels.

---

## Color Palette

| Token | Hex | Role |
|---|---|---|
| `background` | `#080604` | Scaffold background |
| `surface` | `#12100A` | Card base / bottom sheet |
| `surfaceCard` | gradient `#1C1810 → #12100A` | Relic-panel card fill |
| `border` | `#5A4820` | Card border |
| `borderSubtle` | `#3A2E18` | Dividers, subtle outlines |
| `primary` | `#C49A22` | Gold accent — buttons, FAB, active nav |
| `primaryLight` | `#D4AA55` | Price text, glow source |
| `onBackground` | `#E8D4A0` | Primary text (parchment) |
| `onSurface` | `#C8B890` | Secondary text |
| `muted` | `#7A6A3A` | Tertiary / meta text |
| `shadow` | `#C49A2212` | Gold glow shadow |
| `insetHighlight` | `#6A5028` | Inset top-edge card shimmer |
| `error` | `#AA4444` | Errors, destructive |

**Background radial glow:** `radial-gradient(ellipse at 50% 0%, #1A1408 0%, #080604 65%)`  
**Animated gradient:** very slow drift between `#080604`, `#0F0C08`, `#14100A` — near-imperceptible movement.

---

## Typography

- **Page titles / AppBar titles**: `Cinzel` (Google Fonts), weight 700, letter-spacing 0.12–0.18em, uppercase, color `primaryLight`
- **Card titles / Section headings**: `Cinzel`, weight 600–700, letter-spacing 0.04–0.06em, color `onBackground`
- **Body / metadata / labels**: `Inter` (existing), unchanged weights
- **Prices**: `Cinzel` weight 700, color `primaryLight`, text-shadow glow `#C49A2250`

---

## Surface Style — Relic Panels

All cards and elevated surfaces use:
```
background: linear-gradient(135deg, #1C1810 0%, #12100A 100%)
border: 1px solid #5A4820
border-radius: 8px
box-shadow: 0 0 16px #C49A2212, inset 0 1px 0 #6A5028
```

**Glass widgets** (GlassAppBar, GlassCard) keep backdrop blur but adopt gold border `#4A3C18` and dark fill `#12100A`.

**Bottom nav**: same relic-panel treatment — gradient fill, gold border, gold active indicator dot + text-shadow glow.

---

## Theme Architecture

- **Dark theme only** — remove `lightTheme` export from `AppTheme`, force `themeMode: ThemeMode.dark` in `MaterialApp`.
- `ColorScheme.dark()` populated with Plague & Gold palette.
- `scaffoldBackgroundColor: Colors.transparent` — keep (background painted by `AnimatedGradientBackground`).
- `AppBarTheme`: transparent, Cinzel title style.
- `CardTheme`: relic gradient via custom `GlassCard` (theme-level card color set to surface).
- `FilledButton`: gold fill `#C49A22`, dark text `#080604`.
- `OutlinedButton`: gold border, gold text.
- `InputDecoration`: fill `#16130A`, border `#3A2E18`, focused border gold.
- `ChipTheme`: `#1E1A09` bg, gold border, gold selected.
- `BottomSheet`: dark fill `#16130A`, gold top border.

---

## Navigation Labels (standard)

| Index | Icon | Label |
|---|---|---|
| 0 | `home_outlined` / `home_rounded` | Главная |
| 1 | `favorite_outline` / `favorite_rounded` | Избранное |
| 2 | `chat_bubble_outline` / `chat_bubble_rounded` | Сообщения |
| 3 | `person_outline` / `person_rounded` | Профиль |

---

## Service Cards — Relic Panel Layout

Card displays (from `GET /cards/get-cards` response):
- **Image** (if `image-url` present): full-width top, height ~140px, rounded top corners
- **Title**: Cinzel font, parchment color
- **Author row**: small avatar circle + `{name} {surname}`, rating stars
- **Tags row**: gold-tinted chips
- **Price**: Cinzel, gold with glow
- **Type badge**: top-right corner, Cinzel small-caps

**Reply button** (`POST /cards/create-reply`): shown when `status == "active"` AND card is not authored by current user. "Откликнуться" — outlined gold button.

**Status badge** (from `GET /user/me` cards with status field):
- `active` → gold dot "Активно"
- `in-progress` → amber "В работе"
- `completed` → muted green "Завершено"
- `closed` → muted red "Закрыто"

**Owner actions** (visible only to card author, `status == "in-progress"`):
- Approve executor: `PUT /cards/approve-executor`
- Reject executor: `PUT /cards/reject-executor`
- Close card: `PUT /cards/close` with status options (`completed`, `closed-with-bad-result`, `reopen-with-bad-result`, `reopen-with-good-result`)

---

## Files to Modify

1. `lib/core/theme/app_colors.dart` — full Plague & Gold palette
2. `lib/core/theme/app_text_styles.dart` — Cinzel for display/headline scales
3. `lib/core/theme/app_theme.dart` — dark-only, new ColorScheme, component themes
4. `lib/core/theme/animated_gradient_background.dart` — slow dark gradient
5. `lib/core/widgets/glass.dart` — GlassCard/GlassAppBar adopt gold border/fill
6. `lib/core/widgets/app_layout.dart` — AppPageHeader uses Cinzel
7. `lib/features/main/presentation/pages/main_shell_page.dart` — nav labels + gold style
8. `lib/features/services/presentation/widgets/service_card.dart` — relic layout + reply button + status badge
9. `lib/features/services/presentation/widgets/service_card_shimmer.dart` — dark shimmer colors
10. `lib/features/services/presentation/pages/services_home_page.dart` — search bar + chips dark styling
11. `lib/main.dart` — force `ThemeMode.dark`

---

## Out of Scope

- No new features beyond reply/approve/reject/close surface-level UI
- No new routes
- No Hive model changes
- Light theme: removed (dark only)
