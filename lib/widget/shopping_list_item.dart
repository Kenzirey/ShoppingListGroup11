import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

// Helper function to get the full name of a unit from its abbreviation.
// You can expand this list as needed.
String _getFullUnitName(String unitAbbreviation) {
  if (unitAbbreviation.isEmpty) {
    return ''; // Return empty if abbreviation is empty
  }
  // Normalize to lowercase for consistent matching
  final String lowerUnit = unitAbbreviation.toLowerCase();

  switch (lowerUnit) {
    case 'tbsp':
      return 'tablespoons'; // Endret til engelsk for konsistens med koden, kan oversettes i appen om nødvendig
    case 'ml':
      return 'milliliters';
    case 'l':
      return 'liters';
    case 'g':
      return 'grams';
    case 'kg':
      return 'kilograms';
    case 'tsp':
      return 'teaspoons';
    case 'pcs':
      return 'pieces';
    case 'oz':
      return 'ounces';
    case 'fl oz':
      return 'fluid ounces';
    case 'cup':
    case 'cups':
      return 'cups';
    // Add any other units you use
    default:
      // If the unit is not in our list, return the original abbreviation.
      // This ensures that less common or custom units are still announced,
      // though ideally, all common ones should be mapped.
      return unitAbbreviation;
  }
}

/// A ShoppingListItem shows the item name and, when count-based (unitLabel is empty),
/// displays a dropdown that lazy-loads numeric options. Otherwise, it shows a TextField
/// for quantity input with a unit suffix.
class ShoppingListItem extends StatefulWidget {
  final String item;
  final String quantityText; // e.g., "2 tbsp" or "5"
  final String unitLabel;    // e.g., "tbsp" or "" if count-based
  final ValueChanged<int> onQuantityChanged;

  const ShoppingListItem({
    super.key,
    required this.item,
    required this.quantityText,
    required this.unitLabel,
    required this.onQuantityChanged,
  });

  @override
  State<ShoppingListItem> createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller only if not using dropdown and it hasn't been initialized.
    // This setup is a bit unusual; typically, the controller would be initialized
    // here and updated in didUpdateWidget if initialValue changes.
    // For this specific request, we'll keep the existing logic for controller initialization.
    final bool useDropdown = widget.unitLabel.isEmpty;
    if (!useDropdown) {
      final numericQuantity = QuantityParser.parseLeadingNumber(
          widget.quantityText, defaultValue: 1);
      _controller = TextEditingController(text: numericQuantity.toString());
    }
  }

  @override
  void didUpdateWidget(ShoppingListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool useDropdown = widget.unitLabel.isEmpty;
    if (!useDropdown) {
      final numericQuantity = QuantityParser.parseLeadingNumber(
          widget.quantityText, defaultValue: 1);
      final String currentNumericText = numericQuantity.toString();

      // Ensure controller exists if we are not using dropdown
      _controller ??= TextEditingController();

      // Update controller text only if it's different to avoid cursor jumps
      if (_controller!.text != currentNumericText) {
        _controller!.text = currentNumericText;
        // Optionally, move cursor to the end after programmatic change
        // _controller!.selection = TextSelection.fromPosition(
        //   TextPosition(offset: _controller!.text.length),
        // );
      }
    } else {
      // If we switch to dropdown, dispose the controller as it's not needed
      _controller?.dispose();
      _controller = null;
    }
  }


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final bg = theme.colorScheme.primaryContainer; // Not used in this snippet
    final tertiary = theme.colorScheme.tertiary;
    final numericQuantity = QuantityParser.parseLeadingNumber(
        widget.quantityText, defaultValue: 1);
    final initialValue = numericQuantity.toString(); // For dropdown
    final useDropdown = widget.unitLabel.isEmpty;

    // This ensures the controller is initialized if needed for the TextField branch.
    // It was previously inside the build method which is not ideal for controller creation.
    // Moved to initState and didUpdateWidget for better lifecycle management.
    // if (!useDropdown && _controller == null) {
    //   _controller = TextEditingController(text: initialValue);
    // }

    return Container(
      height: 56, // Fixed height for the list item
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // item name
          Expanded(
            child: Text(
              widget.item,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (useDropdown)
            // ───── dropdown branch (for count-based items like "pieces") ─────
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // hide the built-in underline and center the trigger
                  DropdownButtonHideUnderline(
                    child: Center(
                      child: CustomLazyDropdown(
                        initialValue: initialValue, // This is the numeric part
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            widget.onQuantityChanged(parsed);
                          }
                        },
                        // Potentially add semanticHint for the dropdown action
                        // semanticHint: "Select quantity for ${widget.item}",
                      ),
                    ),
                  ),
                  // draw a 1px underline exactly under the trigger
                  Container(
                    height: 1,
                    color: tertiary,
                  ),
                ],
              ),
            )
          else
            // ───── textfield branch (for items with units like "ml", "tbsp") ─────
            IntrinsicWidth(
              child: Semantics(
                // Konstruer den semantiske etiketten for å inkludere både synlig tekst og fullt enhetsnavn
                label: () {
                  final String currentNumericValue = _controller?.text ?? initialValue;
                  final String visualUnit = widget.unitLabel;
                  final String fullUnitName = _getFullUnitName(visualUnit);

                  if (fullUnitName == visualUnit || visualUnit.isEmpty) {
                    // Hvis fullt navn er lik forkortelse, eller ingen enhet, bare vis tall + enhet
                    return '$currentNumericValue $visualUnit'.trim();
                  } else {
                    // Ellers, vis tall + forkortelse + (fullt navn)
                    return '$currentNumericValue $visualUnit ($fullUnitName)';
                  }
                }(),
                textField: true, // Indikerer at dette er et tekstfelt
                value: '${_controller?.text ?? initialValue} ${widget.unitLabel}'.trim(), // Den faktiske synlige verdien
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  decoration: InputDecoration(
                    // Økt vertikal padding og fjernet isDense for større berøringsflate
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), 
                    // isDense: true, // Fjernet for standard (større) høyde
                    border: const UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: tertiary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: theme.colorScheme.primary),
                    ),
                    // Suffix er nå rent visuelt, Semantics-wrapperen håndterer den tilgjengelige annonseringen.
                    suffix: widget.unitLabel.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0), // Legg til litt mellomrom
                            child: Text(
                              widget.unitLabel, // Visuell forkortelse
                              style: TextStyle( 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: tertiary,
                              ),
                            ),
                          )
                        : null, 
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      widget.onQuantityChanged(parsed);
                    }
                    // Viktig for Semantics: Sørg for at semantikknoden oppdateres når teksten endres.
                    // setState brukes her for å tvinge en gjenoppbygging av Semantics-noden med ny verdi/etikett.
                    // Dette er nødvendig fordi _controller.text endres utenfor en normal setState-syklus for denne widgeten.
                    setState(() {});
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
