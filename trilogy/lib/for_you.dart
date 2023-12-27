import 'package:flutter/material.dart';

void main() {
  runApp(ForYou());
}

class ForYou extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Listings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: ForYouPage(),
    );
  }
}

class Job {
  final String title;
  final String description;

  Job(this.title, this.description);
}

class ForYouPage extends StatefulWidget {
  @override
  _ForYouPageState createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  List<Job> _jobs = []; // Simulated job data

  @override
  void initState() {
    super.initState();
    // Simulated job data based on user's interests
    _fetchJobsBasedOnInterests();
  }

  void _fetchJobsBasedOnInterests() {
    // Simulated job data based on user's interests
    // Replace this with logic to fetch jobs from a backend/database based on user's interests
    // For demonstration, I'm adding some static jobs
    setState(() {
      _jobs = [
        Job('Software Engineer', 'Develop software applications'),
        Job('Marketing Manager', 'Create and manage marketing campaigns'),
        Job('Robotics Engineer', 'Design and build robotic systems'),
        // Add more jobs based on user interests or any other logic
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('For You'),
      ),
      body: _jobs.isNotEmpty
          ? ListView.separated(
              itemCount: _jobs.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final job = _jobs[index];
                return ListTile(
                  title: Text(
                    job.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      job.description,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // You can add more UI components here for each job listing
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(), // Show a loader while fetching data
            ),
    );
  }
}
