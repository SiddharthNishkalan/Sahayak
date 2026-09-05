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
  final int totalAmount;
  final bool isPaid;

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
    required this.totalAmount,
    this.isPaid = false,
  });

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
    int? totalAmount,
    bool? isPaid,
  }) {
    return CooperativeInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      coopRegNumber: coopRegNumber ?? this.coopRegNumber,
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      diagnosticFee: diagnosticFee ?? this.diagnosticFee,
      laborFee: laborFee ?? this.laborFee,
      materialsFee: materialsFee ?? this.materialsFee,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
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
    totalAmount: 850,
    isPaid: true,
  );
}
