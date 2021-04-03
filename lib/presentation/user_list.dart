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
  /// keys which we needed on refresh widget and scafold key for the snackbar
  GlobalKey<RefreshIndicatorState> refreshKey;
  GlobalKey<ScaffoldState> _scaffoldKey;
  bool isLoading = false;

  APIService http;
  ListUserResponse listUserResponse;
  List<User> users;

  ///geting users
  Future getListUser() async {
    Response response;
    try {
      isLoading = true;

      ///using service which i created in sevies
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

  ///deleting user
  Future deleteUser(String id) async {
    Response response;

    ///using service which i created in sevies
    response = await http.delete('api/users/2/' + id);
  }

  ///Using inti to initialize required data on boot
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
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
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
                          return await dialogDeleteConfirm(
                              user.id.toString());
                        },
                        background: deleteBg(),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30.0,
                              backgroundImage:
                              NetworkImage(user.avatar),
                              backgroundColor: Colors.transparent,
                            ),
                            tileColor: Colors.red[200],
                            title: Text(
                                '${user.firstName} ${user.lastName}',
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

  /// background widget when deleting the user
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

  ///reload feature
  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    getListUser();
    return null;
  }

  ///alert box to delete the user
  Future dialogDeleteConfirm(String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          title: Text('Delete User'),
          titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          content: Text('Are you Sure?'),
          actions: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .90,
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
                        deleteUser(userId).whenComplete(
                                () {
                              Navigator.of(context).pop(true);
                              displaySnackBar
                                ('your user is deleted');
                            });
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
        ) ??
            false;
      },
    );
  }

  displaySnackBar(text) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
