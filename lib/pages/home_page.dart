import 'package:b_social/components/drawer.dart';
import 'package:b_social/components/text_field.dart';
import 'package:b_social/components/wall_post.dart';
import 'package:b_social/pages/profil_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  //post massage
  void postMassage() {
    //only post if has message
    if (textController.text.isNotEmpty) {
      //store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    //clear textfield
    setState(() {
      textController.clear();
    });
  }

//Navigate To Profile Page
  void goToProfile() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfile,
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            //wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get massage
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //postingan
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  //textfield
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Write Something',
                      obscureText: false,
                    ),
                  ),

                  //post button
                  IconButton(
                      onPressed: postMassage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            //logged in as
            //Text("Logged in as: " + currentUser.email!),
          ],
        ),
      ),
    );
  }
}
