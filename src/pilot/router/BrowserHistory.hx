package pilot.router;

import pilot.Signal;
import js.Browser;

class BroswerHistory implements History {

  final onPopState:Signal<String> = new Signal();

  public function new() {
    Browser.window.addEventListener('popstate', (e) -> {
      onPopState.dispatch(getLocation());
    });
  }

  public function getLocation() {
    return Browser.location.pathname;
  }

  public function push(url:String) {
    Browser.window.history.pushState(null, null, url);
  }

  public inline function subscribe(listener) {
    return onPopState.add(listener);
  }

}
