import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanModel {
  final int id;
  final DateTime createdAt;
  final String originalImageUrl;
  final String scannedImageUrl;
  final String prediction;
  final int spots;
  final String report;
  final String userId;

  ScanModel({
    required this.id,
    required this.createdAt,
    required this.originalImageUrl,
    required this.scannedImageUrl,
    required this.prediction,
    required this.spots,
    required this.report,
    required this.userId,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      originalImageUrl: json['original_image_url'],
      scannedImageUrl: json['scanned_image_url'],
      prediction: json['prediction'],
      spots: json['spots'],
      report: json['report'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'original_image_url': originalImageUrl,
      'scanned_image_url': scannedImageUrl,
      'prediction': prediction,
      'spots': spots,
      'report': report,
      'user_id': userId,
    };
  }
}

class ScanProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ScanModel> _scans = [];
  bool _isLoading = false;
  String _error = '';

  List<ScanModel> get scans => List.unmodifiable(_scans);
  bool get isLoading => _isLoading;
  String get error => _error;

  void resetScans() {
    _scans = [];
    notifyListeners();
  }

  Future<void> fetchUserScans(String userId) async {
    _setLoading(true);
    _setError('');

    try {
      final response = await _supabase
          .from('scans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 30));

      if (response.isEmpty) {
        _scans = [];
        _setError('No scans found for this user');
        return;
      }

      _scans =
          response.map((scanData) => ScanModel.fromJson(scanData)).toList();
    } on PostgrestException catch (e) {
      _setError('Database error: ${e.message}');
      _scans = [];
    } on TimeoutException {
      _setError('Request timed out. Please check your internet connection');
      _scans = [];
    } on SocketException {
      _setError('Network error. Please check your internet connection');
      _scans = [];
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _scans = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addScan(ScanModel scan) async {
    _setLoading(true);
    _setError('');

    try {
      // Validate required fields
      if (scan.originalImageUrl.isEmpty || scan.userId.isEmpty) {
        throw Exception('Missing required scan data');
      }

      final response = await _supabase.from('scans').insert({
        'original_image_url': scan.originalImageUrl,
        'scanned_image_url': scan.scannedImageUrl,
        'prediction': scan.prediction,
        'spots': scan.spots,
        'report': scan.report,
        'user_id': scan.userId,
        'created_at': scan.createdAt.toIso8601String(),
      }).timeout(const Duration(seconds: 30));

      if (response.error != null) {
        throw Exception(response.error?.message ?? 'Failed to add scan');
      }

      // Refresh the scans list
      await fetchUserScans(scan.userId);
      return true;
    } on PostgrestException catch (e) {
      _setError('Database error: ${e.message}');
      return false;
    } on TimeoutException {
      _setError('Request timed out. Please check your internet connection');
      return false;
    } catch (e) {
      _setError('Failed to add scan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteScan(int scanId, String userId) async {
    _setLoading(true);
    _setError('');

    try {
      // Validate inputs
      if (scanId <= 0 || userId.isEmpty) {
        throw Exception('Invalid scan ID or user ID');
      }

      final response = await _supabase
          .from('scans')
          .delete()
          .eq('id', scanId)
          .timeout(const Duration(seconds: 30));

      // Supabase returns null on successful deletion
      if (response == null) {
        // Refresh the scans list
        await fetchUserScans(userId);
        return true;
      }

      // If we get here, there might be an error
      if (response.error != null) {
        throw Exception(response.error?.message ?? 'Failed to delete scan');
      }

      // Refresh the scans list
      await fetchUserScans(userId);
      return true;
    } on PostgrestException catch (e) {
      _setError('Database error: ${e.message}');
      return false;
    } on TimeoutException {
      _setError('Request timed out. Please check your internet connection');
      return false;
    } catch (e) {
      _setError('Failed to delete scan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
