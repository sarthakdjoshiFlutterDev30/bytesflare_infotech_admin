class HiredEmployee {
  final String id;
  final String name;
  final String jobDesignation;
  final String appliedDate;
  final String hiredAt;
  final String portfolioLink;
  final String mobileNo;
  final String resumeUrl;

  HiredEmployee({
    required this.id,
    required this.name,
    required this.jobDesignation,
    required this.appliedDate,
    required this.hiredAt,
    required this.portfolioLink,
    required this.resumeUrl,
    required this.mobileNo,
  });

  factory HiredEmployee.fromMap(String id, Map<String, dynamic> map) {
    return HiredEmployee(
      id: id,
      name: map['name'] ?? '',
      jobDesignation: map['jobDesignation'] ?? '',
      appliedDate: map['appliedDate'] ?? '',
      hiredAt: map['hiredAt'] ?? '',
      portfolioLink: map['portfolioLink'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      mobileNo: map['mobileNo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobDesignation': jobDesignation,
      'appliedDate': appliedDate,
      'hiredAt': hiredAt,
      'portfolioLink': portfolioLink,
      'resumeUrl': resumeUrl,
      'mobileNo': mobileNo,
    };
  }
}
