package pilot.router;

import js.Browser;

using StringTools;
using tink.CoreApi;

class BroswerHistory implements History {

  var root:String;
  final onChangeTrigger:SignalTrigger<String>;
  public final onChange:Signal<String>;

  public function new(?root) {
    onChangeTrigger = Signal.trigger();
    onChange = onChangeTrigger.asSignal();
    this.root = root;
    Browser.window.addEventListener('popstate', (e) -> {
      onChangeTrigger.trigger(getLocation());
    });
  }

  public function push(url:String) {
    Browser.window.history.pushState(null, null, url);
    onChangeTrigger.trigger(getLocation());
  }

  public function getLocation() {
    var path = Browser.location.pathname + Browser.location.search;
    // todo: what are we actually doing with `root`.
    if (root != null && path.startsWith(root)) {
      return path.substring(root.length);
    }
    return path;
  }

  public inline function subscribe(listener) {
    return onChange.handle(listener);
  }

}
