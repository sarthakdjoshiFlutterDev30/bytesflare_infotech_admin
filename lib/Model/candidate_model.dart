class Candidate {
  final String id;
  final String name;
  final String jobDesignation;
  final String appliedDate;
  final String mobileNo;
  final String resumeUrl;
  final String? portfolioLink;

  Candidate({
    required this.id,
    required this.name,
    required this.jobDesignation,
    required this.appliedDate,
    required this.resumeUrl,
    this.portfolioLink,
    required this.mobileNo,
  });

  factory Candidate.fromMap(String id, Map<String, dynamic> map) {
    return Candidate(
      id: id,
      name: map['name'] ?? '',
      jobDesignation: map['jobDesignation'] ?? '',
      appliedDate: map['appliedDate'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      portfolioLink: map['portfolioLink'],
      mobileNo: map['mobileNo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobDesignation': jobDesignation,
      'appliedDate': appliedDate,
      'resumeUrl': resumeUrl,
      'portfolioLink': portfolioLink,
      'mobileNo': mobileNo,
    };
  }
}
