This package allows you to easily create a full CI/CD Gitlab pipeline for your Flutter applications.
It asks you if you wanna generate a CI/CD with tests reports, a SonarQube properties file, 
a Docker image for the web and a deploy to gitlab pages.

## Features

* Generate a full CI/CD pipeline for your Flutter application, with tests reports
* Generate a SonarQube properties file to deploy your tests reports to SonarQube
* Generate a Docker image that is built and pushed to your Gitlab project registry. Some modifications are needed in order for you to make it work on your Gitlab.
* Deploy your tests reports to your Gitlab pages.

## Getting started

To use this package, you first need to add it in your `dev_dependencies` from your
`pubspec.yml` file like this:

```yaml
dev_dependencies:
  flutter_ci_cd_gen: [latest version here]
```

Than, to generate all the file needed, you need to run the command `flutter pub run flutter_ci_cd_gen:generate`.
Answer the questions by `y` or `n` to generate the files.

## Changes you might need to make in order to make it work on your Gitlab
You can chose to use the default settings, if you do, you'll have to see the text below,
else, you can change the settings in the command line.

### Docker image (to deploy your flutter web app easily with docker)
If you choose to generate a Docker image, in the generated `Dockerfile`, change the line:
`FROM cirrusci/flutter:3.1.0` to the flutter version you have. For example: `FROM cirrusci/flutter:[version here]`.

If you want to change de default port of the container made with the image, change it in the `Dockerfile` like this:
`EXPOSE [port here]` instead of `EXPOSE 5000`. Here, the default port is 5000.
You also need to change it in `server/server.sh`, change the line `PORT=5000` to `PORT=[port here]` and
`fuser -k 5000/tcp` like that : `fuser -k [port here]/tcp`.

You also need to change the tag of the Gitlab Runner to run it on a Runner with privileged access.
Change the following lines:
```yaml
  tags:
    - image_deploy
```
to 
```yaml
  tags:
    - [tag here]
```
It might work without any tags.

By default, there is two images built, one with the tag latest and one with the
version you choose. You can set the version in two ways:

* By changing the variable `$CI_IMAGE_VERSION` with a version number like `1.0.0` in the `.gitlab-ci.yml` file.
* By adding a CI/CD variable on your Gitlab project with the name `CI_IMAGE_VERSION` and a value like `1.0.0`.


### SonarQube properties file
If you choose to generate a SonarQube properties file, in the generated `sonar-project.properties`, change the line:
`sonar.projectKey=<project-key>` to the project key you have from SonarQube

### CD/CD pipeline
If you choose to generate a CD/CD pipeline, in the generated `.gitlab-ci.yml`, change the following line
to adapt it to your flutter version:

```yaml
default:
  image: "cirrusci/flutter:3.0.1"
```

Change it to :

```yaml
default:
  image: "cirrusci/flutter:[version here]"
```
## Issues and improvements
I know that for now, there is a lot to change if you want to make it work properly, but 
I've planed to improve the project a lot. Please visit the [Gitlab pages of this project](https://git.simonbraillard.ch/flutter-packages/flutter-ci-cd-gen.git) to 
report any issues.