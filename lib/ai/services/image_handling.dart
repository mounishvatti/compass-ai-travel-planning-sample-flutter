// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as imgpkg;

import 'package:http/http.dart' as http;

var imageResourceEndpoint = 'uploadimgtrip-hovwuqnpzq-uc.a.run.app';
var imageMimeTypeResourceEndpoint = 'us-central1-yt-rag.cloudfunctions.net';

class UserSelectedImage {
  String path;
  Uint8List bytes;

  UserSelectedImage(this.path, this.bytes);

  Future<Uint8List?> get smallBytes async {
    imgpkg.Image? img = await compute(imgpkg.decodeImage, bytes);

    if (img == null) {
      return null;
    }

    imgpkg.Image smallImg = imgpkg.copyResize(img, width: 250);
    Uint8List smallBytes = imgpkg.encodeJpg(smallImg, quality: 10);

    debugPrint(smallBytes.lengthInBytes.toString());

    return smallBytes;
  }
}

class ImageClient {
  static String? getMimeType(UserSelectedImage image) {
    List<int> header = [];

    for (var element in image.bytes) {
      if (element == 0) continue;
      header.add(element);
    }

    String? mimeType = lookupMimeType(image.path, headerBytes: header);

    return mimeType;
  }

  static tempUrls(String mimeType) async {
    var endpoint = Uri.https(
      imageResourceEndpoint,
      '/UploadImgTrip',
    );

    if (mimeType != 'image/png' && mimeType != 'image/jpeg') return;

    try {
      var response = await http.get(endpoint, headers: {
        'mime': mimeType,
      });

      var jsonMap = jsonDecode(response.body) as Map<String, dynamic>;

      String uploadUrl, downloadUrl;

      {
        'uploadLocation': uploadUrl as String,
        'downloadLocation': downloadUrl as String,
      } = jsonMap;

      return (uploadUrl, downloadUrl);
    } catch (e) {
      debugPrint(e.toString());
      throw ('couldn\'t get image processing urls');
    }
  }

  /*static Future<String> uploadImage(File imageFile) async {
    String uploadUrl, downloadUrl;
    (uploadUrl, downloadUrl) = await ImageClient.tempUrls;

    await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: await imageFile.readAsBytes(),
    );

    return downloadUrl;
  }*/

  static Future<String> uploadImageBytes(UserSelectedImage image) async {
    String uploadUrl, downloadUrl;
    var mimeType = getMimeType(image);

    if (!['image/jpeg', 'image/png'].contains(mimeType) || mimeType == null) {
      throw ("Sorry we don't support that file type.");
    }

    (uploadUrl, downloadUrl) = await ImageClient.tempUrls(mimeType);

    await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': mimeType,
      },
      body: image.bytes,
    );

    debugPrint(downloadUrl);

    return downloadUrl;
  }

  static Future<List<String>> uploadImagesBytes(
      List<UserSelectedImage> images) async {
    try {
      List<Future<String>> imagesFutures = List.generate(
        images.length,
        (idx) => uploadImageBytes(images[idx]),
      );

      var imagesDownloadUrls = await Future.wait(imagesFutures);

      debugPrint('Uploaded all images!\n$imagesDownloadUrls');

      return imagesDownloadUrls;
    } catch (e) {
      throw ('Unable to upload images');
    }
  }

  static Future<List<String>> base64EncodeImages(
      List<UserSelectedImage> images) async {
    try {
      List<String> base64Encodedimages = [];

      for (var image in images) {
        var imgBytes = await image.smallBytes;

        if (imgBytes != null) {
          base64Encodedimages
              .add('data:image/jpeg;base64,${base64Encode(imgBytes)}');
        }
      }

      for (var image in base64Encodedimages) {
        debugPrint(image);
      }

      return base64Encodedimages;
    } catch (e) {
      throw ('Unable to upload images');
    }
  }
}

void main() async {
  //var imageFile = File('assets/images/la-jolla.jpeg');

  //var downloadUrl = await ImageClient.uploadImage(imageFile);

  //debugPrint('Uploaded! Check it out:\n$downloadUrl');

  /*var images = [
    File('assets/images/la-jolla.jpeg').readAsBytes(),
    File('assets/images/coronado-island.jpeg').readAsBytes(),
    File('assets/images/louvre.png').readAsBytes(),
    File('assets/images/paris.png').readAsBytes(),
  ];

  var imageBytes = await Future.wait(images);

  var downloadUrls = await ImageClient.uploadImagesBytes(imageBytes);

  debugPrint(downloadUrls);*/
}
