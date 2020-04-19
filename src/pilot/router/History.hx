package pilot.router;

using tink.CoreApi;

interface History {
  public final onChange:Signal<String>;
  public function getLocation():String;
  public function push(url:String):Void;
  public function subscribe(listener:Callback<String>):CallbackLink;
}
