import 'package:flutter/material.dart';

void main() {
  runApp(UserInformation());
}

// This class was never used.
class UserInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Information Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.purple,
      ),
      home: InformationForm(),
    );
  }
}

class InformationForm extends StatefulWidget {
  @override
  _InformationFormState createState() => _InformationFormState();
}

class _InformationFormState extends State<InformationForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  bool _computerScience = false;
  bool _business = false;
  bool _marketing = false;
  bool _robotics = false;
  bool _design = false;
  bool _otherInterest = false;
  bool _summerInternship = false;
  bool _unpaidInternship = false;
  bool _paidInternship = false;
  bool _partTimeJob = false;
  bool _fullTimeJob = false;
  int _yearsOfExperience = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _gradeController,
                  decoration: InputDecoration(
                    labelText: 'Grade Level',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your grade level';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Interests (Check all that apply):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text('Computer Science'),
                  value: _computerScience,
                  onChanged: (newValue) {
                    setState(() {
                      _computerScience = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Business'),
                  value: _business,
                  onChanged: (newValue) {
                    setState(() {
                      _business = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Marketing'),
                  value: _marketing,
                  onChanged: (newValue) {
                    setState(() {
                      _marketing = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Robotics'),
                  value: _robotics,
                  onChanged: (newValue) {
                    setState(() {
                      _robotics = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Design'),
                  value: _design,
                  onChanged: (newValue) {
                    setState(() {
                      _design = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Other'),
                  value: _otherInterest,
                  onChanged: (newValue) {
                    setState(() {
                      _otherInterest = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Job Interests (Check all that apply):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text('Summer Internship'),
                  value: _summerInternship,
                  onChanged: (newValue) {
                    setState(() {
                      _summerInternship = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Unpaid Internship'),
                  value: _unpaidInternship,
                  onChanged: (newValue) {
                    setState(() {
                      _unpaidInternship = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Paid Internship'),
                  value: _paidInternship,
                  onChanged: (newValue) {
                    setState(() {
                      _paidInternship = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Part-time Job'),
                  value: _partTimeJob,
                  onChanged: (newValue) {
                    setState(() {
                      _partTimeJob = newValue!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Full-time Job'),
                  value: _fullTimeJob,
                  onChanged: (newValue) {
                    setState(() {
                      _fullTimeJob = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Years of prior experience in CTE courses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _yearsOfExperience = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String name = _nameController.text;
                      String gradeLevel = _gradeController.text;
                      // Process and use the collected data as needed
                      print('Name: $name');
                      print('Grade Level: $gradeLevel');
                      // Print other form data
                    }
                  },
                  child: Text('Submit'),
                ),
                SizedBox(
                    height: 100), // Padding for bottom space after the form
              ],
            ),
          ),
        ),
      ),
    );
  }
}
