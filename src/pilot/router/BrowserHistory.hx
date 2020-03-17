package pilot.router;

import pilot.Signal;
import js.Browser;

using haxe.io.Path;
using StringTools;

class BroswerHistory implements History {

  var root:String;
  final onPopState:Signal<String> = new Signal();

  public function new() {
    Browser.window.addEventListener('popstate', (e) -> {
      onPopState.dispatch(getLocation());
    });
  }

  public function setRoot(root:String) {
    this.root = root;
  }

  public function getLocation() {
    var path = Browser.location.pathname;
    if (path.startsWith(root)) {
      return path.substring(root.length);
    }
    return path;
  }

  public function push(url:String) {
    Browser.window.history.pushState(null, null, url);
  }

  public inline function subscribe(listener) {
    return onPopState.add(listener);
  }

}
