import 'shipment.dart';

extension IncotermAllocation on Incoterm {
  bool get waterwayOnly => switch (this) {
    Incoterm.fas || Incoterm.fob || Incoterm.cfr || Incoterm.cif => true,
    _ => false,
  };

  bool supports(Transport transport) =>
      !waterwayOnly || transport == Transport.sea;

  bool get sellerPaysMainCarriage => switch (this) {
    Incoterm.cpt ||
    Incoterm.cip ||
    Incoterm.dap ||
    Incoterm.dpu ||
    Incoterm.ddp ||
    Incoterm.cfr ||
    Incoterm.cif => true,
    _ => false,
  };

  bool get sellerContractsInsurance =>
      this == Incoterm.cip || this == Incoterm.cif;
  bool get sellerHandlesImport => this == Incoterm.ddp;
}
