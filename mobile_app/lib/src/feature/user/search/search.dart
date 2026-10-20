import 'dart:async';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/common/services/location_service.dart';
import 'package:deliver_mee/src/common/services/location_suggestion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SearchScreen extends StatefulWidget {
  final bool tolocation;
  final String location;
  SearchScreen({
    super.key,
    required this.tolocation,
    required this.location,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService.to;
  final LocationSuggestionService _suggestionService =
      LocationSuggestionService.to;
  final TextEditingController _searchController = TextEditingController();

  // Map state
  LatLng _selectedLocation = const LatLng(40.7128, -74.0060); // Default to NYC
  Set<Marker> _markers = {};
  String _selectedAddress = '';
  bool _showSuggestions = false;

  // Camera position
  CameraPosition get _cameraPosition => CameraPosition(
        target: _selectedLocation,
        zoom: 15.0,
      );

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.location;
    _searchController.text = widget.location; // Pre-fill search field
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize location and map
  Future<void> _initializeLocation() async {
    try {
      // If we have an existing location passed in, geocode it to get coordinates if they are (0,0)
      // Otherwise, use current location as fallback only if widget.location is empty
      if (widget.location.isNotEmpty && 
          widget.location != 'Please select pickup location' && 
          widget.location != 'Please select dropoff location') {
        
        print('🔍 SearchScreen: Initializing with existing location: ${widget.location}');
        
        try {
          List<Location> locations = await locationFromAddress(widget.location);
          if (locations.isNotEmpty) {
            _selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);
            print('✅ Geocoded existing location to: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
          }
        } catch (e) {
          print('⚠️ Could not geocode existing location text, will try current location as fallback for map');
          // If geocoding fails, we'll try current location for map target below
        }
      }

      // If we still have default NYC or want to center on user for better UX
      if (_selectedLocation.latitude == 40.7128) {
        final location = await _locationService.getCurrentLocation();
        if (location != null &&
            location.latitude != null &&
            location.longitude != null) {
          // If widget.location was empty, set both address and coordinates
          if (widget.location.isEmpty || 
              widget.location == 'Please select pickup location' || 
              widget.location == 'Please select dropoff location') {
            _selectedLocation = LatLng(location.latitude!, location.longitude!);
            _getAddressFromPosition(_selectedLocation);
          } else {
            // Just center map but don't overwrite user's address text
            _selectedLocation = LatLng(location.latitude!, location.longitude!);
          }
        }
      }

      // Add marker for selected location
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: InfoWindow(
            title: widget.tolocation ? 'To Location' : 'From Location',
            snippet: _selectedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.tolocation
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Error initializing location: $e');
    }
  }

  /// Get address from position
  Future<void> _getAddressFromPosition(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
        setState(() {
          _selectedAddress = address;
          _searchController.text = address; // Update search bar with new address
        });
        print('📍 Address updated: $address');
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      final fallbackAddress =
          'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      setState(() {
        _selectedAddress = fallbackAddress;
        _searchController.text = fallbackAddress; // Update search bar with fallback
      });
    }
  }

  /// Search for location suggestions
  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
      });
      _suggestionService.clearSuggestions();
      return;
    }

    setState(() {
      _showSuggestions = true;
    });

    _suggestionService.searchSuggestions(query);
  }

  /// Select a location from suggestions
  void _selectSuggestion(LocationSuggestion suggestion) {
    setState(() {
      _selectedLocation = LatLng(suggestion.latitude, suggestion.longitude);
      _selectedAddress = suggestion.address;
      _showSuggestions = false;
      _searchController.text = suggestion.address;

      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: InfoWindow(
            title: widget.tolocation ? 'To Location' : 'From Location',
            snippet: suggestion.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.tolocation
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    });

    // Move camera to new location
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_selectedLocation),
    );

    // Clear suggestions
    _suggestionService.clearSuggestions();
  }

  /// Handle map tap
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: InfoWindow(
            title: widget.tolocation ? 'To Location' : 'From Location',
            snippet: _selectedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.tolocation
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    });

    _getAddressFromPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Google Maps
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: _onMapTap,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // Location top bar
          Positioned(
            top: 30.h,
            left: 20.w,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white,
                  shape: CircleBorder(),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                    customBorder: CircleBorder(),
                    child: Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.pinIcon,
                        height: 22.h,
                        width: 22.w,
                        colorFilter: ColorFilter.mode(
                          _selectedAddress.isNotEmpty
                              ? AppColors.primaryColor
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: TextWidget(
                          text: _selectedAddress.isNotEmpty
                              ? _selectedAddress
                              : widget.location,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: _selectedAddress.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      if (_selectedAddress.isNotEmpty)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // My Location button
          Positioned(
            right: 20.w,
            top: 300.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: IconButton(
                onPressed: () async {
                  final location = await _locationService.getCurrentLocation();
                  if (location != null &&
                      location.latitude != null &&
                      location.longitude != null) {
                    final newPosition =
                        LatLng(location.latitude!, location.longitude!);
                    _onMapTap(newPosition);
                    _mapController.animateCamera(
                      CameraUpdate.newLatLng(newPosition),
                    );
                  }
                },
                icon: SvgPicture.asset(
                  AppIcons.currentlocationIcon,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),
          ),

          // Search Location bottom bar
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 40.h,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 10.w),

                        // Flexible TextField to avoid overflow
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              _searchLocation(value);
                            },
                            onSubmitted: (value) {
                              _searchLocation(value);
                            },
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true, // removes extra vertical space
                              contentPadding: EdgeInsets.zero,
                              hintText: widget.tolocation
                                  ? 'Search dropoff location...'
                                  : 'Search pickup location...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              suffixIcon: Obx(() {
                                if (_suggestionService.isSearching) {
                                  return SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (_selectedAddress.isNotEmpty) {
                                  return Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryColor,
                                    size: 20.sp,
                                  );
                                }
                                return SizedBox.shrink();
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Location Suggestions
                  if (_showSuggestions)
                    Obx(() => _suggestionService.suggestions.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: _suggestionService.suggestions
                                  .map((suggestion) =>
                                      _buildSuggestionItem(suggestion))
                                  .toList(),
                            ),
                          )
                        : SizedBox.shrink()),

                  SizedBox(height: 20.h),
                  // Confirm Location Button
                  GestureDetector(
                    onTap: () {
                      print('🔵 Confirm button tapped');
                      final locationText = _searchController.text.trim();
                      print('📝 Location text: $locationText');
                      
                      if (locationText.isNotEmpty) {
                        print('✅ Updating controller with location: $locationText');
                        if (widget.tolocation) {
                          print('📍 Updating TO location');
                          ctrl.updateToLocation(
                              locationText,
                              _selectedLocation.latitude,
                              _selectedLocation.longitude);
                        } else {
                          print('📍 Updating FROM location');
                          ctrl.updateFromLocation(
                              locationText,
                              _selectedLocation.latitude,
                              _selectedLocation.longitude);
                        }

                        print('📍 From: ${ctrl.fromlocation.value}');
                        print('📍 To: ${ctrl.tolocation.value}');
                        print('🔙 Popping navigation stack');
                        
                        // Use Navigator.pop instead of Get.back
                        Navigator.of(context).pop();
                      } else {
                        print('❌ Location text is empty');
                        Get.snackbar(
                          'Location Required',
                          'Please enter a location in the search bar',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: Duration(seconds: 3),
                          icon: Icon(Icons.location_on, color: Colors.white),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                        color: _searchController.text.isNotEmpty
                            ? AppColors.primaryColor
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: 'Confirm Location',
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build suggestion item widget
  Widget _buildSuggestionItem(LocationSuggestion suggestion) {
    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: suggestion.address,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  if (suggestion.description?.isNotEmpty == true) ...[
                    SizedBox(height: 2.h),
                    TextWidget(
                      text: suggestion.description!,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
