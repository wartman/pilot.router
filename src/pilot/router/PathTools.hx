package pilot.router;

import haxe.ds.Option;
import haxe.DynamicAccess;

using StringTools;

enum abstract LexTokenType(String) to String {
  var Open;
  var Close;
  var Pattern;
  var Name;
  var Char;
  var EscapedChar;
  var Modifier;
  var End;
}

typedef LexToken = {
  type:LexTokenType,
  index:Int,
  value:String
}

typedef ParseOptions = {
  ?delimiter:String,
  ?prefixes:String
}

typedef TokensToFunctionsOptions = {
  ?sensitive:Bool,
  ?encode:(value:String, ?token:Token)->String,
  ?validate:Bool
}

typedef TokensToEregOptions = {
  ?sensitive:Bool,
  ?strict:Bool,
  ?end:Bool,
  ?start:Bool,
  ?delimiter:String,
  ?endsWith:String,
  ?encode:(value:String)->String
}

typedef ERegToFunctionOptions = {
  ?decode:(value:String, token:Token)->String
}

typedef PathMatcher = (path:String) -> Option<{ path:String, params:DynamicAccess<Dynamic> }>;

enum Token {
  Value(value:String);
  Key(name:String, prefix:String, suffix:String, pattern:String, modifier:String);
}

/**
  Haxe adaption of https://github.com/pillarjs/path-to-regexp/blob/master/src/index.ts
**/
class PathTools {

  static function lex(str:String):Array<LexToken> {
    var tokens:Array<LexToken> = [];
    var i = 0;

    while (i < str.length) {
      var char = str.charAt(i);
      switch char {
        case '*' | '+' | '?':
          tokens.push({ type: Modifier, index: i, value: str.charAt(i++) });
        case '\\':
          tokens.push({ type: EscapedChar, index: i++, value: str.charAt(i++) });
        case '{':
          tokens.push({ type: Open, index: i, value: str.charAt(i++) });
        case '}':
          tokens.push({ type: Close, index: i, value: str.charAt(i++) });
        case ':':
          var name = '';
          var j = i + 1;
          while (j < str.length) {
            var code = str.charCodeAt(j);
            if (
              // `0-9`
              (code >= 48 && code <= 57) ||
              // `A-Z`
              (code >= 65 && code <= 90) ||
              // `a-z`
              (code >= 97 && code <= 122) ||
              // `_`
              code == 95
            ) {
              name += str.charAt(j++);
            } else {
              break;
            }
          }
          if (name.length == 0) {
            throw 'Missing parameter name at ${i}';
          }
          tokens.push({ type: Name, index: i, value: name });
          i = j;
        case '(':
          var count = 1;
          var pattern = '';
          var j = i + 1;
          if (str.charAt(j) == '?') {
            throw 'Pattern cannot start with "?" at ${j}';
          }
          while (j < str.length) {
            switch str.charAt(j) {
              case '\\':
                pattern += str.charAt(j++) + str.charAt(j++);
              case ')':
                count--;
                if (count == 0) {
                  j++;
                  break;
                }
              case '(':
                count++;
                if (str.charAt(j + 1) != '?') {
                  throw 'Capturing groups are not allowed at ${j}';
                }
                pattern += str.charAt(j++);
              default:
                pattern += str.charAt(j++);  
            }
          }
          if (count != 0) {
            throw 'Unbalanced pattern at ${i}';
          }
          if (pattern.length == 0) {
            throw 'Missing pattern at ${i}';
          }
          tokens.push({ type: Pattern, index: i, value: pattern });
          i = j;
        default:
          tokens.push({ type: Char, index: i, value: str.charAt(i++) });
      }
    }

    tokens.push({ type: End, index: i, value: '' });
    return tokens;
  }

