import 'package:flutter/material.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/detail_popup_page.dart';

class PopupCarouselDialog extends StatefulWidget {
  final List<PopupModel> popupModels;
  final UserModel? userModel;

  const PopupCarouselDialog(
      {Key? key, required this.popupModels, this.userModel})
      : super(key: key);

  @override
  _PopupCarouselDialogState createState() => _PopupCarouselDialogState();
}

class _PopupCarouselDialogState extends State<PopupCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void routeToDetail(PopupModel popupModel) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext buildContext) => DetailPopup(
        popupModel: popupModel,
        userModel: widget.userModel,
      ),
    ));
  }

  void routeToHome() {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext buildContext) => MyService(
        userModel: widget.userModel,
              ),
    ));
  }

  Widget popupPage(PopupModel item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if ((item.detail ?? '').isNotEmpty)
            Text(
                item.detail!
                    .replaceAll('\r\n', '\n')
                    .replaceAll('\\n', '\n'),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0, color: Colors.black87)),
          if ((item.photo ?? '').isNotEmpty) ...[
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => routeToDetail(item),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(item.photo!, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PopupModel> items = widget.popupModels;
    PopupModel current = items[_currentIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(current.subject ?? '',
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: MyStyle().textColor)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => routeToHome(),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: 400.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (BuildContext context, int index) =>
                      popupPage(items[index]),
                ),
              ),
              if (items.length > 1) ...[
                SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: _currentIndex > 0
                          ? () => _pageController.previousPage(
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut)
                          : null,
                    ),
                    ...List.generate(items.length, (int index) {
                      bool active = index == _currentIndex;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 3.0),
                        width: active ? 18.0 : 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color:
                              active ? MyStyle().mainColor : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      );
                    }),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: _currentIndex < items.length - 1
                          ? () => _pageController.nextPage(
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeInOut)
                          : null,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 6.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => routeToDetail(current),
                      child: Text('อ่านต่อ',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () => routeToHome(),
                      child: Text('ปิด'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
