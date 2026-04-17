import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:collection/collection.dart';
import '../../../controller/network_controller.dart';
import '../../../model/network_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/measureWidgetHeight.dart';
import 'card.dart';
import 'package:graphview/graphview.dart';

class CustomEdgeRenderer extends EdgeRenderer {
  @override
  void renderEdge(Canvas canvas, Edge edge, Paint paint) {
    var sourceNode = edge.source;
    var destNode = edge.destination;

    // 1. MANTENEMOS TU MATEMÁTICA PERFECTA
    double startX = sourceNode.x + (sourceNode.width / 2);
    double startY = sourceNode.y + sourceNode.height;
    double endX = destNode.x + (destNode.width / 2);
    double endY = destNode.y;

    // Mantén el gap (8px para mayor limpieza visual)
    startY += 8;
    endY -= 8;

    if (startY < endY) {
      // 2. ESTILIZAMOS LA LÍNEA (Más sutil y premium)
      paint.color =
          const Color(0xFF00FF88).withOpacity(0.4); // Verde neón translúcido
      paint.strokeWidth = 1.5; // Grosor elegante
      paint.style = PaintingStyle.stroke;

      // 3. LA MAGIA: Trazar curva suave (S-Curve)
      Path path = Path();
      path.moveTo(startX, startY);

      // Punto medio para la curvatura
      double controlPointY = startY + (endY - startY) / 2;

      path.cubicTo(
        startX, controlPointY, // Control 1: Tira hacia abajo desde el padre
        endX, controlPointY, // Control 2: Tira hacia arriba desde el hijo
        endX, endY, // Punto final
      );

      canvas.drawPath(path, paint);
    }
  }
}

class NetworkListView extends StatefulWidget {
  const NetworkListView({super.key, required this.controller});

  final NetworkController controller;

  @override
  State<NetworkListView> createState() => _NetworkListViewState();
}

class _NetworkListViewState extends State<NetworkListView> {
  final TransformationController _transformationController =
      TransformationController();
  List<Userslist> finalUserList = [];
  bool nodegeneratorBuilt = false;
  List<List<int>> nodeModel = [];
  int childLevel = 0;
  double widgetScale = 0;
  var widgetHeight = Size.zero;


  listBuilder(List<Userslist> userlist) {
    try {
      finalUserList = [];
      nodeModel = [];
      childLevel = 0;

      // REQUERIMIENTO V10.1: Si la lista de referidos está vacía, no inventamos nodos.
      if (userlist.isEmpty) {
        return;
      }

      listBuilderSub(userlist, 0);
      print('✅ Red cargada: Perfil nuevo sin afiliados.');
    } catch (e) {
      finalUserList = [];
      nodeModel = [];
    }
  }

  listBuilderSub(List<Userslist> userlist, int parentIndex) {
    for (int i = 0; i < userlist.length; i++) {
      final String currentName = userlist[i].name.toLowerCase();
      
      // v1.3.0: Ignorar nodo técnico "Root" - Elevamos a sus hijos al nivel del padre
      if (currentName.contains("root")) {
        if (userlist[i].children.isNotEmpty) {
          listBuilderSub(userlist[i].children, parentIndex);
        }
        continue;
      }

      finalUserList.add(userlist[i]);
      int currentIndex = finalUserList.length; // 1-based index

      // Conectar con el padre si existe (excepto el nodo raíz absoluto)
      if (parentIndex != 0) {
        nodeModel.add([
          parentIndex,
          currentIndex,
        ]);
      }

      // Recursividad para hijos reales
      if (userlist[i].children.isNotEmpty) {
        listBuilderSub(userlist[i].children, currentIndex);
      }
    }
  }

