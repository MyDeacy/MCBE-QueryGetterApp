import 'processor.dart';
import 'datacenter.dart';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';

class InputState extends State<MainWindow> {
  String _statusText = "\nサーバー情報がありません";

  final GlobalKey _formKey = GlobalKey();
  ConnectionData _data = ConnectionData();

  FocusNode _ipFocusNode;
  FocusNode _portFocusNode;

  void onPressed() {
    FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      runZoned(setQuery, onError: (e) {
        _updateLabel("接続エラーが検出されました");
      });
      _ipFocusNode.unfocus();
      _portFocusNode.unfocus();
    }
  }

  void _updateLabel(String text) {
    setState(() {
      _statusText = "\n" + text;
    });
  }

  void setQuery() async {
    _updateLabel("取得中です...");
    http
        .get("https://api.mcsrvstat.us/1/" + _data.ip + ":" + _data.port)
        .then((http.Response response) {
      String result = utf8.decode(response.bodyBytes);
      Map arr = jsonDecode(result);

      if (arr["offline"] != true) {
        result = "サーバー名：" +
            arr["motd"]["clean"][0] +
            "\n" +
            "バージョン：" +
            arr["version"] +
            "\n" +
            "ステータス：" +
            arr["players"]["online"].toString() +
            "/" +
            arr["players"]["max"].toString() +
            "\n" +
            "プレイヤーリスト：\n";
        arr["players"]["list"]
            .forEach((element) => result += "・" + element + " \n");
      } else {
        result = "サーバーがオフラインです";
      }
      _updateLabel(result);
    });
  }

  @override
  void initState() {
    super.initState();
    _ipFocusNode = FocusNode();
    _portFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _ipFocusNode.dispose();
    _portFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MCBE QueryGetter")),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "IP", border: OutlineInputBorder()),
                  maxLengthEnforced: true,
                  focusNode: _ipFocusNode,
                  onSaved: (String value) => _data.ip = value,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_portFocusNode),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Port(デフォルト: 19132)",
                      border: OutlineInputBorder()),
                  maxLengthEnforced: true,
                  focusNode: _portFocusNode,
                  onSaved: (String value) =>
                      _data.port = value.isEmpty ? "19132" : value,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                ),
                SizedBox(height: 32.0),
                RaisedButton(child: Text('情報を取得'), onPressed: onPressed),
                Text(
                  '$_statusText',
                ),
              ],
            ),
          )),
    );
  }
}
