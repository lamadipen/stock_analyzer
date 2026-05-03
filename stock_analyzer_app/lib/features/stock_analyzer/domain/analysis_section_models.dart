import 'package:stock_analyzer_app/features/stock_analyzer/domain/sale_target_calculator.dart';

class DecisionSummary {
  const DecisionSummary({
    required this.savedAt,
    required this.businessQuality,
    required this.valuation,
    required this.entryPoint,
    required this.riskLevel,
    required this.finalAction,
    required this.notes,
  });

  final DateTime? savedAt;
  final String businessQuality;
  final String valuation;
  final String entryPoint;
  final String riskLevel;
  final String finalAction;
  final String notes;

  factory DecisionSummary.fromJson(Map<String, dynamic> json) {
    return DecisionSummary(
      savedAt: DateTime.tryParse('${json['savedAt'] ?? ''}'),
      businessQuality: _readString(json['businessQuality'], fallback: 'Watch'),
      valuation: _readString(json['valuation'], fallback: 'Fair'),
      entryPoint: _readString(json['entryPoint'], fallback: 'Wait'),
      riskLevel: _readString(json['riskLevel'], fallback: 'Medium'),
      finalAction: _readString(json['finalAction'], fallback: 'Watchlist'),
      notes: _readString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedAt': savedAt?.toIso8601String(),
      'businessQuality': businessQuality,
      'valuation': valuation,
      'entryPoint': entryPoint,
      'riskLevel': riskLevel,
      'finalAction': finalAction,
      'notes': notes,
    };
  }
}

class BusinessOverviewChecklistItem {
  const BusinessOverviewChecklistItem({
    required this.title,
    required this.isChecked,
  });

  final String title;
  final bool isChecked;

  factory BusinessOverviewChecklistItem.fromJson(Map<String, dynamic> json) {
    return BusinessOverviewChecklistItem(
      title: _readString(json['title']),
      isChecked: json['isChecked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isChecked': isChecked};
  }
}

class BusinessOverview {
  const BusinessOverview({
    required this.savedAt,
    required this.businessModel,
    required this.revenueSources,
    required this.mainSegment,
    required this.growthDriver,
    required this.earningsSignal,
    required this.analystRating,
    required this.stockTrend,
    required this.conclusion,
    required this.rawResearch,
    required this.earningsSignalCheckedAt,
    required this.analystRatingCheckedAt,
    required this.stockTrendCheckedAt,
    required this.rawResearchPastedAt,
    required this.qualityScore,
    required this.qualityLabel,
    required this.items,
  });

  final DateTime? savedAt;
  final String businessModel;
  final String revenueSources;
  final String mainSegment;
  final String growthDriver;
  final String earningsSignal;
  final String analystRating;
  final String stockTrend;
  final String conclusion;
  final String rawResearch;
  final DateTime? earningsSignalCheckedAt;
  final DateTime? analystRatingCheckedAt;
  final DateTime? stockTrendCheckedAt;
  final DateTime? rawResearchPastedAt;
  final int qualityScore;
  final String qualityLabel;
  final List<BusinessOverviewChecklistItem> items;

  String get decisionBusinessQuality {
    return switch (qualityLabel) {
      'Strong' => 'Pass',
      'Weak' => 'Fail',
      _ => 'Watch',
    };
  }

  bool get hasResearchNotes {
    return [
      businessModel,
      revenueSources,
      mainSegment,
      growthDriver,
      earningsSignal,
      analystRating,
      stockTrend,
      conclusion,
    ].any((value) => value.trim().isNotEmpty);
  }