  splitName(String name, int part) {
    try {
      int idx = name.indexOf("<");
      int idx2 = name.indexOf("src='");
      int idx3 = name.indexOf("'>");
      if (idx == -1 || idx2 == -1 || idx3 == -1) {
        return part == 1 ? name : '';
      }
      List parts = [
        name.substring(0, idx).trim(),
        name.substring(idx2 + 5, idx3).trim(),
      ];
      return part == 1 ? parts[0] : parts[1];
    } catch (e) {
      return part == 1 ? name : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width; // calculate the scale factor

    // Add null check
    if (widget.controller.networkData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    var netModel = widget.controller.networkData!.data.userslist;
    listBuilder(netModel);
    if (nodegeneratorBuilt == false) {
      Future.delayed(const Duration(milliseconds: 300), () {
        nodegenerator();
      });
      nodegeneratorBuilt = true;
    }

    return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double childHeight = constraints.maxHeight;
        double scale = (MediaQuery.of(context).size.height-300) / childHeight;

        return Stack(
          children: [
            InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 2.0,
          transformationController: _transformationController,
          onInteractionEnd: (details) {
            // Details.scale can give values below 0.5 or above 2.0 and resets to 1
            // Use the Controller Matrix4 to get the correct scale.
            double correctScaleValue =
                _transformationController.value.getMaxScaleOnAxis();
          },
          onInteractionUpdate: (ScaleUpdateDetails details) {
            // get the scale from the ScaleUpdateDetails callback
            var myScale = details.scale;
          },
          child: OverflowBox(
              alignment: Alignment.center,
              minWidth: 0.0,
              minHeight: 0.0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.scale(
                scale: scale,
                child: finalUserList.length == 1
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nodo Raíz: Embajadores X
                          NetworkCard(
                            data: Userslist(
                              name: "Embajadores X",
                              children: [],
                              rank: "Corporativo",
                              photoUrl: "null",
                            ),
                          ),
                          // Línea de conexión
                          Container(
                            width: 1.5,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF00FF88).withOpacity(0.5),
                                  const Color(0xFF00FF88).withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          // Nodo Usuario: Haniel
                          NetworkCard(data: finalUserList[0]),
                        ],
                      )
                    : MeasureSize(
                        onChange: (size) {
                          setState(() {
                            widgetHeight = size;
                          });
                        },
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(
                              builder, CustomEdgeRenderer()),
                          paint: Paint()
                            ..color = AppColor.appPrimary
                            ..strokeWidth = 2
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            // I can decide what widget should be shown here based on the id
                            var a = node.key!.value as int;
                            return NetworkCard(data: finalUserList[a - 1]);
                          },
                        ),
                      ),
              )),
            ),
            // BOTÓN MI UBICACIÓN (Focus Me)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.small(
                onPressed: () => _searchAndCenter("haniel"),
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                elevation: 6,
                child: const Icon(Icons.my_location, size: 20),
              ),
            ),
          ],
        );
      });
  }

  final Graph graph = Graph()..isTree = true;

  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  nodegenerator() {
    List<Node> nodes = [];
    nodes = List.generate(finalUserList.length, (i) => Node.Id(i + 1));

// edges represented as nested list
    List<List<int>> edges = [];
    edges = nodeModel;

    for (var edge in edges) {
      graph.addEdge(nodes[edge[0] - 1], nodes[edge[1] - 1]);
    }

    builder
      ..siblingSeparation = (60)
      ..levelSeparation = (80)
      ..subtreeSeparation = (100)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.networkData != null) {
      var netModel = widget.controller.networkData!.data.userslist;
      listBuilder(netModel);
      nodegenerator();
    }
    // TAREA: Árbol reestructurado (v1.2.9)
    print("🌳 [NETWORK UI] Texto corto 'EX' aplicado, botón de ubicación activo y zoom out ampliado.");
  }

  void _searchAndCenter(String query) {
    for (int i = 0; i < finalUserList.length; i++) {
      if (finalUserList[i].name.toLowerCase().contains(query.toLowerCase())) {
        // Encontrar nodo en el grafo
        final node = graph.nodes.firstWhereOrNull((n) => (n.key!.value as int) == (i + 1));
        if (node != null) {
          // Centrar InteractiveViewer en las coordenadas del nodo
          final x = node.x;
          final y = node.y;
          
          final double scale = _transformationController.value.getMaxScaleOnAxis();
          final double viewWidth = MediaQuery.of(context).size.width;
          final double viewHeight = MediaQuery.of(context).size.height;

          final Matrix4 matrix = Matrix4.identity()
            ..scale(scale)
            ..translate(
              -(x + 80) + (viewWidth / (2 * scale)), 
              -(y + 100) + (viewHeight / (2 * scale))
            );

          _transformationController.value = matrix;
          break; // Centrar en el primero encontrado
        }
      }
    }
  }
}
