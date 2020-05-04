package pilot.router;

import haxe.DynamicAccess;
import pilot.Component;
import pilot.Context;
import pilot.WireType;
import pilot.VNode;

using pilot.router.PathTools;

class Route extends Component {
  
  @:attribute var url:String;
  @:attribute var to:RouteTarget;
  @:attribute var strict:Bool = false;
  @:attribute var sensitive:Bool = true;
  @:attribute var end:Bool = true;
  @:attribute(optional) var data:DynamicAccess<Dynamic>;
  @:attribute(consume) var router:Router;
  @:attribute(consume) var context:Switch;
  var matcher:PathMatcher;

  @:init
  function createMatcher() {
    var parsedUrl = url == '*' 
      ? '(.)*' 
      : router.basename + url;
    trace(parsedUrl);
    matcher = parsedUrl.createMatcher({
      strict: strict,
      sensitive: sensitive,
      end: end
    });
  }

  override function render():VNode {
    return switch matcher(context.path) {
      case Some(v) if (!context.matched):
        context.markMatched();
        context.setParams(v.params);
        to(createAttributes(v.params));
      default:
        null;
    }
  }

  function createAttributes(params:Dynamic) {
    Reflect.setField(params, '__matchedPath', context.path);
    if (data != null) {
      var d = data.copy();
      for (f in Reflect.fields(params)) {
        d.set(f, Reflect.field(params, f));
      }
      return d;
    }
    return params;
  }

}

@:callable
private abstract RouteTarget((props:Dynamic)->VNode) from (props:Dynamic)->VNode {
  
  @:from public static inline function ofWireType(type:WireType<Dynamic>):RouteTarget {
    return props -> VComponent(type, props);
  }

}
