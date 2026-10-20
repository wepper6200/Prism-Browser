import 'package:flutter/widgets.dart';

/// Semantic icon set backed by Phosphor Icons (MIT, fonts vendored in
/// `assets/fonts`, see docs/DECISIONES.md). Screens never reference glyphs
/// directly, so the family can be swapped here in one place.
///
/// One weight (Regular) per hierarchy level; Fill is reserved for
/// "selected / active" states. All values are `const`, so release builds
/// tree-shake the fonts down to the glyphs actually used.
abstract final class PrismIcons {
  static const _r = 'PhosphorRegular';
  static const _f = 'PhosphorFill';

  static const IconData back = IconData(
    0xe058,
    fontFamily: _r,
    matchTextDirection: true,
  );
  static const IconData forward = IconData(
    0xe06c,
    fontFamily: _r,
    matchTextDirection: true,
  );
  static const IconData reload = IconData(0xe036, fontFamily: _r);
  static const IconData stop = IconData(0xe4f6, fontFamily: _r);
  static const IconData close = IconData(0xe4f6, fontFamily: _r);
  static const IconData add = IconData(0xe3d4, fontFamily: _r);
  static const IconData menu = IconData(0xe208, fontFamily: _r);
  static const IconData tabs = IconData(0xe464, fontFamily: _r);
  static const IconData home = IconData(0xe2c2, fontFamily: _r);
  static const IconData search = IconData(0xe30c, fontFamily: _r);
  static const IconData lock = IconData(0xe308, fontFamily: _r);
  static const IconData lockOpen = IconData(0xe30a, fontFamily: _r);
  static const IconData shield = IconData(0xe40c, fontFamily: _r);
  static const IconData shieldWarning = IconData(0xe412, fontFamily: _r);
  static const IconData bookmark = IconData(0xe0ea, fontFamily: _r);
  static const IconData bookmarkFilled = IconData(0xe0ea, fontFamily: _f);
  static const IconData history = IconData(0xe1a0, fontFamily: _r);
  static const IconData downloads = IconData(0xe20c, fontFamily: _r);
  static const IconData settings = IconData(0xe272, fontFamily: _r);
  static const IconData incognito = IconData(0xe83e, fontFamily: _r);
  static const IconData light = IconData(0xe472, fontFamily: _r);
  static const IconData dark = IconData(0xe330, fontFamily: _r);
  static const IconData system = IconData(0xe18c, fontFamily: _r);
  static const IconData sparkle = IconData(0xe6a2, fontFamily: _r);
  static const IconData check = IconData(0xe182, fontFamily: _r);
  static const IconData palette = IconData(0xe6c8, fontFamily: _r);
  static const IconData globe = IconData(0xe288, fontFamily: _r);
  static const IconData copy = IconData(0xe1ca, fontFamily: _r);
  static const IconData pin = IconData(0xe3e2, fontFamily: _r);
  static const IconData pinFilled = IconData(0xe3e2, fontFamily: _f);
  static const IconData chevronRight = IconData(
    0xe13a,
    fontFamily: _r,
    matchTextDirection: true,
  );
  static const IconData chevronLeft = IconData(
    0xe138,
    fontFamily: _r,
    matchTextDirection: true,
  );
  static const IconData delete = IconData(0xe4a6, fontFamily: _r);
  static const IconData share = IconData(0xe408, fontFamily: _r);
  static const IconData fingerprint = IconData(0xe23e, fontFamily: _r);
  static const IconData appearance = IconData(0xe6f0, fontFamily: _r);
  static const IconData phone = IconData(0xe1e0, fontFamily: _r);
  static const IconData desktop = IconData(0xe560, fontFamily: _r);
  static const IconData block = IconData(0xe3de, fontFamily: _r);
  static const IconData broom = IconData(0xec54, fontFamily: _r);
  static const IconData text = IconData(0xe6ee, fontFamily: _r);
  static const IconData reader = IconData(0xe0e6, fontFamily: _r);
  static const IconData pdf = IconData(0xe702, fontFamily: _r);
  static const IconData zoom = IconData(0xe310, fontFamily: _r);
  static const IconData warning = IconData(0xe4e2, fontFamily: _r);
  static const IconData info = IconData(0xe2ce, fontFamily: _r);
  static const IconData folder = IconData(0xe24a, fontFamily: _r);
  static const IconData folderOpen = IconData(0xe256, fontFamily: _r);
  static const IconData pause = IconData(0xe39e, fontFamily: _r);
  static const IconData play = IconData(0xe3d0, fontFamily: _r);
  static const IconData eye = IconData(0xe220, fontFamily: _r);
  static const IconData eyeSlash = IconData(0xe224, fontFamily: _r);
  static const IconData sliders = IconData(0xe432, fontFamily: _r);
  static const IconData language = IconData(0xe4a2, fontFamily: _r);
  static const IconData success = IconData(0xe184, fontFamily: _r);
  static const IconData layers = IconData(0xe466, fontFamily: _r);
  static const IconData drop = IconData(0xe210, fontFamily: _r);
  static const IconData minus = IconData(0xe32a, fontFamily: _r);
  static const IconData cookie = IconData(0xe6ca, fontFamily: _r);
  static const IconData link = IconData(0xe2e2, fontFamily: _r);
  static const IconData camera = IconData(0xe10e, fontFamily: _r);
  static const IconData microphone = IconData(0xe326, fontFamily: _r);
  static const IconData location = IconData(0xe316, fontFamily: _r);
  static const IconData notifications = IconData(0xe0ce, fontFamily: _r);
  static const IconData popups = IconData(0xe0f6, fontFamily: _r);
  static const IconData fileImage = IconData(0xea24, fontFamily: _r);
  static const IconData fileZip = IconData(0xe958, fontFamily: _r);
  static const IconData fileText = IconData(0xe23a, fontFamily: _r);
  static const IconData fileSheet = IconData(0xeb22, fontFamily: _r);
  static const IconData file = IconData(0xe230, fontFamily: _r);
  static const IconData wifi = IconData(0xe4ea, fontFamily: _r);
  static const IconData cellSignal = IconData(0xe142, fontFamily: _r);
  static const IconData battery = IconData(0xe0c0, fontFamily: _r);
  static const IconData barTop = IconData(0xe066, fontFamily: _r);
  static const IconData barBottom = IconData(0xe05c, fontFamily: _r);
  static const IconData density = IconData(0xe5a2, fontFamily: _r);
  static const IconData star = IconData(0xe46a, fontFamily: _r);
  static const IconData external = IconData(0xe5de, fontFamily: _r);
  static const IconData chevronDown = IconData(0xe136, fontFamily: _r);
  static const IconData lightning = IconData(0xe2de, fontFamily: _r);
  static const IconData more = IconData(0xe1fe, fontFamily: _r);
  static const IconData undo = IconData(0xe038, fontFamily: _r);
  static const IconData key = IconData(0xe2d6, fontFamily: _r);
  static const IconData fillQuery = IconData(
    0xe090,
    fontFamily: _r,
    matchTextDirection: true,
  );
  static const IconData lockKey = IconData(0xe2fe, fontFamily: _r);
  static const IconData clock = IconData(0xe19a, fontFamily: _r);
  static const IconData calendar = IconData(0xe10a, fontFamily: _r);
  static const IconData findInPage = IconData(0xebe0, fontFamily: _r);
  static const IconData expand = IconData(0xe0a6, fontFamily: _r);
  static const IconData hand = IconData(0xe57e, fontFamily: _r);
  static const IconData chart = IconData(0xe150, fontFamily: _r);
  static const IconData swatches = IconData(0xe5b8, fontFamily: _r);
  static const IconData eraser = IconData(0xe21e, fontFamily: _r);
  static const IconData fingerprintScan = IconData(0xe6fc, fontFamily: _r);
  static const IconData folderSimple = IconData(0xe25a, fontFamily: _r);
  static const IconData power = IconData(0xe3da, fontFamily: _r);
  static const IconData globeWorld = IconData(0xe28c, fontFamily: _r);
}
