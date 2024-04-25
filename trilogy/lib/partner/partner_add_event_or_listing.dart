import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// This class is a widget that allows the partner to create a listing or an event.
class PartnerAddEventOrListing extends StatefulWidget {
  const PartnerAddEventOrListing({Key? key, required this.user})
      : super(key: key);
  final GoogleSignInAccount user;

  @override
  State<PartnerAddEventOrListing> createState() =>
      _PartnerAddEventOrListingState();
}

class _PartnerAddEventOrListingState extends State<PartnerAddEventOrListing> {
  List<String> dropdownItems = ['Create New Listing', 'Create New Event'];
  String? selectedDropdownItem = 'Create New Listing';
  List<String> typeDropdownItems = ['Job', 'Internship', 'Volunteer'];
  String? selectedTypeDropdownItem = 'Job';
  TextEditingController listingTitleController = TextEditingController();
  TextEditingController listingDescriptionController = TextEditingController();
  TextEditingController listingAddressController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController eventAddressController = TextEditingController();

  Map<String, IconData> itemIcons = {
    'Job': Icons.business_center_outlined,
    'Internship': Icons.workspace_premium,
    'Volunteer': Icons.volunteer_activism_outlined
  };
  List<String> selectedGradeLevels = [];
  String deadline = 'Select Application Deadline';
  String eventStartDate = 'Select Start Date and Time';
  String eventEndDate = 'Select End Date and Time';
  String pdfDownloadUrl = '';
  bool isPdfUploading = false;
  String id = '';

  String companyName = '';

  // Must clear fields when form is submitted.
  void clearFields() {
    setState(() {
      listingTitleController.text = '';
      listingDescriptionController.text = '';
      listingAddressController.text = '';
      listingAddressController.text = '';
      eventTitleController.text = '';
      eventDescriptionController.text = '';
      eventAddressController.text = '';
      selectedGradeLevels = [];
      deadline = 'Select Application Deadline';
      eventStartDate = 'Select Start Date and Time';
      eventEndDate = 'Select End Date and Time';
      pdfDownloadUrl = '';
      isPdfUploading = false;
      id = '';
    });
  }

  // Gets the information about the partner from Firebase.
  Future<void> getName() async {
    var userQuery = await FirebaseFirestore.instance
        .collection('partnerships')
        .where('contactInfo', isEqualTo: widget.user.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userSnapshot = userQuery.docs.first;
      setState(() {
        companyName = userSnapshot.data()['name'];
      });
    }
  }