  factory BusinessOverview.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return BusinessOverview(
      savedAt: DateTime.tryParse('${json['savedAt'] ?? ''}'),
      businessModel: _readString(json['businessModel']),
      revenueSources: _readString(json['revenueSources']),
      mainSegment: _readString(json['mainSegment']),
      growthDriver: _readString(json['growthDriver']),
      earningsSignal: _readString(json['earningsSignal']),
      analystRating: _readString(json['analystRating']),
      stockTrend: _readString(json['stockTrend']),
      conclusion: _readString(json['conclusion']),
      rawResearch: _readString(json['rawResearch']),
      earningsSignalCheckedAt: DateTime.tryParse(
        '${json['earningsSignalCheckedAt'] ?? ''}',
      ),
      analystRatingCheckedAt: DateTime.tryParse(
        '${json['analystRatingCheckedAt'] ?? ''}',
      ),
      stockTrendCheckedAt: DateTime.tryParse(
        '${json['stockTrendCheckedAt'] ?? ''}',
      ),
      rawResearchPastedAt: DateTime.tryParse(
        '${json['rawResearchPastedAt'] ?? ''}',
      ),
      qualityScore: _readInt(json['qualityScore']),
      qualityLabel: _readString(json['qualityLabel'], fallback: 'Mixed'),
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(BusinessOverviewChecklistItem.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedAt': savedAt?.toIso8601String(),
      'businessModel': businessModel,
      'revenueSources': revenueSources,
      'mainSegment': mainSegment,
      'growthDriver': growthDriver,
      'earningsSignal': earningsSignal,
      'analystRating': analystRating,
      'stockTrend': stockTrend,
      'conclusion': conclusion,
      'rawResearch': rawResearch,
      'earningsSignalCheckedAt': earningsSignalCheckedAt?.toIso8601String(),
      'analystRatingCheckedAt': analystRatingCheckedAt?.toIso8601String(),
      'stockTrendCheckedAt': stockTrendCheckedAt?.toIso8601String(),
      'rawResearchPastedAt': rawResearchPastedAt?.toIso8601String(),
      'qualityScore': qualityScore,
      'qualityLabel': qualityLabel,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class SaleTarget {
  const SaleTarget({
    required this.title,
    required this.startDate,
    required this.principal,
    required this.growthRatePercent,
    required this.years,
  });

  final String title;
  final DateTime startDate;
  final double principal;
  final double growthRatePercent;
  final int years;

  double get targetPrice => SaleTargetCalculator.calculateTargetPrice(
    principal: principal,
    growthRatePercent: growthRatePercent,
    years: years,
  );

  DateTime get maturityDate => SaleTargetCalculator.calculateMaturityDate(
    startDate: startDate,
    years: years,
  );

  factory SaleTarget.fromJson(Map<String, dynamic> json) {
    return SaleTarget(
      title: _readString(json['title']),
      startDate:
          DateTime.tryParse('${json['startDate'] ?? ''}') ?? DateTime.now(),
      principal: _readDouble(json['principal']),
      growthRatePercent: _readDouble(json['growthRatePercent']),
      years: _readInt(json['years'], fallback: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate.toIso8601String(),
      'principal': principal,
      'growthRatePercent': growthRatePercent,
      'years': years,
    };
  }

  SaleTarget copyWith({
    String? title,
    DateTime? startDate,
    double? principal,
    double? growthRatePercent,
    int? years,
  }) {
    return SaleTarget(
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      principal: principal ?? this.principal,
      growthRatePercent: growthRatePercent ?? this.growthRatePercent,
      years: years ?? this.years,
    );
  }
}

class SaleTargetSection {
  const SaleTargetSection({required this.savedAt, required this.targets});

  final DateTime? savedAt;
  final List<SaleTarget> targets;

  factory SaleTargetSection.fromJson(Map<String, dynamic> json) {
    final targets = json['targets'];
    return SaleTargetSection(
      savedAt: DateTime.tryParse('${json['savedAt'] ?? ''}'),
      targets: targets is List
          ? targets
                .whereType<Map<String, dynamic>>()
                .map(SaleTarget.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedAt': savedAt?.toIso8601String(),
      'targets': targets.map((target) => target.toJson()).toList(),
    };
  }
}

class BuyPoint {
  const BuyPoint({
    required this.dateCreated,
    required this.buyPoint,
    required this.targetPrice,
  });

  final String dateCreated;
  final String buyPoint;
  final String targetPrice;

  factory BuyPoint.fromJson(Map<String, dynamic> json) {
    return BuyPoint(
      dateCreated: _readString(json['dateCreated']),
      buyPoint: _readString(json['buyPoint']),
      targetPrice: _readString(json['targetPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateCreated': dateCreated,
      'buyPoint': buyPoint,
      'targetPrice': targetPrice,
    };
  }
}

class AnalysisReferenceLink {
  const AnalysisReferenceLink({required this.label, required this.url});

  final String label;
  final String url;

  factory AnalysisReferenceLink.fromJson(Map<String, dynamic> json) {
    return AnalysisReferenceLink(
      label: _readString(json['label']),
      url: _readString(json['url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'url': url};
  }
}

class MarginOfSafety {
  const MarginOfSafety({
    required this.savedAt,
    required this.isGreatEntry,
    required this.buyPoints,
    required this.referenceLinks,
  });

  final DateTime? savedAt;
  final bool isGreatEntry;
  final List<BuyPoint> buyPoints;
  final List<AnalysisReferenceLink> referenceLinks;

  factory MarginOfSafety.fromJson(Map<String, dynamic> json) {
    final buyPoints = json['buyPoints'];
    final referenceLinks = json['referenceLinks'];
    return MarginOfSafety(
      savedAt: DateTime.tryParse('${json['savedAt'] ?? ''}'),
      isGreatEntry: json['isGreatEntry'] == true,
      buyPoints: buyPoints is List
          ? buyPoints
                .whereType<Map<String, dynamic>>()
                .map(BuyPoint.fromJson)
                .toList()
          : const [],
      referenceLinks: referenceLinks is List
          ? referenceLinks
                .whereType<Map<String, dynamic>>()
                .map(AnalysisReferenceLink.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedAt': savedAt?.toIso8601String(),
      'isGreatEntry': isGreatEntry,
      'buyPoints': buyPoints.map((buyPoint) => buyPoint.toJson()).toList(),
      'referenceLinks': referenceLinks.map((link) => link.toJson()).toList(),
    };
  }
}

class CompetitorStudyParameter {
  const CompetitorStudyParameter({
    required this.title,
    required this.isChecked,
    required this.note,
  });

  final String title;
  final bool isChecked;
  final String note;

  factory CompetitorStudyParameter.fromJson(Map<String, dynamic> json) {
    return CompetitorStudyParameter(
      title: _readString(json['title']),
      isChecked: json['isChecked'] == true,
      note: _readString(json['note']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isChecked': isChecked, 'note': note};
  }
}

class CompetitorStudy {
  const CompetitorStudy({required this.savedAt, required this.parameters});

  final DateTime? savedAt;
  final List<CompetitorStudyParameter> parameters;

  factory CompetitorStudy.fromJson(Map<String, dynamic> json) {
    final parameters = json['parameters'];
    return CompetitorStudy(
      savedAt: DateTime.tryParse('${json['savedAt'] ?? ''}'),
      parameters: parameters is List
          ? parameters
                .whereType<Map<String, dynamic>>()
                .map(CompetitorStudyParameter.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedAt': savedAt?.toIso8601String(),
      'parameters': parameters.map((parameter) => parameter.toJson()).toList(),
    };
  }
}

String _readString(Object? value, {String fallback = ''}) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? fallback : text;
}

double _readDouble(Object? value, {double fallback = 0}) {
  return double.tryParse('${value ?? ''}') ?? fallback;
}

int _readInt(Object? value, {int fallback = 0}) {
  return int.tryParse('${value ?? ''}') ?? fallback;
}
