package pilot.router;

import js.Browser;
import pilot.Signal;

using StringTools;

class BroswerHistory implements History {

  var root:String;
  final onChange:Signal<String> = new Signal();

  public function new(?root) {
    this.root = root;
    Browser.window.addEventListener('popstate', (e) -> {
      onChange.enqueue(getLocation());
    });
  }

  public function push(url:String) {
    Browser.window.history.pushState(null, null, url);
    onChange.enqueue(getLocation());
  }

  public function getLocation() {
    var path = Browser.location.pathname;
    // todo: what are we actually doing with `root`.
    if (root != null && path.startsWith(root)) {
      return path.substring(root.length);
    }
    return path;
  }

  public inline function subscribe(listener) {
    return onChange.add(listener);
  }

}
