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
  @:attribute @:optional var data:DynamicAccess<Dynamic>;
  @:attribute( inject = Router.id ) var options:Router.RouterOptions;
  @:attribute( inject = RouteContext.id ) var context:RouteContext;
  var matcher:PathMatcher;

  override function render():VNode {
    if (matcher == null) createMatcher();
    return switch matcher(context.path) {
      case Some(v) if (!context.matched):
        context.markMatched();
        context.setParams(v.params);
        to(createAttributes(v.params));
      default:
        null;
    }
  }

  function createMatcher() {
    if (matcher == null) {
      var parsedUrl = url == '*' 
        ? '(.)*' 
        : options.basename + url;
      matcher = parsedUrl.createMatcher({
        strict: strict,
        sensitive: sensitive,
        end: end
      });
    }
  }

  function createAttributes(params:Dynamic) {
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
