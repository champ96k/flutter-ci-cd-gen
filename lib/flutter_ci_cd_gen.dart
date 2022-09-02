library flutter_ci_cd_gen;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const String flutterCICDURL =
    "https://git.simonbraillard.ch/-/snippets/6/raw/master/.gitlab-ci.yml?inline=false";
const String flutterCICDDockerURL =
    "https://git.simonbraillard.ch/-/snippets/9/raw/master/.gitlab-ci.yml?inline=false";
const String flutterCICDSonarURL =
    "https://git.simonbraillard.ch/-/snippets/7/raw/master/.gitlab-ci.yml?inline=false";
const String flutterCICDPagesURL =
    "https://git.simonbraillard.ch/-/snippets/8/raw/master/.gitlab-ci.yml?inline=false";
const String sonarPropertiesURL =
    "https://git.simonbraillard.ch/-/snippets/2/raw/master/sonar-project.properties?inline=false";
const String dockerfileURL =
    "https://git.simonbraillard.ch/-/snippets/4/raw/master/Dockerfile?inline=false";
const String startServerURL =
    "https://git.simonbraillard.ch/-/snippets/5/raw/master/server.sh?inline=false";
const String headerFileURL =
    "https://git.simonbraillard.ch/-/snippets/10/raw/master/header.txt?inline=false";

const String defaultPort = "5000";
const String defaulFlutterVersion = "3.0.1";
const String defaultRunnerTag = "image_deploy";
const String defaultImageVersion = "\$CI_IMAGE_VERSION";
const String defaultSonarQubeProjectKey = "<project-key>";

