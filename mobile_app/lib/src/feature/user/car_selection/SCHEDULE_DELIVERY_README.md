# Schedule Delivery Feature

## Overview
The "Deliver Now" button has been replaced with "Schedule Delivery" which allows users to schedule deliveries with specific date and time slots based on the day of the week.

## Time Slot Rules

**Backend API Accepted Slots**: `08:00-10:00`, `10:00-12:00`, `12:00-14:00`, `14:00-16:00`, `16:00-18:00`, `18:00-20:00`

### Weekdays (Monday - Friday)
- **Business Hours**: 5:00 PM - 8:00 PM
- **Available Time Slots** (2-hour blocks):
  - 4:00 PM - 6:00 PM (`16:00-18:00`) - Covers 5PM-6PM requirement
  - 6:00 PM - 8:00 PM (`18:00-20:00`) - Covers 6PM-8PM requirement

### Weekends (Saturday - Sunday)
- **Business Hours**: 8:00 AM - 8:00 PM
- **Available Time Slots** (2-hour blocks):
  - 8:00 AM - 10:00 AM (`08:00-10:00`)
  - 10:00 AM - 12:00 PM (`10:00-12:00`)
  - 12:00 PM - 2:00 PM (`12:00-14:00`)
  - 2:00 PM - 4:00 PM (`14:00-16:00`)
  - 4:00 PM - 6:00 PM (`16:00-18:00`)
  - 6:00 PM - 8:00 PM (`18:00-20:00`)

## Files Modified/Created

### New Files
1. **`schedule_delivery_dialog.dart`**
   - Custom dialog for scheduling deliveries
   - Integrated calendar date picker
   - Dynamic time slot selection based on selected day
   - Beautiful UI with proper validation

### Modified Files
1. **`car_selection.dart`**
   - Changed "Deliver Now" button to "Schedule Delivery"
   - Integrated schedule dialog
   - Updated delivery creation flow to include schedule data
   - Sets `scheduleType` to 'scheduled'
   - Passes `scheduledDate` and `timeSlot` to HomeController

## How It Works

### User Flow
1. User fills in delivery details (pickup, dropoff, vehicle, etc.)
2. User uploads item photo
3. User clicks **"Schedule Delivery"** button
4. Schedule dialog opens with:
   - Calendar to select date (can schedule up to 90 days in advance)
   - Time slots that automatically adjust based on selected day
   - Visual feedback for selected date and time
5. User selects date and time slot
6. User clicks "Confirm Schedule"
7. Delivery is created with scheduled information
8. User proceeds to payment

### Technical Flow
```dart
// When user clicks Schedule Delivery button
showDialog(
  context: context,
  builder: (context) => ScheduleDeliveryDialog(
    onScheduled: (DateTime date, String timeSlot) async {
      // Set schedule data in HomeController
      homeController.scheduleType.value = 'scheduled';
      homeController.scheduledDate.value = date;
      homeController.timeSlot.value = timeSlot;
      
      // Create delivery with schedule
      await homeController.createDelivery();
      
      // Navigate to payment
      Get.to(() => PaymentMethodScreen());
    },
  ),
);
```

## API Integration

The scheduled delivery data is sent to the backend via the existing `/deliveries/create` endpoint:

```json
{
  "schedule_type": "scheduled",
  "scheduled_date": "2024-12-15",
  "time_slot": "17:00-18:00",
  // ... other delivery fields
}
```

## Features

### ✅ Calendar Integration
- Native Flutter date picker
- Minimum date: Today
- Maximum date: 90 days from today
- Custom theme matching app colors

### ✅ Dynamic Time Slots
- Automatically adjusts based on selected day
- Weekday vs Weekend detection
- Visual selection with color feedback
- 12-hour format display (AM/PM)

### ✅ Validation
- Requires both date and time slot selection
- Shows error if user tries to confirm without selection
- Prevents scheduling in the past

### ✅ User Experience
- Clean, modern UI
- Easy to understand time slots
- Day type indicator (Weekday/Weekend)
- Scrollable time slot list for better mobile UX
- Responsive design with ScreenUtil

## Testing Checklist

- [ ] Open car selection screen
- [ ] Click "Schedule Delivery" button
- [ ] Verify dialog opens with calendar
- [ ] Select a weekday date (Mon-Fri)
- [ ] Verify time slots show 5PM-10PM
- [ ] Select a weekend date (Sat-Sun)
- [ ] Verify time slots show 8AM-8PM
- [ ] Select a time slot
- [ ] Click "Confirm Schedule"
- [ ] Verify delivery is created with schedule data
- [ ] Verify navigation to payment screen
- [ ] Check backend receives correct schedule_type, scheduled_date, and time_slot

## Dependencies

All required dependencies are already in `pubspec.yaml`:
- `intl` - For date formatting
- `flutter_screenutil` - For responsive sizing
- `get` - For state management and navigation

## Future Enhancements

Potential improvements for future versions:
1. Show unavailable/booked time slots
2. Add delivery fee variations based on time slot
3. Show estimated driver availability per slot
4. Add recurring delivery scheduling
5. Send reminder notifications before scheduled delivery
6. Allow rescheduling from tracking page


