import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../constant/app_colors.dart';
import '../utils/text_widget.dart';

class LiveMapWidget extends StatefulWidget {
  final double height;
  final Function(LatLng)? onLocationSelected;
  final LatLng? initialLocation;
  final bool showCurrentLocationButton;
  final bool showSearchButton;
  final VoidCallback? onSearchTap;

  const LiveMapWidget({
    super.key,
    this.height = 450,
    this.onLocationSelected,
    this.initialLocation,
    this.showCurrentLocationButton = true,
    this.showSearchButton = true,
    this.onSearchTap,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService.to;

  // Map state
  LatLng _currentLocation = const LatLng(40.7128, -74.0060); // Default to NYC
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // Camera position
  CameraPosition get _cameraPosition => CameraPosition(
        target: _currentLocation,
        zoom: 15.0,
      );

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Initialize location and map
  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current location
      final location = await _locationService.getCurrentLocation();
      if (location != null &&
          location.latitude != null &&
          location.longitude != null) {
        _currentLocation = LatLng(location.latitude!, location.longitude!);

        // Add current location marker
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation,
            infoWindow: InfoWindow(
              title: 'Current Location',
              snippet: _locationService.currentAddress,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      } else if (widget.initialLocation != null) {
        _currentLocation = widget.initialLocation!;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error initializing location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Move camera to current location
  Future<void> _moveToCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null &&
          location.latitude != null &&
          location.longitude != null) {
        final newLocation = LatLng(location.latitude!, location.longitude!);

        _mapController.animateCamera(
          CameraUpdate.newLatLng(newLocation),
        );

        setState(() {
          _currentLocation = newLocation;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: newLocation,
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: _locationService.currentAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
          );
        });
      }
    } catch (e) {
      print('❌ Error moving to current location: $e');
    }
  }

  /// Handle map tap
  void _onMapTap(LatLng position) {
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(position);
    }

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  /// Handle map created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      // Map is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Google Map
            if (_isLoading)
              Container(
                color: AppColors.greyColor.withValues(alpha: 0.1),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      TextWidget(
                        text: 'Loading map...',
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ],
                  ),
                ),
              )
            else
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _cameraPosition,
                markers: _markers,
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                onCameraMove: (CameraPosition position) {
                  // Update current location as user moves the map
                  _currentLocation = position.target;
                },
              ),

            // Top controls
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  // Search button
                  if (widget.showSearchButton)
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onSearchTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(25.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.greyColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              TextWidget(
                                text: 'Search location...',
                                fontSize: 14.sp,
                                color: AppColors.greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (widget.showSearchButton) SizedBox(width: 12.w),

                  // Current location button
                  if (widget.showCurrentLocationButton)
                    GestureDetector(
                      onTap: _moveToCurrentLocation,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextWidget(
                        text: _locationService.currentAddress.isNotEmpty
                            ? _locationService.currentAddress
                            : 'Getting location...',
                        fontSize: 12.sp,
                        color: AppColors.blackColor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
