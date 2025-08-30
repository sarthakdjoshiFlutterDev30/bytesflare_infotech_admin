import 'package:bytesflare_infotech_admin/View/candidate_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/HiredEmployee.dart';
import 'pdf_viewer_page.dart';

class HiredEmployeesPage extends StatelessWidget {
  const HiredEmployeesPage({super.key});

  String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> fireEmployee(BuildContext context, HiredEmployee e) async {
    try {
      // Delete resume from Firebase Storage if exists
      if (e.resumeUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(e.resumeUrl);
        await storageRef.delete();
      }

      // Remove from hired-employees collection
      await FirebaseFirestore.instance
          .collection('hired-employees')
          .doc(e.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Employee has been removed")),
      );
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error firing employee: $err")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "🎯 Hired Employees",
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CandidateListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Hired Employees'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hired-employees')
            .orderBy('hiredAt', descending: true)
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
                "No hired employees yet 📭",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final employees = snapshot.data!.docs.map((doc) {
            return HiredEmployee.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final e = employees[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal.shade100,
                        child: (e.photoUrl.isNotEmpty)
                            ? Image.network(e.photoUrl)
                            : Text(
                                e.name.isNotEmpty
                                    ? e.name[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Employee Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              e.jobDesignation,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "📅 Applied on: ${formatDate(e.appliedDate)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "🎉 Hired at: ${formatDate(e.hiredAt)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Buttons
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchPhone(e.mobileNo);
                            },
                            icon: const Icon(Icons.call, color: Colors.white),
                            label: const Text("Call"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PdfViewerPage(pdfUrl: e.resumeUrl),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                            ),
                            label: const Text("Resume"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: () => fireEmployee(context, e),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.white,
                            ),
                            label: const Text("Fire"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
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
