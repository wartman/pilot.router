package pilot.router;

import haxe.DynamicAccess;

@:allow(pilot.router)
class RouteContext {

  public static final ID = Type.getClassName(RouteContext);

  public var matched(default, null):Bool = false;
  public var path(default, null):String;
  public var params(default, null):DynamicAccess<Dynamic>;

  public function new() {}

  function markMatched() {
    this.matched = true;
  }

  function setPath(path) {
    matched = false;
    this.path = path;
  }

  function setParams(params) {
    this.params = params;
  }

}
