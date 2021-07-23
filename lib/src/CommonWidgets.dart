import 'package:flutter/material.dart';
import 'package:keepin/pages/Post/LikeCommentShare.dart';
import 'package:keepin/pages/Post/PostPage.dart';
import 'package:keepin/pages/UserProfileDisplay.dart';
import 'package:keepin/src/models/Post.dart';

class Header extends StatelessWidget {
  const Header(this.heading);
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content);
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail);
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            SizedBox(width: 8),
            Text(
              detail,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style:
            ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
        onPressed: onPressed,
        child: child,
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
        onPressed: onPressed,
        child: child,
      );
}

class ImageButton extends StatelessWidget {
  const ImageButton(
      {this.imageLink,
      this.image,
      this.oval = true,
      this.fit = BoxFit.cover,
      this.onPressed,
      required this.size});

  final Widget? image;
  final String? imageLink;
  final void Function()? onPressed;
  final bool oval;
  final BoxFit fit;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget image = imageLink == null
        ? this.image == null
            ? defaultAvatar(size)
            : this.image!
        : Image.network(imageLink!, fit: fit);
    return GestureDetector(
      onTap: onPressed == null ? _showImage(context, image) : onPressed,
      child: Container(
        width: size,
        height: size,
        child: oval ? ClipOval(child: image) : image,
      ),
    );
  }

  static Null Function() _showImage(BuildContext context, Widget image) {
    return () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              insetPadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0),
              content: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: image,
              ));
        },
      );
    };
  }
}

class UploadImageButton extends StatelessWidget {
  const UploadImageButton({
    required this.image,
    required this.size,
    required this.onPressed,
  });

  final Widget image;
  final void Function() onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ImageButton(image: image, size: size),
        ),
        Positioned(
          right: -24,
          bottom: 1,
          child: MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: onPressed,
            color: Color(0xbbffffff),
            shape: CircleBorder(),
            child: Icon(
              Icons.upload_rounded,
              size: 22,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }
}

class TextH1 extends StatelessWidget {
  const TextH1(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
}

class TextH2 extends StatelessWidget {
  const TextH2(this.str, {this.size = 22.0});
  final String str;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          str,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          softWrap: true,
        ),
      );
}

class TextH3 extends StatelessWidget {
  const TextH3(this.str, {this.size = 18.0});
  final String str;
  final double size;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w400,
            color: Colors.blueGrey.shade700),
      );
}

class TextH4 extends StatelessWidget {
  const TextH4(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
          color: Colors.black54,
        ),
      );
}

class TextH5 extends StatelessWidget {
  const TextH5(this.str);
  final String str;
  @override
  Widget build(BuildContext context) => Text(
        str,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      );
}

Image defaultAvatar(double size) {
  return Image.asset(
    'assets/images/placeholder.png',
    width: size,
    height: size,
    fit: BoxFit.cover,
  );
}

void showError(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.red.shade300,
    content: Text(str),
  ));
}

void showSuccess(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green.shade300,
    content: Text(str),
  ));
}

void showWarning(BuildContext context, String str) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    backgroundColor: Colors.orange.shade300,
    content: Text(str),
  ));
}

/// Return a substring of time to display
TextH5 getTimeDisplay(String str) {
  return TextH5(str.substring(0, 16));
}

Widget postDetail(BuildContext context, Post post, {bool detail = true}) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 70,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ImageButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserProfileDisplay(post.posterId)));
              },
              imageLink: post.posterAvatarLink!,
              size: 46,
            ),
            SizedBox(height: 10),
            TextH4(post.posterName)
          ],
        ),
      ),
      SizedBox(width: 10),
      Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostPage(post: post))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    TextH2(post.title),
                    detail
                        ? getTimeDisplay(post.timestamp.toString())
                        : SizedBox(),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      constraints: new BoxConstraints(
                        minHeight: 40.0,
                        maxHeight: 300.0,
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.text,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            detail && post.imageLinks.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "click to view " +
                                          post.imageLinks.length.toString() +
                                          " images",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
            detail ? LikeCommentShare(post: post) : SizedBox()
          ],
        ),
      )
    ],
  );
}

class CircleInfoBuilder {
  static Widget buildCircleInfo(String url, String name, num count) {
    return Container(
      width: 130,
      height: 50,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'keepin for: $count',
                style: TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
