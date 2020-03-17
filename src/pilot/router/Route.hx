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
  @:attribute @:optional var params:DynamicAccess<Dynamic>;
  @:attribute( inject = RouteContext.ID ) var context:RouteContext;
  var matcher:PathMatcher;

  @:init
  public function setup() {
    matcher = url.createMatcher();
  }

  override function render():VNode {
    return switch matcher(context.path) {
      // this seems bound to fail
      case Some(v) if (!context.matched):
        context.markMatched();
        context.setParams(v.params);
        VComponent(component, v.params, url);
      default: 
        html(<></>);
    }
  }

}
