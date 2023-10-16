This umbrella chart is created to deploy my motivation for Autoscaling Selenium Grid on Kubernetes, details as below

![Scalable Grid](docs/central_grid_diagram.png)

More details on my motivation are mentioned in the presentation [here](docs/Topic_Scalable-Parallel-AT_Publish.pdf).

## System requires

1. Maven (Tested version 3.8.6)
2. Helm v3 (Tested version v3.11.3)
3. Kubernetes (Tested version v1.25.5 - Runtime: Docker v20.10.24 - Provisioned by Minikube v1.26.1)

## Install the chart

```shell
# Add ndviet helm repository
helm repo add ndviet https://www.ndviet.org/charts

# Update charts from ndviet repo
helm repo update

# List all versions present in the ndviet repo
helm search repo ndviet/scalable-selenium-grid --versions

# Install full components as default with latest version
helm upgrade -i test-grid ndviet/scalable-selenium-grid

# Download the chart latest version to local
helm fetch ndviet/scalable-selenium-grid --untar
```

## Build the umbrella chart

```shell
mvn clean install
```
Built chart is located under target/helm/repo/scalable-selenium-grid-x.x.x.tgz

## Change Log

### :heavy_check_mark: 23.10.12
**Removed**
- Templates to create scaledObject in module [grid-autoscaling](charts/grid-autoscaling/templates) (Fortunately, [Selenium-Grid Helm Chart](charts/selenium-grid/README.md) added autoscaling in default values.yaml from version [0.19.0](https://github.com/SeleniumHQ/docker-selenium/blob/trunk/charts/selenium-grid/CHANGELOG.md#heavy_check_mark-0190))

**Updated**
- Use ```node.sidecars``` to define the second container for video-recording (Refer to chart [scalable-selenium-grid/values.yaml](scalable-selenium-grid/src/main/resources/scalable-selenium-grid/values.yaml) for more details)
- Chart dependencies:
  - selenium-grid ```(0.15.8 -> 0.22.0)```
  - keda ```(2.10.1 -> 2.12.0)```

**Added**
- Use ConfigMap to override scripts, configs in video-recording container (Refer to [patch-selenium-grid](patch-selenium-grid/src/main/resources/patch-selenium-grid/patch/configurations/Video))
- Video container refer to ENV ```DRAIN_AFTER_SESSION_COUNT``` to terminate the container together with browser node.
- Video container support graceful shutdown, terminate the container after the ongoing recording are completed.
- Video support API via port 9000 to get status
    * GET ```/status```: return status ```true/false``` of pid "video.sh" is running. Can be used in startupProbe, livenessProbe to check whether container is healthy.
    * GET ```/recording```: return status ```true/false``` of pid "ffmpeg" is running.
    * POST ```/drain```: terminating with grace. Can call this API in container ```lifecycle.preStop.exec.command``` Or in part of ```selenium-grid.autoscaling.deregisterLifecycle.preStop.exec.command``` to gracefully shut down the container together with browser node.
- Those above features need to use with image [ndviet/video:ffmpeg-4.4.3-20231012](https://hub.docker.com/r/ndviet/video)

### :heavy_check_mark: 23.9.26
**Added**
- Umbrella chart to deploy scalable selenium grid in module [scalable-selenium-grid](scalable-selenium-grid)