  public static function parse(str:String, ?options:ParseOptions) {
    if (options == null) options = {};

    var tokens = lex(str);
    var prefixes = options.prefixes != null ? options.prefixes : './';
    var defaultPattern = '[^${escapeString(options.delimiter != null ? options.delimiter : "/#?")}]+?';
    var result:Array<Token> = [];
    var key = 0;
    var i = 0;
    var path = '';

    function tryConsume(type:LexTokenType):Null<String> {
      if (i < tokens.length && tokens[i].type == type) {
        return tokens[i++].value;
      }
      return null;
    }

    function tryConsumeAny(types:Array<LexTokenType>):Null<String> {
      for (type in types) {
        var value = tryConsume(type);
        if (value != null) return value;
      }
      return null;
    }

    function mustConsume(type:LexTokenType):String {
      var value = tryConsume(type);
      if (value != null) return value;
      var nextToken = tokens[i];
      throw 'Unexpected ${nextToken.type} at ${nextToken.index}, expected ${type}';
    }

    function consumeText():String {
      var result = '';
      var value:String;
      while ((value = tryConsumeAny([ Char, EscapedChar ])) != null) {
        result += value;
      }
      return result;
    }

    while (i < tokens.length) {
      var char = tryConsume(Char);
      var name = tryConsume(Name);
      var pattern = tryConsume(Pattern);

      if (name != null || pattern != null) {
        var prefix = char != null ? char : '';
        if (prefixes.indexOf(prefix) == -1) {
          path += prefix;
          prefix = '';
        }
        if (path.length != 0) {
          result.push(Value(path));
          path = '';
        }

        result.push(Key(
          name != null ? name : Std.string(key++),
          prefix,
          '',
          pattern != null ? pattern : defaultPattern,
          switch tryConsume(Modifier) {
            case null: '';
            case modifier: modifier;
          }
        ));
        continue;
      }

      var value = char != null 
        ? char
        : tryConsume(EscapedChar);
      if (value != null) {
        path += value;
        continue;
      }

      if (path.length != 0) {
        result.push(Value(path));
        path = '';
      }

      var open = tryConsume(Open);
      if (open != null) {
        var prefix = consumeText();
        var name = switch tryConsume(Name) {
          case null: '';
          case name: name;
        }
        var pattern = switch tryConsume(Pattern) {
          case null: '';
          case pattern: pattern;
        }
        var suffix = consumeText();

        mustConsume(Close);

        result.push(Key(
          if (name.length > 0) 
            name 
          else if (pattern.length > 0)
            Std.string(key++) 
          else '',
          prefix,
          suffix,
          if (name.length > 0 && pattern.length == 0) defaultPattern else pattern,
          switch tryConsume(Modifier) {
            case null: '';
            case modifier: modifier;
          }
        ));
        continue;
      }

      mustConsume(End);
    }

    return result;
  }

  public static function compile(
    str:String,
    ?options:ParseOptions & TokensToFunctionsOptions
  ) {
    if (options == null) options = {};
    return tokensToFunction(parse(str, options), options);
  }

  public static function pathToEReg(
    path:String,
    ?keys:Array<Token>,
    ?options:ParseOptions & TokensToEregOptions
  ) {
    if (options == null) options = {};
    return tokensToEreg(parse(path, options), keys, options);
  }
  
  public static function createMatcher(
    str:String,
    ?options: ParseOptions & TokensToEregOptions & ERegToFunctionOptions
  ):PathMatcher {
    if (options == null) options = {};
    var keys:Array<Token> = [];
    var re = pathToEReg(str, keys, options);
    return eRegToFunction(re, keys, options);
  }

  static function tokensToFunction(
    tokens:Array<Token>,
    options:TokensToFunctionsOptions
  ) {
    var reFlags = flags(options);
    var encode = options.encode != null
      ? options.encode
      : (x:String, _) -> x;
    var validate = options.validate != null
      ? options.validate
      : true;
    
    var matches = tokens.map(token -> switch token {
      case Value(value): 
        new EReg(value, reFlags); // ????
      case Key(_, _, _, pattern, _):
        new EReg(pattern, reFlags);
    });

    return (?data:DynamicAccess<Dynamic>) -> {
      var path = '';
      for (i in 0...tokens.length) {
        var token = tokens[i];
        switch token {
          case Value(value): path += value;
          case Key(name, prefix, suffix, pattern, modifier):
            var value = data != null
              ? data[name]
              : null;
            var optional = modifier == '?' || modifier == '*';
            var repeat = modifier == '*' || modifier == '+';

            if (Std.is(value, Array)) {
              if (!repeat) {
                throw '`Expected "${name}" to not repeat, but got an array';
              }
              var arr:Array<Dynamic> = value;

              if (arr.length == 0) {
                if (optional) continue;
                throw 'Expected "${name}" to not be empty';
              }

              for (item in arr) {
                var segment = encode(item, token);
                if (validate && !matches[i].match(segment)) {
                  throw 'Expected all "${name}" to match "${pattern}", but got "${segment}"';
                }

                path += prefix + segment + suffix;
              }

              continue;
            }

            if (Std.is(value, String) || Std.is(value, Int)) {
              var segment = encode(Std.string(value), token);
              if (validate && !matches[i].match(segment)) {
                throw 'Expected all "${name}" to match "${pattern}", but got "${segment}"';
              }

              path += prefix + segment + suffix;
              continue;
            }

            if (optional) continue;

            throw 'Expected "${name}" to be ${repeat ? 'an array' : 'a string'}';
        }
      }

      return path;
    };
  }

