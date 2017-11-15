import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

@Component(
    selector: 'home',
    styleUrls: const ['home.css'],
    templateUrl: 'home_component.html',
    directives: const [
      CORE_DIRECTIVES,
      ROUTER_DIRECTIVES
    ]
)
class HomeComponent implements OnInit {

  @override
  ngOnInit() {

  }
}