  // Takes the application pdf that was inputted by the user and
  // allows the user to view it by downloading it or storing it via
  // a multitude of apps.
  Future<void> downloadPdf(String downloadUrl) async {
    final Dio dio = Dio();

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String filePath = '$appDocPath/application.pdf';

      await dio.download(downloadUrl, filePath,
          onReceiveProgress: (received, total) {});

      await Share.shareFiles([filePath]);
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  // Allows the partner to attatch the application pdf that they want
  // the students to fill out when applying for the listing.
  // This pdf is then stored in FirebaseStorage.
  Future<String> uploadPdf(String fileName, File file) async {
    final reference = FirebaseStorage.instance
        .ref()
        .child("applications/" + fileName + ".pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadURL = await reference.getDownloadURL();

    return downloadURL;
  }

  // The partner has access to their files on their device.
  // This allows them to pick a file to upload as the application.
  Future<String?> pickFile() async {
    await getName();
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["pdf", "docx"]);

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path!);

      final downloadUrl = await uploadPdf(fileName, file);

      setState(() {
        pdfDownloadUrl = downloadUrl;
        isPdfUploading = false;
      });
      setState(() {
        id = Uuid().v4();
      });
      await FirebaseFirestore.instance.collection('listings').doc(id).set({
        'applicationRef': downloadUrl,
        'deadline': DateFormat('MMMM dd, yyyy').parse(deadline),
        'gradeLevel': selectedGradeLevels.length == 0
            ? 'No Requirement'
            : selectedGradeLevels.join(', '),
        'location': listingAddressController.text,
        'name': companyName,
        'refName': id,
        'title': listingTitleController.text,
        'description': listingDescriptionController.text,
        'type': selectedTypeDropdownItem,
        'logoRef': 'logos/microsoft_logo.png'
      });
      // Store this through the set in the add event or listings page
      return downloadUrl;
    }
  }

  // This builds the entire layout of the page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Listing/Event',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 30),
                buildDropdown(),
                SizedBox(height: 30),
                selectedDropdownItem == 'Create New Listing'
                    ? buildListingForm()
                    : buildEventForm()
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Displays the event creation form/
  Widget buildEventForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelText('EVENT TITLE'),
        buildListingTextField(eventTitleController, Icons.event_outlined),
        SizedBox(
          height: 30,
        ),
        buildLabelText('EVENT DESCRIPTION'),
        buildListingTextField(eventDescriptionController, Icons.info_outline),
        SizedBox(
          height: 30,
        ),
        buildLabelText('START DATE AND TIME'),
        buildEventDate(true),
        SizedBox(
          height: 30,
        ),
        buildLabelText('END DATE AND TIME'),
        buildEventDate(false),
        SizedBox(
          height: 30,
        ),
        buildLabelText('CITY, STATE'),
        buildListingTextField(
            eventAddressController, Icons.location_on_outlined),
        SizedBox(
          height: 30,
        ),
        // Handles invalid input (e.g. if nothing was entered).
        // Adds new event to Firebase Firestore.
        GestureDetector(
            onTap: () async {
              if (eventTitleController.text.isEmpty ||
                  eventDescriptionController.text.isEmpty ||
                  eventStartDate == 'Select Start Date and Time' ||
                  eventEndDate == 'Select End Date and Time' ||
                  eventAddressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields.'),
                  ),
                );
              } else {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc()
                    .set({
                  'name': 'Microsoft',
                  'title': eventTitleController.text,
                  'description': eventDescriptionController.text,
                  'location': eventAddressController.text,
                  'refName': 'partnerships/microsoft',
                  'startDate':
                      DateFormat('MMMM dd, yyyy h:mm a').parse(eventStartDate),
                  'endDate':
                      DateFormat('MMMM dd, yyyy h:mm a').parse(eventEndDate)
                });
                showDialog(
                  context: context,
                  builder: (context) {
                    return buildEndScreen();
                  },
                );
              }
            },
            child: buildSubmit())
      ],
    );
  }

  // Handles invalid input (e.g. if nothing was entered).
  // Adds new listing to Firebase Firestore.
  Widget buildListingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabelText('LISTING TITLE'),
        buildListingTextField(
            listingTitleController, Icons.account_box_outlined),
        SizedBox(height: 30),
        buildLabelText('LISTING DESCRIPTION'),
        buildListingTextField(listingDescriptionController, Icons.info_outline),
        SizedBox(height: 30),
        buildLabelText('TYPE'),
        buildListingDropdown(),
        SizedBox(
          height: 30,
        ),
        buildLabelText('GRADE REQUIREMENT'),
        buildGradeMultiSelect(),
        SizedBox(
          height: 30,
        ),
        buildLabelText('CITY, STATE'),
        buildListingTextField(
            listingAddressController, Icons.location_on_outlined),
        SizedBox(
          height: 30,
        ),
        buildLabelText('DEADLINE'),
        buildDeadline(),
        SizedBox(
          height: 30,
        ),
        buildLabelText('APPLICATION'),
        isPdfUploading
            ? CircularProgressIndicator(
                color: Colors.grey,
              )
            : uploadApplication(),
        SizedBox(
          height: 30,
        ),
        GestureDetector(
            onTap: () async {
              if (listingTitleController.text.isEmpty ||
                  listingDescriptionController.text.isEmpty ||
                  listingAddressController.text.isEmpty ||
                  pdfDownloadUrl.isEmpty ||
                  deadline == 'Select Application Deadline') {
                print('in herree');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields.'),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return buildEndScreen();
                  },
                );
              }
            },
            child: buildSubmit())
      ],
    );
  }

  // Once the form has been successfully submitted, a message
  // indicating that it was a success is displayed to the user.
  Widget buildEndScreen() {
    return AlertDialog(
      title: Text(
          (selectedDropdownItem == 'Create New Listing' ? 'Listing' : 'Event') +
              ' was successfully created!'),
      actions: [
        TextButton(
            onPressed: () {
              clearFields();
              Navigator.pop(context);
            },
            child: Text('Great!'))
      ],
    );
  }

  // This method builds the submit button.
  Widget buildSubmit() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff2C003F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
              child: Text(
            'Submit',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          )),
        ),
      ),
    );
  }

  // This method builds the upload application button.
  Widget uploadApplication() {
    return GestureDetector(
        onTap: () {},
        child: Container(
          width: pdfDownloadUrl == ''
              ? MediaQuery.of(context).size.width * 0.35
              : MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 40,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: pdfDownloadUrl == ''
                ? TextButton(
                    onPressed: () {
                      pickFile();
                      setState(() {
                        isPdfUploading = true;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Upload',
                          style:
                              TextStyle(color: Color(0xff8FD694), fontSize: 16),
                        ),
                        Spacer(),
                        Icon(
                          Icons.upload,
                          color: Color(0xff8FD694),
                        )
                      ],
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      downloadPdf(pdfDownloadUrl);
                    },
                    child: Row(
                      children: [
                        Text(
                          'View',
                          style:
                              TextStyle(color: Color(0xff8FD694), fontSize: 16),
                        ),
                        Spacer(),
                        Icon(
                          Icons.download,
                          color: Color(0xff8FD694),
                        )
                      ],
                    ),
                  ),
          ),
        ));
  }

  // When selecting a deadline, a date picker is shown to make it easier for the user.
  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

  // The button to select a date for the event is built.
  Widget buildEventDate(isStartDate) {
    return GestureDetector(
      onTap: () async {
        pickDateTime(isStartDate);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.watch_later_outlined,
                size: 35,
                color: Color(0xff8FD694),
              ),
              SizedBox(
                width: 20,
              ),
              isStartDate ? Text(eventStartDate) : Text(eventEndDate),
            ],
          ),
        ),
      ),
    );
  }

  // When selecting a start or end time, date and time
  // pickers are shown to make it easier for the user.
  Future pickDateTime(isStartDate) async {
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStartDate) {
        eventStartDate = DateFormat('MMMM dd, yyyy h:mm a').format(dateTime);
      } else {
        eventEndDate = DateFormat('MMMM dd, yyyy h:mm a').format(dateTime);
      }
    });
  }

  // Tiime picker only.
  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));

  // Allows the user to select a deadline for the listing they are creating.
  Widget buildDeadline() {
    return GestureDetector(
      onTap: () async {
        final date = await pickDate();
        if (date == null) return;
        setState(() {
          deadline = DateFormat('MMMM dd, yyyy').format(date);
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.watch_later_outlined,
                size: 35,
                color: Color(0xff8FD694),
              ),
              SizedBox(
                width: 20,
              ),
              Text(deadline),
            ],
          ),
        ),
      ),
    );
  }

  // Allows the user to select the grade levels that the listing will pertain to.
  Widget buildGradeMultiSelect() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.school_outlined,
              color: Color(0xff8FD694),
              size: 35,
            ),
            SizedBox(
              width: 20,
            ),
            Text(selectedGradeLevels.length == 0
                ? 'No Requirement'
                : selectedGradeLevels.join(', ')),
            Spacer(),
            IconButton(
                onPressed: showMultiSelect,
                icon: Icon(
                  Icons.add,
                  color: Color(0xff9E9E9E),
                ))
          ],
        ),
      ),
    );
  }

  // Represents the multiselect for the grade level criteria.
  void showMultiSelect() async {
    List<String> gradeLevels = [
      '9th',
      '10th',
      '11th',
      '12th',
      'No Requirement'
    ];
    List<String>? results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GradeMultiSelect(items: gradeLevels);
        });
    if (results != null) {
      setState(() {
        if (results.contains('No Requirement')) {
          selectedGradeLevels.clear(); // Clear all selected items
          selectedGradeLevels
              .add('No Requirement'); // Add 'No Requirement' only
        } else {
          selectedGradeLevels =
              results.where((item) => item != 'No Requirement').toList();
        }
      });
    }
  }

  // Formats the text in a nice manner.
  Widget buildLabelText(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        bottom: 8,
      ),
      child: Text(
        text,
        style: TextStyle(color: Color(0xff2C003F), fontSize: 12),
      ),
    );
  }

  // Builds the text fields that the user will need to input text into
  // when creating a listing or an event.
  Widget buildListingTextField(
      TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textInputAction: TextInputAction.done,
          maxLines: null,
          cursorColor: Colors.black,
          autocorrect: true,
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                icon,
                color: Color(0xff8FD694),
                size: 35,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // This dropdown is used to specify that a listing needs to be created.
  buildListingDropdown() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(1, 1),
                blurRadius: 40)
          ]),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: DropdownButton(
            value: selectedTypeDropdownItem,
            items: typeDropdownItems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      itemIcons[item],
                      color: Color(0xff8FD694),
                      size: 35,
                    ),
                    SizedBox(width: 20),
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (item) {
              setState(() {
                selectedTypeDropdownItem = item;
              });
            },
            icon: Container(
              margin: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
            ),
            isExpanded: true,
            underline: SizedBox(),
          )),
    );
  }

  Widget buildDropdown() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xffE3F5EA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(4, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        child: DropdownButton(
          value: selectedDropdownItem,
          items: dropdownItems
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              )
              .toList(),
          onChanged: (item) => setState(() {
            selectedDropdownItem = item;
          }),
          isExpanded: true,
          underline: SizedBox(),
        ),
      ),
    );
  }
}

