import 'package:flutter/material.dart';
import 'package:cratch/Utils/color_constant.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../widgets/Sizebox/sizedboxheight.dart';

// ignore: must_be_immutable
class TagsTextField extends StatefulWidget {
  List tagss;

  TagsTextField({Key? key, required this.tagss}) : super(key: key);

  @override
  State<TagsTextField> createState() => _TagsTextFieldState();
}

class _TagsTextFieldState extends State<TagsTextField> {
  late double _distanceToField;
  late TextfieldTagsController _controller;
  TextEditingController textEditingController = TextEditingController();
  bool isTapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
    textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tagsa = widget.tagss.cast<String>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: 'Tags',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        CustomSizedBoxHeight(height: 4),
        TextFieldTags(
          textfieldTagsController: _controller,
          initialTags: tagsa,
          textSeparators: const [' ', ','],
          letterCase: LetterCase.normal,
          validator: (String tag) {
            if (tag == 'php') {
              return 'No, please just no';
            } else if (_controller.getTags!.contains(tag)) {
              return 'you already entered that';
            }
            return null;
          },
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TextField(
                  controller: tec,
                  focusNode: fn,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.indigo,
                        width: 2.0,
                      ),
                    ),
                    hintText: _controller.hasTags ? '' : "Some tags",
                    hintStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: isTapped
                        ? AppColors.mainColor
                        : AppColors.fieldUnActive,
                    errorText: error,
                    suffixIconConstraints:
                        BoxConstraints(maxWidth: _distanceToField * 0.74),
                    suffixIcon: tags.isNotEmpty
                        ? SingleChildScrollView(
                            controller: sc,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: tags.map((String tag) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6F54E5),
                                      Color(0xFF373953),
                                    ],
                                    stops: [
                                      0.0608,
                                      0.9956,
                                    ],
                                    transform: GradientRotation(
                                        92.42 * (3.141592 / 180)),
                                  ),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5.0),
                                      child: InkWell(
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        onTap: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                      child: Container(
                                        height: 23,
                                        width: 23,
                                        decoration: BoxDecoration(
                                            color: AppColors.tagCancel,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: 18.0,
                                            color: AppColors.whiteA700,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        onTagDelete(tag);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList()),
                          )
                        : null,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              );
            });
          },
        ),
      ],
    );
  }
}
