import 'dart:math' as math;

/// Instant arithmetic answers for Prism Search ("2+2*3", "(1,5 + 2) ^ 2",
/// "15% * 80"). Pure Dart recursive-descent parser: no eval, no network.
abstract final class Calculator {
  static final _allowed = RegExp(r'^[0-9\s.,+\-*/×÷^%()=]+$');
  static final _hasOperator = RegExp(r'[0-9)%]\s*[+\-*/×÷^]\s*[-(0-9.,]');

  // Dates and phone-like numbers are not sums: 2026-10-20, 8-800-555-35-35.
  static final _dashed = RegExp(r'^\d+(-\d+){2,}$');

  /// The value of [input] when it is an arithmetic expression with at least
  /// one binary operator, otherwise null (plain numbers are not answers).
  static double? tryEvaluate(String input) {
    var s = input.trim();
    if (s.endsWith('=')) s = s.substring(0, s.length - 1).trim();
    if (s.isEmpty || s.length > 200) return null;
    if (!_allowed.hasMatch(s) || !_hasOperator.hasMatch(s)) return null;
    if (_dashed.hasMatch(s)) return null;
    // A comma is a decimal separator ("1,5"), never a thousands one.
    s = s.replaceAll(',', '.').replaceAll(RegExp(r'\s+'), '');
    try {
      final p = _Parser(s);
      final v = p.expression();
      if (!p.done || v.isNaN || v.isInfinite) return null;
      return v;
    } on FormatException {
      return null;
    }
  }
}

class _Parser {
  _Parser(this.s);

  final String s;
  int i = 0;

  bool get done => i == s.length;

  String? get _peek => i < s.length ? s[i] : null;

  bool _eat(String c) {
    if (_peek == c) {
      i++;
      return true;
    }
    return false;
  }

  // expression := term (('+' | '-') term)*
  double expression() {
    var v = term();
    while (true) {
      if (_eat('+')) {
        v += term();
      } else if (_eat('-')) {
        v -= term();
      } else {
        return v;
      }
    }
  }

  // term := power (('*' | '×' | '/' | '÷') power)*
  double term() {
    var v = power();
    while (true) {
      if (_eat('*') || _eat('×')) {
        v *= power();
      } else if (_eat('/') || _eat('÷')) {
        final d = power();
        if (d == 0) throw const FormatException('division by zero');
        v /= d;
      } else {
        return v;
      }
    }
  }

  // power := unary ('^' power)?   (right-associative)
  double power() {
    final base = unary();
    if (_eat('^')) {
      final e = power();
      return _pow(base, e);
    }
    return base;
  }

  // unary := ('-' | '+') unary | postfix
  double unary() {
    if (_eat('-')) return -unary();
    if (_eat('+')) return unary();
    return postfix();
  }

  // postfix := primary '%'?
  double postfix() {
    final v = primary();
    return _eat('%') ? v / 100 : v;
  }

  double primary() {
    if (_eat('(')) {
      final v = expression();
      if (!_eat(')')) throw const FormatException('missing )');
      return v;
    }
    final start = i;
    while (i < s.length && RegExp(r'[0-9.]').hasMatch(s[i])) {
      i++;
    }
    if (start == i) throw const FormatException('number expected');
    final n = double.tryParse(s.substring(start, i));
    if (n == null) throw const FormatException('bad number');
    return n;
  }

  static double _pow(double b, double e) {
    if (e.abs() > 1000) throw const FormatException('exponent too large');
    final r = math.pow(b, e).toDouble();
    if (r.isNaN) throw const FormatException('complex result');
    return r;
  }
}
