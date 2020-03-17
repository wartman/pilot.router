package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

class HistoryProvider extends Component {
  
  public static final ID = Type.getClassName(HistoryProvider);

  @:attribute var value:History;
  @:attribute var children:Children;

  override function render() return html(
    <Provider id={ID} value={value}>
      {children}
    </Provider>
  );

}
