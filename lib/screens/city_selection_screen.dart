import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({Key? key}) : super(key: key);

  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  Timer? _debounce;

  bool _isLoading = false;
  bool _isGettingLocation = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _popularCities = [
    {'name': 'İstanbul', 'country': 'Turkey'},
    {'name': 'Ankara', 'country': 'Turkey'},
    {'name': 'İzmir', 'country': 'Turkey'},
    {'name': 'London', 'country': 'United Kingdom'},
    {'name': 'Paris', 'country': 'France'},
    {'name': 'Berlin', 'country': 'Germany'},
    {'name': 'New York', 'country': 'United States'},
    {'name': 'Los Angeles', 'country': 'United States'},
    {'name': 'Chicago', 'country': 'United States'},
    {'name': 'Toronto', 'country': 'Canada'},
    {'name': 'Sydney', 'country': 'Australia'},
    {'name': 'Melbourne', 'country': 'Australia'},
    {'name': 'Dubai', 'country': 'United Arab Emirates'},
    {'name': 'Riyadh', 'country': 'Saudi Arabia'},
    {'name': 'Cairo', 'country': 'Egypt'},
    {'name': 'Jakarta', 'country': 'Indonesia'},
    {'name': 'Kuala Lumpur', 'country': 'Malaysia'},
    {'name': 'Singapore', 'country': 'Singapore'},
    {'name': 'Mumbai', 'country': 'India'},
    {'name': 'Karachi', 'country': 'Pakistan'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchQuery.length < 2) {
        setState(() => _searchResults = []);
      } else {
        _searchCities(_searchQuery);
      }
    });
  }

  Future<void> _searchCities(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await _geocodingService.searchCities(query);
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.locationErrorDetails('$e'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final address = await _locationService.getFullAddress(
            location.latitude!,
            location.longitude!
        );

        if (mounted) {
          Navigator.pop(context, {
            'type': 'location',
            'latitude': location.latitude,
            'longitude': location.longitude,
            'address': address ?? AppLocalizations.of(context)!.currentLocation,
          });
        }
      } else {
        _showError(AppLocalizations.of(context)!.locationError);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.locationErrorDetails('$e'));
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  void _selectCity(Map<String, dynamic> city) {
    Navigator.pop(context, {
      'type': 'city',
      'city': city['name'],
      'country': city['country'],
      'latitude': city['latitude'],
      'longitude': city['longitude'],
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectCityTitle),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Arama Alanı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.citySearchHint,
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            // Mevcut Konum Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isGettingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.useCurrentLocationButton,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Arama Sonuçları veya Popüler Şehirler
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildPopularCities(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noCityFoundMessage,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return _buildCityList(_searchResults);
  }

  Widget _buildPopularCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(context)!.popularCitiesTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildCityList(_popularCities)),
      ],
    );
  }

  Widget _buildCityList(List<Map<String, dynamic>> cities) {
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.location_city, color: Colors.teal),
              title: Text(
                city['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  if (city['admin1'] != null) city['admin1'],
                  if (city['country'] != null) city['country'],
                ].join(', '),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectCity(city),
            ),
          ),
        );
      },
    );
  }
}