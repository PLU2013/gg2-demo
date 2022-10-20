import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/commons/commons.dart';
import 'package:greengrocery/ui/pages/commons/widget_blur_bg.dart';
import 'package:greengrocery/ui/pages/commons/widget_confirm_box.dart';
import 'package:greengrocery/ui/pages/products_management_page/widget_data_table.dart';
import 'package:greengrocery/ui/pages/products_management_page/widget_new_product_dialog.dart';

class ProductsMngmt extends StatefulWidget {
  final List<ProductModel> products;

  const ProductsMngmt({required this.products, Key? key}) : super(key: key);

  @override
  State<ProductsMngmt> createState() => _ProductsMngmtState();
}

class _ProductsMngmtState extends State<ProductsMngmt> {
  late ProductModel editedProduct;
  late List<ProductModel> totalProducts;
  late List<DataColumn> columnHeaders;
  late ProductModel productToDelete;

  bool saving = false;
  bool sortAscending = true;
  bool newProductDialogBoxVisible = false;
  bool confirmDeleteDialogBoxVisible = false;
  int sortColumnIndex = 0;
  bool sendUpdateProductsToAll = false;

  @override
  void initState() {
    totalProducts = widget.products;
    columnHeaders = _initColumns();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: Commons.commonAppBar(
              backBtn: !(saving |
                  newProductDialogBoxVisible |
                  confirmDeleteDialogBoxVisible),
              context: context,
              backResult: sendUpdateProductsToAll),
          body: getBody(),
          bottomNavigationBar: Container(
            alignment: Alignment.centerRight,
            height: 77,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.blueGrey, Colors.black],
                    stops: [0.0, 0.9])),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                  onPressed: (newProductDialogBoxVisible |
                          confirmDeleteDialogBoxVisible)
                      ? null
                      : () => setState(() {
                            newProductDialogBoxVisible = true;
                          }),
                  backgroundColor: (newProductDialogBoxVisible |
                          confirmDeleteDialogBoxVisible)
                      ? Colors.black12
                      : Colors.blue,
                  child: const Icon(Icons.library_add)),
            ),
          )),
    );
  }

  Widget getBody() {
    return Stack(children: [
      Column(
        children: <Widget>[
          Row(
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Gestión de Productos',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
            ],
          ),
          ProductsTable(
            columnHeaders: columnHeaders,
            productList: totalProducts,
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            saving: (status) => _saving(status),
            reSort: (columnIndex, ascending) =>
                _handleSorting(columnIndex, ascending),
            onItemLongPress: _showConfirmDialogBox,
          )
        ],
      ),
      if (newProductDialogBoxVisible || confirmDeleteDialogBoxVisible)
        BlurBg(onTap: () {
          setState(() {
            newProductDialogBoxVisible = false;
            confirmDeleteDialogBoxVisible = false;
          });
        }),
      if (newProductDialogBoxVisible)
        NewProductDialogBox(
          response: (res, product) {
            if (res) {
              _addNewProduct(product!);
            }
            setState(() {
              newProductDialogBoxVisible = false;
            });
          },
          icon: const Icon(Icons.library_add),
          cardTitle: 'Nuevo Producto',
        ),
      if (confirmDeleteDialogBoxVisible)
        ConfirmDialogBox(
            response: (res) async {
              if (res) await _deleteProduct(productToDelete);
              setState(() {
                confirmDeleteDialogBoxVisible = false;
              });
            },
            icon: const Icon(Icons.delete_forever_rounded),
            cardTitle: productToDelete.name!,
            title: 'Eliminar producto',
            info: '¿Confirma la operación?.'),
      if (saving) const Center(child: CircularProgressIndicator())
    ]);
  }

  _saving(bool status) {
    if (status && !sendUpdateProductsToAll) sendUpdateProductsToAll = true;
    setState(() {
      saving = status;
    });
  }

  List<DataColumn> _initColumns() {
    return <DataColumn>[
      DataColumn(
          onSort: ((columnIndex, ascending) =>
              _handleSorting(columnIndex, ascending)),
          label: const Text(
            'Producto',
            style: TextStyle(fontSize: 14),
          )),
      DataColumn(
          onSort: ((columnIndex, ascending) =>
              _handleSorting(columnIndex, ascending)),
          label: const Text(
            'Precio',
            style: TextStyle(fontSize: 14),
          )),
      DataColumn(
          onSort: ((columnIndex, ascending) =>
              _handleSorting(columnIndex, ascending)),
          label: const Text(
            'Unidad',
            style: TextStyle(fontSize: 14),
          )),
      DataColumn(
          onSort: ((columnIndex, ascending) =>
              _handleSorting(columnIndex, ascending)),
          label: const Text(
            'Prioridad',
            style: TextStyle(fontSize: 14),
          )),
    ];
  }

  void _handleSorting(int columnIndex, bool isAscending) {
    switch (columnIndex) {
      case 0:
        isAscending
            ? totalProducts.sort(((a, b) => a.name!.compareTo(b.name!)))
            : totalProducts.sort(((a, b) => b.name!.compareTo(a.name!)));
        break;
      case 1:
        isAscending
            ? totalProducts.sort(((a, b) => a.price!.compareTo(b.price!)))
            : totalProducts.sort(((a, b) => b.price!.compareTo(a.price!)));
        break;
      case 2:
        isAscending
            ? totalProducts.sort(((a, b) => a.unit!.compareTo(b.unit!)))
            : totalProducts.sort(((a, b) => b.unit!.compareTo(a.unit!)));
        break;
      case 3:
        isAscending
            ? totalProducts.sort(((a, b) => a.priority!.compareTo(b.priority!)))
            : totalProducts
                .sort(((a, b) => b.priority!.compareTo(a.priority!)));
        break;
    }
    setState(() {
      sortAscending = isAscending;
      sortColumnIndex = columnIndex;
      totalProducts;
    });
  }

  _addNewProduct(ProductModel product) async {
    _saving(true);
    bool res = await Repo().products.newProduct(product);
    if (res) totalProducts = await Repo().products.getProductsApi();
    ProductModel newP = totalProducts.firstWhere((p) => p.name == product.name);
    widget.products.add(newP);
    _handleSorting(sortColumnIndex, sortAscending);
    _saving(false);
  }

  _showConfirmDialogBox(product) {
    productToDelete = product;
    setState(() {
      confirmDeleteDialogBoxVisible = true;
    });
  }

  _deleteProduct(ProductModel product) async {
    _saving(true);
    bool res = await Repo().products.deleteProduct(product.id!);
    if (res) totalProducts.remove(product);
    _handleSorting(sortColumnIndex, sortAscending);
    _saving(false);
  }
}
