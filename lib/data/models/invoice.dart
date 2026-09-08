class InstitutionInvoiceItem {
  final String domain;
  final String domainTitle;
  final int workerCount;
  final int ratePerWorker;
  final int diagnosticFee;
  final int laborFee;
  final int materialsFee;
  final int? platformFee;
  final int? totalAmount;

  const InstitutionInvoiceItem({
    required this.domain,
    required this.domainTitle,
    required this.workerCount,
    required this.ratePerWorker,
    this.diagnosticFee = 0,
    int? laborFee,
    this.materialsFee = 0,
    this.platformFee,
    this.totalAmount,
  }) : laborFee = laborFee ?? (workerCount * ratePerWorker);

  /// 18% Platform Fee applies strictly to the Visit & Diagnostic Fee line only
  int get effectivePlatformFee =>
      platformFee ?? ((diagnosticFee * 0.18).round());

  /// Labor and Material costs pass through with 0% platform fee
  int get effectiveTotalAmount =>
      totalAmount ?? (diagnosticFee + laborFee + materialsFee + effectivePlatformFee);
}

class CooperativeInvoice {
  final String invoiceNumber;
  final String date;
  final String coopRegNumber;
  final String technicianName;
  final String technicianId;
  final String paymentMethod;
  final int diagnosticFee;
  final int laborFee;
  final int materialsFee;
  final int? platformFee;
  final int totalAmount;
  final bool isPaid;
  final bool isInstitutionInvoice;
  final String? organizationName;
  final String? siteName;
  final List<InstitutionInvoiceItem> lineItems;

  const CooperativeInvoice({
    required this.invoiceNumber,
    required this.date,
    required this.coopRegNumber,
    required this.technicianName,
    required this.technicianId,
    required this.paymentMethod,
    required this.diagnosticFee,
    required this.laborFee,
    required this.materialsFee,
    this.platformFee,
    required this.totalAmount,
    this.isPaid = false,
    this.isInstitutionInvoice = false,
    this.organizationName,
    this.siteName,
    this.lineItems = const [],
  });

  /// Combined total of service fees before platform fee
  int get serviceSubtotal => diagnosticFee + laborFee + materialsFee;

  /// Calculated platform fee:
  /// - Household: 10% of Visit & Diagnostic Fee only (labor and materials pass through with 0% fee)
  /// - Institution: 18% of Visit & Diagnostic Fee line only (labor and materials pass through with 0% fee)
  int get calculatedPlatformFee {
    if (isInstitutionInvoice) {
      if (lineItems.isNotEmpty) {
        return lineItems.fold(0, (sum, item) => sum + item.effectivePlatformFee);
      }
      return (diagnosticFee * 0.18).round();
    } else {
      return (diagnosticFee * 0.10).round();
    }
  }

  int get effectivePlatformFee => platformFee ?? calculatedPlatformFee;

  /// Worker & direct costs payout (100% of diagnostic, labor, and materials)
  int get workerPayout => serviceSubtotal;

  /// Cooperative platform fee share
  int get cooperativePlatformShare => effectivePlatformFee;

  int get effectiveTotalAmount => serviceSubtotal + effectivePlatformFee;

  CooperativeInvoice copyWith({
    String? invoiceNumber,
    String? date,
    String? coopRegNumber,
    String? technicianName,
    String? technicianId,
    String? paymentMethod,
    int? diagnosticFee,
    int? laborFee,
    int? materialsFee,
    int? platformFee,
    int? totalAmount,
    bool? isPaid,
    bool? isInstitutionInvoice,
    String? organizationName,
    String? siteName,
    List<InstitutionInvoiceItem>? lineItems,
  }) {
    final newDiagnostic = diagnosticFee ?? this.diagnosticFee;
    final newLabor = laborFee ?? this.laborFee;
    final newMaterials = materialsFee ?? this.materialsFee;
    final newIsInst = isInstitutionInvoice ?? this.isInstitutionInvoice;
    final newLineItems = lineItems ?? this.lineItems;

    int newPlatform;
    if (platformFee != null) {
      newPlatform = platformFee;
    } else if (newIsInst) {
      if (newLineItems.isNotEmpty) {
        newPlatform = newLineItems.fold(0, (sum, item) => sum + item.effectivePlatformFee);
      } else {
        newPlatform = (newDiagnostic * 0.18).round();
      }
    } else {
      newPlatform = (newDiagnostic * 0.10).round();
    }

    final newTotal = totalAmount ?? (newDiagnostic + newLabor + newMaterials + newPlatform);

    return CooperativeInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      coopRegNumber: coopRegNumber ?? this.coopRegNumber,
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      diagnosticFee: newDiagnostic,
      laborFee: newLabor,
      materialsFee: newMaterials,
      platformFee: newPlatform,
      totalAmount: newTotal,
      isPaid: isPaid ?? this.isPaid,
      isInstitutionInvoice: newIsInst,
      organizationName: organizationName ?? this.organizationName,
      siteName: siteName ?? this.siteName,
      lineItems: newLineItems,
    );
  }

  static const CooperativeInvoice sampleInvoice = CooperativeInvoice(
    invoiceNumber: '#INV-2024-COOP-88219',
    date: '24 Oct 2024 · 2:56 PM',
    coopRegNumber: 'TN-COOP-449',
    technicianName: 'Priya Sharma',
    technicianId: '#PLM-104',
    paymentMethod: 'UPI / Direct Member Settlement',
    diagnosticFee: 300,
    laborFee: 500,
    materialsFee: 50,
    platformFee: 30, // 10% of 300 Visit & Diagnostic only
    totalAmount: 880, // 850 + 30
    isPaid: true,
  );

  static const CooperativeInvoice sampleInstitutionInvoice = CooperativeInvoice(
    invoiceNumber: '#INV-2026-INST-4921',
    date: 'Yesterday · 4:30 PM',
    coopRegNumber: 'TN-COOP-449-INST',
    technicianName: 'Work Solute Cooperative Guild Allocation',
    technicianId: '#CORP-SEC-04',
    paymentMethod: 'Institutional Corporate Net / UPI',
    diagnosticFee: 500, // 300 (Electrical) + 200 (Cleaning)
    laborFee: 4800, // 2400 + 2400
    materialsFee: 350, // 200 + 150
    platformFee: 90, // 18% of 500 Visit/Diagnostic (54 + 36)
    totalAmount: 5740, // 500 + 4800 + 350 + 90
    isPaid: true,
    isInstitutionInvoice: true,
    organizationName: 'Apex Technology Park',
    siteName: 'Office 1 (Main Campus - Block B)',
    lineItems: [
      InstitutionInvoiceItem(
        domain: 'electrical',
        domainTitle: 'Licensed Electricians',
        workerCount: 3,
        ratePerWorker: 800,
        diagnosticFee: 300,
        laborFee: 2400,
        materialsFee: 200,
        platformFee: 54, // 18% of 300
        totalAmount: 2954,
      ),
      InstitutionInvoiceItem(
        domain: 'cleaner',
        domainTitle: 'Deep Cleaning Crew',
        workerCount: 4,
        ratePerWorker: 600,
        diagnosticFee: 200,
        laborFee: 2400,
        materialsFee: 150,
        platformFee: 36, // 18% of 200
        totalAmount: 2786,
      ),
    ],
  );
}
