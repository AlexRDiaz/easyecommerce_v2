import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/options_modal.dart';
import 'package:frontend/ui/widgets/show_error_snackbar.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Términos y Condiciones de Uso"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Última actualización: 01/01/2023\n",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Bienvenido a Easy Ecomerce. Lea atentamente estos Términos y Condiciones de Uso antes de utilizar el Sitio.\n",
            ),
            Text(
                "In tincidunt suscipit lacus, eget pellentesque dolor lacinia ac. Sed velit orci, egestas in laoreet.\nLorem ipsum dolor sit amet consectetur adipiscing, elit litora aliquam quisque. Varius tristique ullamcorper nec porta accumsan maecenas habitasse vehicula, ad luctus dapibus sed velit per euismod, neque molestie fringilla pulvinar tortor facilisis quam. At ultrices gravida duis lacus dapibus vehicula facilisi tristique magnis, nulla lectus sapien montes condimentum laoreet pulvinar sed, orci senectus hendrerit placerat ad purus elementum pretium. Sociis ligula tempus facilisi cubilia tellus volutpat, quam est cras pharetra ridiculus, consequat per himenaeos aliquet pulvinar.\n\nImperdiet tellus turpis iaculis eros quis, gravida vivamus penatibus luctus metus, ac montes neque ullamcorper. Tempus faucibus vitae diam cursus id mus aenean tortor feugiat cubilia fames primis laoreet magnis erat leo, suspendisse condimentum sociosqu orci auctor ultricies at quam augue quis integer venenatis curae porta egestas. Imperdiet sagittis netus mus nisl ut ornare sed ligula dapibus, rhoncus tempus massa velit nostra lacinia gravida pharetra tortor dignissim, sociis nam a nulla tincidunt urna vitae cubilia.\n\n"),
            Text(
              "1. Aceptación de los Términos\n\nAl acceder y utilizar el Sitio, usted acepta cumplir y estar sujeto a estos Términos. Si no está de acuerdo con estos Términos, por favor no utilice el Sitio.\n",
            ),
            Text(
              "2. Cambios en los Términos\n\nNos reservamos el derecho de modificar estos Términos en cualquier momento sin previo aviso. Los cambios entrarán en vigencia a partir de su publicación en el Sitio. Es su responsabilidad revisar regularmente estos Términos para estar al tanto de las actualizaciones. El uso continuado del Sitio después de cualquier modificación constituirá su aceptación de los Términos modificados.\n",
            ),
            Text(
              "3. Privacidad\n\nNuestra Política de Privacidad describe cómo recopilamos, usamos y protegemos su información personal. Al utilizar el Sitio, usted acepta nuestras prácticas de privacidad. Lea la Política de Privacidad detenidamente.\n",
            ),
            Text(
              "4. Propiedad Intelectual\n\nTodos los derechos de propiedad intelectual relacionados con el Sitio y su contenido son propiedad de [Nombre de la Empresa] o sus licenciantes. Usted acepta no copiar, modificar, distribuir, vender o transmitir ninguna parte del Sitio sin nuestro consentimiento por escrito.\n",
            ),
            Text(
              "5. Contenido del Usuario\n\nUsted es responsable de cualquier contenido que envíe al Sitio. Usted otorga a [Nombre de la Empresa] una licencia no exclusiva para utilizar, reproducir, modificar y distribuir dicho contenido en relación con el funcionamiento del Sitio. No se permite el contenido ilegal, difamatorio o que viole los derechos de terceros.\n",
            ),
            Text(
              "6. Limitación de Responsabilidad\n\nEn ningún caso seremos responsables por daños directos, indirectos, especiales, incidentales o consecuentes que surjan del uso o la imposibilidad de uso del Sitio.\n",
            ),
            Text(
              "7. Enlaces a Terceros\n\nEl Sitio puede contener enlaces a sitios web de terceros. No somos responsables del contenido de estos sitios ni de las prácticas de privacidad de terceros. El uso de sitios web de terceros está sujeto a sus propios términos y condiciones.\n",
            ),
            Text(
              "8.	Integer sed nisi ut libero semper consequat.\n\nLorem ipsum dolor sit amet consectetur adipiscing, elit volutpat donec nullam magna, vehicula praesent dis commodo lacus. Nunc blandit tortor gravida pretium vulputate taciti himenaeos habitant, conubia nam accumsan ultricies laoreet eget torquent, sollicitudin fames iaculis odio metus nisl mus. \nPotenti sapien eros nec justo sodales maecenas viverra ligula, platea placerat sed varius nostra quisque parturient hac ornare, porta risus lacinia penatibus dignissim morbi ut. Pellentesque vivamus porttitor duis mattis netus urna fermentum natoque class, nulla rhoncus vel tempus sociosqu interdum condimentum neque fringilla arcu, litora egestas at cum scelerisque eu integer tellus. Augue dapibus rutrum malesuada mauris nisi primis congue faucibus ridiculus pharetra, erat elementum hendrerit curabitur phasellus tempor convallis non diam.\n",
            ),
            Text(
              "Gracias por leer y aceptar estos Términos y Condiciones. Le animamos a utilizar el Sitio de manera responsable y respetuosa.\n",
            ),
          ],
        ),
      ),
    );
  }
}