// This class is widget that represents how to handle the age criteria.
class GradeMultiSelect extends StatefulWidget {
  final List<String> items;
  const GradeMultiSelect({super.key, required this.items});
  @override
  State<GradeMultiSelect> createState() => _GradeMultiSelectState();
}

class _GradeMultiSelectState extends State<GradeMultiSelect> {
  final List<String> selectedItems = [];

  void itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (itemValue == 'No Requirement') {
        if (isSelected) {
          selectedItems.clear(); // Clear all selected items
          selectedItems.add(itemValue); // Add 'No Requirement' only
        }
      } else {
        if (selectedItems.contains('No Requirement')) {
          selectedItems.remove('No Requirement');
        }
        if (isSelected) {
          selectedItems.add(itemValue);
        } else {
          selectedItems.remove(itemValue);
        }
      }
    });
  }

  // This method allows the user to exit without changing anything.
  void cancel() {
    Navigator.pop(context);
  }

  // This method allows the user to submit the age criteria.
  void submit() {
    Navigator.pop(context, selectedItems);
  }

  // This buildds the layout of the age criteria field.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Select Age Requirements'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                  value: selectedItems.contains(item),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => itemChange(item, isChecked!)))
              .toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: cancel, child: Text('Cancel')),
        ElevatedButton(onPressed: submit, child: Text('Submit'))
      ],
    );
  }
}
