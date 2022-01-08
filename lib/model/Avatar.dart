class Avatar {
  final String firstName;
  final String lastName;
  final String imageLocation;
  final String label;
  final String trainImage;
  final double confidence;

  Avatar(this.firstName, this.lastName, this.imageLocation, this.label, this.trainImage, this.confidence);

  String get fullName => '$firstName $lastName';

  static List<Avatar> fetchAll() {
    return [
      Avatar('Nawaz', 'Sharif', 'assets/images/ns.png', 'nawaz', 'images/train/nawaz.png', 0.4),
      Avatar('Shehbaz', 'Sharif', 'assets/images/sbs.jpg', 'shahbaz', 'images/train/shahbaz.png', 0.4),
      Avatar('Maryam', 'Nawaz', 'assets/images/mns.png', 'maryam', 'images/train/maryam.png', 0.3),
      Avatar('Hamza', 'Shahbaz', 'assets/images/hs.jpg', 'hamza', 'images/train/hamza.png', 0.5),
      Avatar('Ishaq', 'Dar', 'assets/images/iqd.jpg', 'ishaq', 'images/train/ishaq.png', 0.5),
      Avatar('Shahid', 'Khaqan Abbasi', 'assets/images/ska.jpg', 'shahid', 'images/train/shahid.png', 0.5),
      Avatar('Saad', 'Rafique', 'assets/images/sr.jpg', 'saad', 'images/train/saad.png', 0.5),
      Avatar('Ahsan', 'Iqbal', 'assets/images/aiq.jpg', 'ahsan', 'images/train/ahsan.png', 0.5),
      Avatar('Maryam', 'Aurangzeb', 'assets/images/ma.jpg', 'maurangzeb', 'images/train/maurangzeb.png', 0.6),
    ];
  }

  static Avatar findByLabel(String label) {
    return Avatar.fetchAll().firstWhere((element) => element.label == label);
  }
}