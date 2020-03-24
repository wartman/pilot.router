package pilot.router;

import haxe.DynamicAccess;
import pilot.Component;
import pilot.Context;
import pilot.WireType;
import pilot.VNode;

using pilot.router.PathTools;

class Route extends Component {
  
  @:attribute var url:String;
  @:attribute var component:WireType<Dynamic>;
  @:attribute var strict:Bool = false;
  @:attribute var sensitive:Bool = true;
  @:attribute var end:Bool = true;
  @:attribute @:optional var params:DynamicAccess<Dynamic>;
  @:attribute( inject = RouteContext.ID ) var context:RouteContext;
  var matcher:PathMatcher;

  override function render():VNode {
    if (matcher == null) {
      matcher = url.createMatcher({ 
        strict: strict,
        sensitive: sensitive,
        end: end
      });
    }
    
    return switch matcher(context.path) {
      case Some(v) if (!context.matched):
        context.markMatched();
        context.setParams(v.params);
        VComponent(component, v.params, url);
      default:
        null;
    }
  }

}
