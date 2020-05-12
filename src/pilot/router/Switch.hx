package pilot.router;

import haxe.DynamicAccess;

using tink.CoreApi;

/**
  The Switch provides context for active routes. When you
  set `currentUrl` it triggers a re-render and causes all nested
  Routes to check for matches. The `path` will also be updated
  by when the provided History changes (generally supplied by a
  parent Router).

  Note that we handle switching here and not in the Router itself,
  as this allows us to only update the part of the app that needs it
  (for example, we might want a Navbar component to have access to
  the History provided by the Router, but not want it to update when the
  route changes).
**/
class Switch extends State {

  @:attribute var basename:String = '';
  @:attribute var location:String = null;
  @:attribute var matched:Bool = false;
  @:attribute(consume) var router:Router;
  public var params(default, null):DynamicAccess<Dynamic>;
  var historySub:CallbackLink;

  @:init
  function subscribeToHistory() {
    if (location == null) {
      update({ location: router.history.getLocation()  }, true);
    }
    historySub = router.history.subscribe(setLocation);
  }

  @:dispose
  function disconnectFromHistory() {
    historySub.cancel();
  }

  @:transition
  public function setLocation(location:String) {
    return {
      location: location,
      matched: false
    };
  }

  @:transition(silent)
  public function markMatched() {
    return { 
      matched: true 
    };
  }

  public function preparePath(subPath:String) {
    var path = basename + subPath;
    return router.preparePath(path);
  }

  public function setParams(params) {
    this.params = params;
  }

}
