import 'dart:io';

import 'package:aplikasi_timbang/data/responses/cari_so_response.dart';
import 'package:aplikasi_timbang/data/responses/job_process_response.dart';
import 'package:aplikasi_timbang/data/responses/upload_bukti_response.dart';
import 'package:aplikasi_timbang/data/services/response.dart';
import 'package:aplikasi_timbang/utils/constants.dart';
import 'package:dio/dio.dart';

import '../responses/error_response.dart';

class SoService {
  Future<ApiResponse<CariSoResponse?>> findSo(int soId, String token) async {
    try {
      var response = await Dio().get(
        BASE_URL + '/job/find-so',
        queryParameters: {'search': soId.toString()},
        options: Options(
          headers: {
            'Authorization': 'Bearer ' + token,
          },
        ),
      );

      var result = ApiResponse(
          success: true,
          data: CariSoResponse.fromJson(response.data),
          message: 'Sukses mencari SO');
      return result;
    } on DioError catch (e) {
      if ((e.response?.statusCode ?? 500) == 401) {
        var result = ApiResponse(
          success: false,
          data: null,
          message: 'Sesi telah berakhir. Mohon login kembali.',
        );
        return result;
      }
      var result = ApiResponse(
          success: false,
          data: null,
          message: 'Gagal mencari SO: ' + e.message);
      return result;
    } on TypeError catch (e) {
      var result = ApiResponse(
          success: false,
          data: null,
          message: 'Maaf terjadi kesalahan: ' + e.toString());
      return result;
    }
  }

  Future<ApiResponse<UploadBuktiResponse?>> uploadBuktiVerifikasi(
      File file, String token) async {
    try {
      var body = FormData.fromMap({
        'files': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });

      var response = await Dio().post(
        BASE_URL + "/job/upload-image",
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer ' + token,
          },
        ),
      );

      if (response.data != null && response.data!.isNotEmpty) {
        List<UploadBuktiResponse> uploadBuktiResponseList = List.from(
            response.data!.map((e) => UploadBuktiResponse.fromJson(e)));
        return ApiResponse(
          success: true,
          data: uploadBuktiResponseList.first,
          message: 'Sukses mengupload bukti verifikasi',
        );
      } else {
        return ApiResponse(
          success: false,
          data: null,
          message: 'Gagal mengupload bukti verifikasi',
        );
      }
    } on DioError catch (e) {
      var errorResponse = e.response;
      if (errorResponse != null) {
        var errorMessage = ApiErrorResponse.fromJson(errorResponse.data);

        return ApiResponse(
          success: false,
          data: null,
          message: errorMessage.message ?? '',
        );
      }
      return ApiResponse(
        success: false,
        data: null,
        message: 'Gagal mengupload bukti verifikasi: ' + e.message,
      );
    }
  }

  Future<ApiResponse<ProcessJobResponse?>> processJob(
      Map<String, dynamic> request, int jobId, String token) async {
    try {
      var response = await Dio().post(
        BASE_URL + '/job/process/$jobId',
        data: request,
        options: Options(
          headers: {
            'Authorization': 'Bearer ' + token,
          },
        ),
      );

      var data = ProcessJobResponse.fromJson(response.data);

      return ApiResponse(
        success: true,
        data: data,
        message: 'Sukses memproses produk',
      );
    } on DioError catch (e) {
      var errorResponse = e.response;
      if (errorResponse != null) {
        var errorMessage = ApiErrorResponse.fromJson(errorResponse.data);
        return ApiResponse(
          success: true,
          data: null,
          message: errorMessage.message ?? '',
        );
      } else {
        return ApiResponse(
          success: true,
          data: null,
          message: e.message,
        );
      }
    }
  }

  Future<ApiResponse> completeJob(int jobId, String token) async {
    try {
      var response = await Dio().patch(
        BASE_URL + '/job/complete/$jobId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ' + token,
          },
        ),
      );

      return ApiResponse(
          success: true, data: null, message: 'Sukses memproses produk');
    } on DioError catch (e) {
      var errorResponse = e.response;
      if (errorResponse != null) {
        var errorMessage = ApiErrorResponse.fromJson(errorResponse.data);
        return ApiResponse(
          success: true,
          data: null,
          message: errorMessage.message ?? '',
        );
      } else {
        return ApiResponse(
          success: true,
          data: null,
          message: e.message,
        );
      }
    }
  }
}