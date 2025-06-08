import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/trabajadores/func/cascade_manager.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';

class TrabajadoresSearchBar extends StatefulWidget {
  const TrabajadoresSearchBar({
    super.key
  });

  @override
  State<TrabajadoresSearchBar> createState() => _TrabajadoresSearchBarState();
}

class _TrabajadoresSearchBarState extends State<TrabajadoresSearchBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller){
          return SizedBox(
            height: normalPadding * 2.5, // Limita el alto aquí
            child: SearchBar(
              controller: controller,
              padding: WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: normalPadding),
              ),
              onTap: (){
                CascadeManager.instance.closeActive();
                controller.openView();
              },
              onChanged: (_) {
                CascadeManager.instance.closeActive();
                controller.openView();
              },
              leading: const Icon(Icons.search),
            ),
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          return List<ListTile>.generate(5, (int index) {
            final String item = 'Item: ${index + 1}';
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  controller.closeView(item);
                });
              },
            );
          });
        },
      ),
    );
  }
}