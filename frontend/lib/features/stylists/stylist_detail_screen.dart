import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/stylist_provider.dart';
import '../../core/providers/booking_provider.dart';

class StylistDetailScreen extends ConsumerStatefulWidget {
  final Stylist stylist;
  const StylistDetailScreen({super.key, required this.stylist});

  @override
  ConsumerState<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends ConsumerState<StylistDetailScreen> {
  DateTime? _selectedDate;
  String _selectedTime = '11:00 am';
  final _commentsController = TextEditingController();
  StylistService? _selectedService;

  @override
  void initState() {
    super.initState();
    if (widget.stylist.services.isNotEmpty) {
      _selectedService = widget.stylist.services.first;
    }
  }

  void _bookAppointment() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    final success = await ref.read(bookingActionProvider).createAppointment(
      stylistId: widget.stylist.id,
      date: _selectedDate!.toIso8601String(),
      time: _selectedTime,
      packageType: _selectedService?.packageType ?? 'Custom',
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booked with ${widget.stylist.name}!')),
      );
      // Refresh bookings
      ref.invalidate(bookingsProvider);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stylist;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Header image
                SliverAppBar(
                  expandedHeight: 300,
                  backgroundColor: AppColors.black,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(s.profileImage, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                              stops: const [0.3, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20, left: 20, right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: GoogleFonts.playfairDisplay(
                                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                                fontStyle: FontStyle.italic,
                              )),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _infoBadge('Experience', '${s.experienceYears}+ years'),
                                  const SizedBox(width: 24),
                                  _infoBadge('Location', s.location),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details', style: GoogleFonts.playfairDisplay(
                          fontSize: 20, color: AppColors.gold, fontStyle: FontStyle.italic,
                        )),
                        const SizedBox(height: 16),
                        // Service selection
                        _detailRow('Service', ''),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: s.services.map((svc) {
                            final isSelected = _selectedService == svc;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedService = svc),
                              child: Chip(
                                label: Text(svc.name, style: TextStyle(
                                  color: isSelected ? AppColors.black : AppColors.greyLight, fontSize: 13,
                                )),
                                backgroundColor: isSelected ? AppColors.gold : AppColors.cardDark,
                                side: BorderSide(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        // Date & Time
                        _detailRow('Date & Time', ''),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 90)),
                                    builder: (ctx, child) {
                                      return Theme(
                                        data: Theme.of(ctx).copyWith(
                                          colorScheme: const ColorScheme.dark(primary: AppColors.gold, surface: AppColors.cardDark),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) setState(() => _selectedDate = date);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.cardBorder),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: AppColors.gold, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDate == null
                                          ? 'Select date'
                                          : '${_dayName(_selectedDate!)}, ${_selectedDate!.day} ${_monthName(_selectedDate!)} ${_selectedDate!.year}',
                                        style: TextStyle(color: _selectedDate == null ? AppColors.greyMid : Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.cardBorder),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: AppColors.gold, size: 16),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _selectedTime,
                                    dropdownColor: AppColors.cardDark,
                                    underline: const SizedBox(),
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    items: ['9:00 am', '10:00 am', '11:00 am', '12:00 pm', '1:00 pm', '2:00 pm', '3:00 pm', '4:00 pm']
                                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedTime = v);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Comments', style: GoogleFonts.playfairDisplay(
                          fontSize: 20, color: AppColors.gold, fontStyle: FontStyle.italic,
                        )),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentsController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'Any specific instructions'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Pay button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                child: Text('Pay £${_selectedService?.price.toInt() ?? 50}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 14)),
        if (value.isNotEmpty) ...[
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }

  Widget _infoBadge(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _dayName(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
  String _monthName(DateTime d) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}