/// A Calculator.
void generate() async {
  Response? ciCdResponse;
  Response? dockerResponse;
  Response? sonarResponse;
  Response? pagesResponse;
  Response? sonarPropertiesResponse;
  Response? dockerfileResponse;
  Response? startServerResponse;
  Response? headerFileResponse;
  String port = defaultPort;
  String flutterVersion = defaulFlutterVersion;
  String runnerTag = defaultRunnerTag;
  String imageVersion = defaultImageVersion;
  String sonarQubeProjectKey = defaultSonarQubeProjectKey;

  debugPrint('Do you want to use SonarQube? (y/n) ');
  String? useSonar = stdin.readLineSync(encoding: utf8)?.toLowerCase();
  debugPrint('Do you want to use Pages? (y/n) ');
  String? usePages = stdin.readLineSync(encoding: utf8)?.toLowerCase();
  debugPrint('Do you want to create a Docker image? (y/n) ');
  String? useDocker = stdin.readLineSync(encoding: utf8)?.toLowerCase();
  String? useCiCd = 'y';

  if (useSonar == 'n' && usePages == 'n') {
    debugPrint('Do you want to use CI/CD with test coverage? (y/n) ');
    useCiCd = stdin.readLineSync(encoding: utf8)?.toLowerCase();
  }

  debugPrint('Do you want to use the default settings? (y/n) ');
  String? useDefaultSettings =
      stdin.readLineSync(encoding: utf8)?.toLowerCase();

  useCiCd = setDefaultValues(useCiCd);
  useSonar = setDefaultValues(useSonar);
  usePages = setDefaultValues(usePages);
  useDocker = setDefaultValues(useDocker);
  useDefaultSettings =
      setDefaultValues(useDefaultSettings, useByDefault: false);

  checkValues([useSonar, usePages, useDocker, useDefaultSettings, useCiCd]);

  if (useDefaultSettings == 'n') {
    if (useDocker == 'y') {
      debugPrint('Please enter the port number (By default: 5000): ');
      port = stdin.readLineSync(encoding: utf8) ?? defaultPort;
      port = (port.isEmpty) ? defaultPort : port;
      debugPrint('Please enter the runner tag (By default: image_deploy): ');
      runnerTag = stdin.readLineSync(encoding: utf8) ?? defaultRunnerTag;
      runnerTag = (runnerTag.isEmpty) ? defaultRunnerTag : runnerTag;
      debugPrint(
          'Please enter the image version (By default: \$CI_IMAGE_VERSION): ');
      imageVersion = stdin.readLineSync(encoding: utf8) ?? defaultImageVersion;
      imageVersion =
          (imageVersion.isEmpty) ? defaultImageVersion : imageVersion;
    }
    debugPrint('Please enter the Flutter version (By default: 3.0.1): ');
    flutterVersion = stdin.readLineSync(encoding: utf8) ?? defaulFlutterVersion;
    flutterVersion =
        (flutterVersion.isEmpty) ? defaulFlutterVersion : flutterVersion;
    if (useSonar == 'y') {
      debugPrint(
          'Please enter the SonarQube project key (By default: <project-key>): ');
      sonarQubeProjectKey =
          stdin.readLineSync(encoding: utf8) ?? defaultSonarQubeProjectKey;
      sonarQubeProjectKey = (sonarQubeProjectKey.isEmpty)
          ? defaultSonarQubeProjectKey
          : sonarQubeProjectKey;
    }
  }

  headerFileResponse = await http.get(Uri.parse(headerFileURL));
  if (headerFileResponse.statusCode != 200) {
    debugPrint('Error: Could not download header file');
    exit(1);
  } else {
    debugPrint('Downloaded header file');
  }

  if (useCiCd == 'y') {
    ciCdResponse = await http.get(Uri.parse(flutterCICDURL));
    if (ciCdResponse.statusCode != 200) {
      debugPrint('Error: Could not download CI/CD file');
      exit(1);
    } else {
      debugPrint('Downloaded CI/CD file');
    }
  }

  if (usePages == 'y') {
    pagesResponse = await http.get(Uri.parse(flutterCICDPagesURL));
    if (pagesResponse.statusCode != 200) {
      debugPrint('Error: Could not download Pages file');
      exit(1);
    } else {
      debugPrint('Downloaded Pages file');
    }
  }

  if (useSonar == 'y') {
    sonarResponse = await http.get(Uri.parse(flutterCICDSonarURL));
    sonarPropertiesResponse = await http.get(Uri.parse(sonarPropertiesURL));
    if (sonarResponse.statusCode != 200 ||
        sonarPropertiesResponse.statusCode != 200) {
      debugPrint('Error: Could not download Sonar config files');
      exit(1);
    } else {
      debugPrint('SonarQube properties file downloaded');
    }
  }

  if (useDocker == 'y') {
    dockerResponse = await http.get(Uri.parse(flutterCICDDockerURL));
    dockerfileResponse = await http.get(Uri.parse(dockerfileURL));
    startServerResponse = await http.get(Uri.parse(startServerURL));
    if (dockerResponse.statusCode != 200 ||
        dockerfileResponse.statusCode != 200 ||
        startServerResponse.statusCode != 200) {
      debugPrint('Error: Could not download Docker config files');
      exit(1);
    } else {
      debugPrint('Docker config files downloaded');
    }
  }

  String? dockerfileResponseText = dockerfileResponse?.body;
  String? startServerResponseText = startServerResponse?.body;
  String? dockerResponseText = dockerResponse?.body;
  String? ciCdResponseText = ciCdResponse?.body;
  String? sonarPropertiesResponseText = sonarPropertiesResponse?.body;

  dockerResponseText = dockerResponseText
      ?.replaceAll("%ciImageVersion%", imageVersion)
      .replaceAll("%runnerTag%", runnerTag);
  ciCdResponseText =
      ciCdResponseText?.replaceAll("%flutterVersion%", flutterVersion);
  startServerResponseText = startServerResponseText?.replaceAll("%port%", port);
  dockerfileResponseText = dockerfileResponseText
      ?.replaceAll("%port%", port)
      .replaceAll("%flutterVersion%", flutterVersion);
  sonarPropertiesResponseText = sonarPropertiesResponseText?.replaceAll(
      "%projectKey%", sonarQubeProjectKey);

  File("./.gitlab-ci.yml").writeAsBytes(headerFileResponse.bodyBytes +
      utf8.encode("\n\n") +
      (utf8.encode(ciCdResponseText ?? "")) +
      utf8.encode("\n") +
      (pagesResponse?.bodyBytes ?? []) +
      utf8.encode("\n") +
      (utf8.encode(dockerResponseText ?? "")) +
      utf8.encode("\n") +
      (sonarResponse?.bodyBytes ?? []));

  if (useSonar == 'y' && sonarPropertiesResponseText != null) {
    File("./sonar-project.properties").writeAsBytes(
        headerFileResponse.bodyBytes +
            utf8.encode("\n\n") +
            utf8.encode(sonarPropertiesResponseText));
  }

  if (useDocker == 'y' &&
      dockerfileResponseText != null &&
      startServerResponseText != null) {
    File("./Dockerfile").writeAsBytes(headerFileResponse.bodyBytes +
        utf8.encode("\n\n") +
        utf8.encode(dockerfileResponseText));
    bool directoryExists = await Directory("./server").exists();
    if (!directoryExists) {
      await Directory("./server").create(recursive: true);
      File("./server/server.sh")
          .writeAsBytes(utf8.encode(startServerResponseText));
    }
  }

  debugPrint("Success: Project files generated.");
}

String? setDefaultValues(String? value, {bool useByDefault = true}) {
  if (value != null && value.isEmpty) {
    if (useByDefault) {
      return 'y';
    }
    return 'n';
  } else if (value == 'y') {
    return 'y';
  } else if (value == 'n') {
    return 'n';
  }
  return null;
}

void checkValues(List<String?> values) {
  for (String? value in values) {
    if (value != 'y' && value != 'n') {
      debugPrint("Error: One or more entries are not 'y' or 'n'.");
      exit(1);
    }
  }
}
