package pilot.router;

using StringTools;
using tink.CoreApi;

class StaticHistory implements History {
  
  final onChangeTrigger:SignalTrigger<String>;
  public final onChange:Signal<String>;
  var root:String = '';
  var currentUrl:String;

  public function new(?initUrl) {
    onChangeTrigger = Signal.trigger();
    onChange = onChangeTrigger.asSignal();
    currentUrl = initUrl;
  }

  public function getLocation() {
    var path = currentUrl;
    if (path.startsWith(root)) {
      return path.substring(root.length);
    }
    return path;
  }

  public function push(url:String) {
    currentUrl = url;
    onChangeTrigger.trigger(getLocation());
  }

  public inline function subscribe(listener) {
    return onChange.handle(listener);
  }

}
