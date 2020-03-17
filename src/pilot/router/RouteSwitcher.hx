package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Signal;
import pilot.VNodeValue;

class RouteSwitcher extends Component {

  @:attribute var children:Children;
  @:attribute var currentUrl:String = '/';
  @:attribute( inject = HistoryProvider.ID ) var history:History;
  var subscribers:Array<Route> = [];
  var historySub:SignalSubscription<String>;

  @:init
  function subscribeToHistory() {
    __attrs.currentUrl = history.getLocation();
    historySub = history.subscribe(setCurrentUrl);
  }

  @:dispose
  function disconnectHistory() {
    historySub.cancel();
  }

  @:update
  public function setCurrentUrl(url:String) {
    return { currentUrl: url };
  }

  override function render() {
    return html(
      <RouteContextProvider url={currentUrl}>
        {children}
      </RouteContextProvider>
    );
  }

}
