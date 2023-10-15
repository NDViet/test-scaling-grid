This umbrella chart is created to deploy my motivation for Autoscaling Selenium Grid on Kubernetes, details as below

![Scalable Grid](docs/central_grid_diagram.png)

More details on my motivation are mentioned in the presentation [here](docs/Topic_Scalable-Parallel-AT_Publish.pdf).

## System requires

1. Maven (Tested version 3.8.4)
2. Helm v3 (Tested version v3.8.2)
3. Kubernetes (Tested version v1.23.13 - Runtime: docker - Provisioned by Minikube v1.26.0)

## Build the umbrella chart

```shell
mvn clean install
```
Built chart is located under target/helm/repo/scalable-selenium-grid-x.x.x.tgz

## Change Log

### :heavy_check_mark: 23.10.0
**Removed**
- Templates to create scaledObject in module [grid-autoscaling](charts/grid-autoscaling/templates) (Fortunately, [Selenium-Grid Helm Chart](charts/selenium-grid/README.md) added autoscaling in default values.yaml from version [0.19.0](https://github.com/SeleniumHQ/docker-selenium/blob/trunk/charts/selenium-grid/CHANGELOG.md#heavy_check_mark-0190))

**Updated**
- Use ```node.sidecars``` to define the second container for video-recording (Refer to chart [scalable-selenium-grid/values.yaml](scalable-selenium-grid/src/main/resources/scalable-selenium-grid/values.yaml) for more details)

**Added**
- Use ConfigMap to override scripts, configs in video-recording container (Refer to [patch-selenium-grid](patch-selenium-grid/src/main/resources/patch-selenium-grid/patch/configurations/Video))
- Video container refer to ENV ```DRAIN_AFTER_SESSION_COUNT``` to terminate the container together with browser node.
- Video container support graceful shutdown, terminate the container after the ongoing recording are complete.
- Video support API via port 9000 to get status
    * GET ```/status```: return status ```true/false``` of pid "video.sh" is running. Can be used in startupProbe, livenessProbe to check whether container is healthy.
    * GET ```/recording```: return status ```true/false``` of pid "ffmpeg" is running.
    * POST ```/drain```: terminating with grace. Can call this API in container ```lifecycle.preStop.exec.command``` Or in part of ```selenium-grid.autoscaling.deregisterLifecycle.preStop.exec.command``` to gracefully shut down the container together with browser node.

### :heavy_check_mark: 23.9.0
**Added**
- Umbrella chart to deploy scalable selenium grid in module [scalable-selenium-grid](scalable-selenium-grid)