  static function tokensToEreg(
    tokens:Array<Token>,
    ?keys:Array<Token>,
    options:TokensToEregOptions
  ) {
    var strict = options.strict != null ? options.strict : false;
    var start = options.start != null ? options.start : true;
    var end = options.end != null ? options.end : true;
    var encode = options.encode != null ? options.encode : s -> s;
    var endsWith = '[${escapeString(options.endsWith != null ? options.endsWith : '')}]|$';
    var delimiter = '[${escapeString(options.delimiter != null ? options.delimiter : '')}]';
    var route = start != null ? '^' : '';

    for (token in tokens) switch token {
      case Value(value): route += escapeString(encode(value));
      case Key(_, prefix, suffix, pattern, modifier):
        prefix = escapeString(encode(prefix));
        suffix = escapeString(encode(suffix));

        if (pattern != null) {
          if (keys != null) keys.push(token);
          if (prefix.length > 0 || suffix.length > 0) {
            if (modifier == '+' || modifier == '*') {
              var mod = modifier == '*' ? '?' : '';
              route += '(?:${prefix}((?:${pattern})(?:${suffix}${prefix}(?:${pattern}))*)${suffix})${mod}';
            } else {
              route += '(?:${prefix}(${pattern})${suffix})${modifier}';
            }
          } else {
            route += '(${pattern})${modifier}';
          }
        } else {
          route += '(?:${prefix}${suffix})${modifier}';
        }
    }

    if (end) {
      if (!strict) route += '${delimiter}?';
      route += options.endsWith == null ? '$' : '(?=${endsWith})';
    } else {
      var endToken = tokens[tokens.length - 1];
      var isEndDelimited = switch endToken {
        case Value(value): delimiter.indexOf(value.charAt(value.length - 1)) > -1;
        default: endToken == null;
      }
      if (!strict) {
        route += '(?:${delimiter}(?=${endsWith}))?';
      }
      if (!isEndDelimited) {
        route += '(?=${delimiter}|${endsWith})';
      }
    }

    return new EReg(route, flags(options));
  }

  static function eRegToFunction(
    re:EReg,
    keys:Array<Token>,
    options:ERegToFunctionOptions
  ):PathMatcher {
    var decode = options.decode != null ? options.decode : (s, _) -> s;
    return function (path:String):Option<{ path:String, params:DynamicAccess<Dynamic> }> {
      if (re.match(path)) {
        var params:DynamicAccess<Dynamic> = {};
        for (i in 1...(keys.length + 1)) {
          var m = re.matched(i);
          if (m == null) continue;
          var key = keys[i - 1];
          switch key {
            case Value(_):
            case Key(name, prefix, suffix, _, modifier):
              if (modifier == '*' || modifier == '+') {
                params.set(name, m.split(prefix + suffix).map(value -> decode(value, key)));
              } else {
                params.set(name, decode(m, key));
              }
          }
        }
        return Some({ path: path, params: params });
      }
      return None;
    }
  }

  static function escapeString(str:String) {
    // return ~/([.+*?=^!:${}()[\]|\/\\])/g.replace(str, '\\$1');
    var chars = '\\.+*?=^!:${}()[]|/'.split('');
		for (char in chars)
			str = StringTools.replace(str, char, '\\$char');
		return str;
  }

  static function flags(options:{ sensitive:Bool }) {
    return options.sensitive ? '' : 'i';
  }

}