import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/candidate_model.dart';
import 'HiredEmployeesPage.dart';
import 'pdf_viewer_page.dart';

class CandidateListPage extends StatelessWidget {
  const CandidateListPage({super.key});

  Future<void> hireCandidate(BuildContext context, Candidate c) async {
    try {
      final hiredDate = DateTime.now().toIso8601String(); // current date-time
      await FirebaseFirestore.instance
          .collection('hired-employees')
          .doc(c.id)
          .set({
            'name': c.name,
            'jobDesignation': c.jobDesignation,
            'appliedDate': c.appliedDate,
            'mobileNo': c.mobileNo,
            'hiredAt': hiredDate,
            'portfolioLink': c.portfolioLink,
            'resumeUrl': c.resumeUrl,
          });

      await FirebaseFirestore.instance
          .collection('Carriers')
          .doc(c.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Candidate hired successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error hiring candidate: $e")));
    }
  }

  Future<void> rejectCandidate(BuildContext context, Candidate c) async {
    try {
      if (c.resumeUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(c.resumeUrl);
        await storageRef.delete();
      }
      await FirebaseFirestore.instance
          .collection('Carriers')
          .doc(c.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Application rejected and deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Error rejecting application: $e")),
      );
    }
  }

  String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "📋 Applications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: const Text(
                'Admin Panel \nBytesFlares Infotech',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Applications'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Hired Employees'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HiredEmployeesPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Carriers')
            .orderBy('appliedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No applications found 📭",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final candidates = snapshot.data!.docs.map((doc) {
            return Candidate.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final c = candidates[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.teal.shade100,
                            child: Text(
                              c.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  c.jobDesignation,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                  tooltip: "Call",
                                  onPressed: () {
                                    _launchPhone(c.mobileNo);
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: "View Resume",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PdfViewerPage(pdfUrl: c.resumeUrl),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "📅 Applied on: ${formatDate(c.appliedDate)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => hireCandidate(context, c),
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: const Text("Hire"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => rejectCandidate(context, c),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _launchPhone(String phone) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phone);

    await launch(phoneLaunchUri.toString());
  }
}
