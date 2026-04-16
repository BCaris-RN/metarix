enum JobType {
  schedulePrepare,
  publishAttempt,
  reportGenerate,
  evidenceAssemble,
  connectorSync,
  listeningRefresh,
}

extension JobTypeX on JobType {
  String get label => switch (this) {
        JobType.schedulePrepare => 'Schedule prepare',
        JobType.publishAttempt => 'Publish attempt',
        JobType.reportGenerate => 'Report generate',
        JobType.evidenceAssemble => 'Evidence assemble',
        JobType.connectorSync => 'Connector sync',
        JobType.listeningRefresh => 'Listening refresh',
      };
}
