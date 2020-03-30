package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

typedef RouterOptions = {
  history:History,
  basename:String
} 

/**
  The Router provides context for nested Routes and
  Links. It should be on the top-level of your app.
**/
class Router extends Component {

  public static final id = Type.getClassName(Router);

  @:attribute var history:History;
  @:attribute var children:Children;
  @:attribute var basename:String = '';

  override function render() return html(
    <Provider id={id} value={ {
      history: history,
      basename: basename
    } }>
      {children}
    </Provider>
  );

}
