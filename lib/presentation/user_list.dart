import 'package:b2cinfo/model/list_user_response.dart';
import 'package:b2cinfo/model/user.dart';
import 'package:b2cinfo/services/api_services.dart';
import 'package:b2cinfo/utils/styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  GlobalKey<ScaffoldState> _scaffoldKey;
  bool isLoading = false;

  APIService http;
  ListUserResponse listUserResponse;
  List<User> users;

  Future getListUser() async {
    Response response;
    try {
      isLoading = true;

      response = await http.getRequest("/api/users?page=2");

      isLoading = false;

      if (response.statusCode == 200) {
        setState(() {
          listUserResponse = ListUserResponse.fromJson(response.data);
          users = listUserResponse.users;
        });
      } else {
        print("Connection problem");
      }
    } on Exception catch (e) {
      isLoading = false;
      print(e);
    }
  }
Future deleteUser(String id) async{
    Response response;
    response = await http.delete('api/users/2/' + id);
}
  @override
  void initState() {
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    http = APIService();

    getListUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cloud = Provider.of<List<Cloud>>(context) ?? [];
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'b2c Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await refreshList();
        },
        child: SingleChildScrollView(physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Styles.initialgrad, Styles.finalgred]),
                backgroundBlendMode: BlendMode.darken),
            child: Column(
              children: [
                Container(
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'Please pull down to refresh List',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 05,
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : users != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: users.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Dismissible(
                                  key: Key(user.id.toString()),
                                  /// todo delete user
                                  confirmDismiss: (direction) async {
                                    return await dialogDeleteConfirm(user.id.toString());
                                  },

                                  background: deleteBg(),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading:CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage:
                                        NetworkImage(user.avatar),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      tileColor: Colors.red[200],
                                      title: Text('${user.firstName} ${user.lastName}',
                                          style:
                                              TextStyle(color: Colors.white)),

                                    ),
                                  ));
                            },
                          )
                        : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget deleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.red,
      child: Icon(
        Icons.auto_delete,
        color: Colors.white,
      ),
    );
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    getListUser();
    return null;
  }
  Future dialogDeleteConfirm(String userId) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          title: Text('Delete User'),
          titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          content:  Text('Are you Sure?'),
          actions: [
            Container(
              width: MediaQuery.of(context).size.width * .90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        deleteUser(userId).whenComplete(() => Navigator.of(context).pop(true));
                        
                      }),
                  InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          color: Colors.green,
                        ),
                      ),
                      onTap: () {
                        getListUser();
                        Navigator.of(context).pop(false);
                      }),
                ],
              ),
            ),
          ],
        )?? false;
      },
    );
  }

  displaySnackBar(text) {
    final snackBar = SnackBar(content: Text(text));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
