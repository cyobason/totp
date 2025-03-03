import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan.dart';
import 'db.dart';
import 'code.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'show.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MobileScannerController cameraController = MobileScannerController();
  String? scanResult;
  List<Map<String, dynamic>> items = [];
  bool edit = false;
  TextEditingController textIssuerController = TextEditingController();
  TextEditingController textAccountController = TextEditingController();
  bool mode = false; // true 是为当前页面显示动态验证码

  @override
  void initState() {
    super.initState();
    getMode();
    initDb();
  }

  void getMode() async {
    var prefs = await SharedPreferences.getInstance();
    var value = prefs.getBool('mode') ?? false;
    setState(() {
      mode = value;
    });
  }

  void initDb() async {
    var db = await getDb();
    await db.close();
    await loadData();
  }

  Future loadData() async {
    var db = await getDb();
    var arr = await db.query('MyAuth');
    setState(() {
      items = arr;
    });
    await db.close();
  }

  Widget listTile(dynamic item){
    var account = item['account'].toString();
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CodePage(item: item, edit: edit)),
        ).then((value){
          loadData();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Row(
                      children: [
                        Text(account.isNotEmpty ? account : '未命名', style: const TextStyle(fontSize: 20)),
                        edit ? const Icon(Icons.edit_note, size: 16) : Container(),
                      ],
                    ),
                    onTap: () async {
                      if (!edit){
                        return;
                      }
                      showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext, Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return TDInputDialog(
                            textEditingController: textAccountController,
                            title: '填写',
                            hintText: '输入账户名称',
                            rightBtn: TDDialogButtonOptions(
                                title: '确定',
                                action: () {
                                  var text = textAccountController.text;
                                  if (text.isNotEmpty){
                                    updateAccount(text, item['id']);
                                  }
                                  textAccountController.text = '';
                                  Navigator.pop(context);
                                }
                            ),
                          );
                        },
                      );
                    },
                  ),
                  InkWell(
                    child: Row(
                        children: [
                          Text(item['issuer'], style: const TextStyle(color: Colors.grey)),
                          edit ? const Icon(Icons.edit_note, size: 14) : Container(),
                        ]),
                    onTap: () async {
                      if (!edit){
                        return;
                      }
                      showGeneralDialog(
                        context: context,
                        pageBuilder: (BuildContext buildContext, Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return TDInputDialog(
                            textEditingController: textIssuerController,
                            title: '填写',
                            hintText: '输入应用名称',
                            rightBtn: TDDialogButtonOptions(
                                title: '确定',
                                action: () {
                                  var text = textIssuerController.text;
                                  if (text.isNotEmpty){
                                    updateIssuer(text, item['id']);
                                  }
                                  textIssuerController.text = '';
                                  Navigator.pop(context);
                                }
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              mode ? ShowCodePage(secretKey: item['secretKey']) :
              Icon(
                Icons.arrow_forward_ios,
                size: 20.0,
                color: Colors.grey.withOpacity(0.5),
              )
            ],
          )
      ),
    );
  }

  void updateIssuer(String text, int id) async {
    var db = await getDb();
    await db.update('MyAuth', { 'issuer': text }, where: 'id = ?', whereArgs: [id]);
    await db.close();
    loadData();
  }

  void updateAccount(String text, int id) async {
    var db = await getDb();
    await db.update('MyAuth', { 'account': text }, where: 'id = ?', whereArgs: [id]);
    await db.close();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TOTP",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2151D1),
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(Icons.swap_horiz),
            color: Colors.white,
            onPressed: () async {
              var prefs = await SharedPreferences.getInstance();
              await prefs.setBool('mode', !mode);
              setState(() {
                mode = !mode;
              });
            }
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_note),
              color: Colors.white,
              onPressed: () async {
                setState(() {
                  edit = !edit;
                });
              }
          ),
        ],
      ),
      body: ListView.builder(itemBuilder: (context, index){
        if (index < items.length - 1) {
          return Column(
            children: <Widget>[
              listTile(items[index]),
              Container(
                height: 0.5,
                color: Colors.grey.withOpacity(0.5),
              )
            ],
          );
        } else {
          return listTile(items[index]);
        }
      }, itemCount: items.length),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerPage()),
          ).then((value){
            loadData();
          });
        },
        backgroundColor: const Color(0xFF2151D1),
        foregroundColor: Colors.white,
        tooltip: '添加',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
