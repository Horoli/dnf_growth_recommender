class MCharacter {
  final String serverId;
  final String characterId;
  final String characterName;
  final String jobName;
  final String jobGrowName;
  final int fame;

  MCharacter({
    required this.serverId,
    required this.characterId,
    required this.characterName,
    required this.jobName,
    required this.jobGrowName,
    required this.fame,
  });

  factory MCharacter.fromJson(Map<String, dynamic> json) => MCharacter(
        serverId: json['serverId'] as String,
        characterId: json['characterId'] as String,
        characterName: json['characterName'] as String,
        jobName: json['jobName'] as String,
        jobGrowName: json['jobGrowName'] as String,
        fame: (json['fame'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'characterId': characterId,
        'characterName': characterName,
        'jobName': jobName,
        'jobGrowName': jobGrowName,
        'fame': fame,
      };
}
