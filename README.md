# Introduction
This project dockerises the deployment of [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) and its variants. It provides a default configuration corresponding to a standard deployment of the application with all extensions enabled, and a base version without extensions. Versions are offered for Nvidia GPU `nvidia`, AMD GPU (unstable) `rocm`, Intel Arc (unstable) `arc`, and CPU-only `cpu`. Pre-built images are available on Docker Hub: [https://hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui).

*The goal of this project is to be to [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui), what [AbdBarho/stable-diffusion-webui-docker](https://github.com/AbdBarho/stable-diffusion-webui-docker) is to [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui).*

# Quick-Start
- Pull the repo: `git clone https://github.com/Atinoda/text-generation-webui-docker`
- Point your terminal to the downloaded folder (e.g., `cd text-generation-webui-docker`)
- *(Optional) Edit `docker-compose.yml` to your requirements*
- Start the server (the image will be pulled automatically for the first run): `docker compose up`
- Navigate to `127.0.0.1:7860` and enjoy your local instance of oobabooga's text-generation-webui!

# Usage
This repo provides a template `docker-compose.yml` and a structured `config` folder to store the application files. The project officially targets Linux as the deployment platform, however the images will also work on Docker Desktop for Windows. There is no plan to support Apple Silicon because that platform runs docker inside a VM, and Apple has chosen not to support virtualised hardware access. Intel Macs should be fine to run with the variant suitable for their GPU.

*Check the issues for hints and tips for your platform (and remember to search closed issues too!)*

## Pre-Requisites
- docker
- docker compose
- CUDA docker runtime *(optional, for Nvidia GPU-powered inferencing)*

*Ask your favourite LLM how to install and configure `docker`, `docker-compose`, and the Nvidia CUDA docker runtime for your platform!*

## Docker Compose
This is the recommended deployment method (it is the easiest and quickest way to manage folders and settings through updates and reinstalls). The recommended variant is `default` (it is the full version of the standard application with all default bundled extensions installed, set up for Nvidia GPU accelerated inference).

### Select variant
Each variant has the 'extras' included in `default` but has some changes made as described in the table. Tagged release versions are published on a regular basis - check [hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui) for available tags. Pulling an untagged variant will pull the latest stable release. Unstable, latest versions are available via nightly builds.

Choose the desired variant by setting the image `:tag` in `docker-compose.yml` using the pattern `{VARIANT}-{PLATFORM}`, or `{VARIANT}-{PLATFORM}-{VERSION}` to specify a specific release.

| Variant | Description | 
|---|---|
| `default-*` | Standard deployment with all default bundled extensions installed. Normal image intended for everyday usage. |
| `base-*` | Basic deployment with no extensions installed. Slimmer image intended for customisation or lightweight deployment.  |

| Platform | Description | 
|---|---|
| `*-nvidia` | CUDA 12.1 inference acceleration. |
| `*-cpu` | CPU-only inference. *Has become surprisingly fast since the early days!* |
| `*-rocm` | ROCM 5.6 inference acceleration. *Experimental and unstable.* |
| `*-arc` | Intel Arc XPU and oneAPI inference acceleration.  **Not compatible with Intel integrated GPU (iGPU).** *Experimental and unstable.* |

| Examples | Description |
|---|---|
| `default` | Standard deployment with all extensions, configured for Nvidia GPU accelerated inferencing. Same as `default-nvidia`. *This version is recommended for most users.*  |
| `default-cpu` | Standard deployment with all extensions, set up for CPU-only inference. *This version is useful if you don't have a supported GPU.*  |
| `{VARIANT}-{PLATFORM}-{VERSION}` | Build of each `{VARIANT}-{PLATFORM}` tagged with the release `{VERSION}` of the text-generation-webui (e.g., `default-nvidia-snapshot-2024-02-04`). *Visit [obabooga/text-generation-webui/releases](https://github.com/oobabooga/text-generation-webui/releases) for release notes. Go to [hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui) to see the available pre-built versions.*|
| `{VARIANT}-{PLATFORM}-nightly` | Automated nightly build of the variant. These images are built and pushed automatically - they are untested and may be unstable. *Suitable when more frequent updates are required and instability is not an issue.* |

### Deploy
Deploy the service:

`docker compose up`

### Remove
Remove the service:

`docker compose down -v`

## Configuration
These configuration instructions describe the relevant details for this docker wrapper. Refer to [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) documentation for usage of the application itself.

### Ports
Three commonly used ports are exposed:

|  Port  | Description | Configuration |
|  ----  | ----------- | ------------- |
| `7860` | Web UI port | Pre-configured and enabled in `docker-compose.yml` |
| `5000` | API port    | Enable by adding `--api --extensions api` to launch args then uncomment mapping in `docker-compose.yml` |
| `5005` | Streaming port | Enable by adding `--api --extensions api` to launch args then uncomment mapping in `docker-compose.yml` |

*Extensions may use additional ports - check the application documentation for more details.*

### Volumes
The provided example docker compose maps several volumes from the local `config` directory into the container: `loras, models, presets, prompts, training, extensions`. If these folders are empty, they will be initialised when the container is run.

Extensions will persist their state between container launches if you use a mapped folder - **but they will not automatically update when a new image is released, so this feature is disabled by default.** The whole extensions folder can be mapped (all extensions are persisted) or individual extensions can be mapped one at a time. Examples are given in the `docker-compose.yml`.

*If you are getting an error about missing files, try clearing these folders and letting the service re-populate them.*

### Extra launch arguments
Extra launch arguments can be defined in the environment variable `EXTRA_LAUNCH_ARGS` (e.g., `"--model MODEL_NAME"`, to load a model at launch). The provided default extra arguments are `--verbose` and `--listen` (which makes the webui available on your local  network) and these are set in the `docker-compose.yml`.

*Launch arguments should be defined as a space-separated list, just like writing them on the command line. These arguments are passed to the `server.py` module.*

### Runtime extension build
Extensions which should be built during startup can be defined in the environment variable `BUILD_EXTENSIONS_LIVE` (e.g., `"coqui_tts whisper_stt"`, will rebuild those extensions at launch). This feature may be useful if you are developing a third-party extension and need its dependencies to refresh at launch.

**Startup times will be much slower** if you use this feature, because it will rebuild the named extensions every time the container is started (i.e., don't use this feature unless you are certain that you need it.)

*Extension names for runtime build should be defined as a space-separated list.*

## Updates
These projects are moving quickly! To update to the most recent version on Docker hub, pull the latest image:

`docker compose pull`

Then recreate the container:

`docker compose up`

*When the container is launched, it will print out how many commits behind origin the current build is, so you can decide if you want to update it. Docker hub images will be periodically updated. The `default-nightly` image is built every day but it is not manually tested. If you need bleeding edge versions you must build locally.*

## Build (optional)
The provided `docker-compose.yml.build` shows how to build the image locally. You can use it as a reference to modify the original `docker-compose.yml`, or you can rename it and use it as-is. Choose the desired variant to build by setting the build `target` and then run:

`docker compose build`

To do a clean build and ensure the latest version:

`docker compose build --no-cache`

*If you choose a different variant later, you must **rebuild** the image.*

### Developers / Advanced Users
The Dockerfile can be easily modified to compile and run the application from a local source folder. This is useful if you want to do some development or run a custom version. See the Dockerfile itself for instructions on how to do this.

*Support is not provided for this deployment pathway. It is assumed that you are competent and willing to do your own debugging! Pro-tip: start by placing a `text-generation-webui` repo into the project folder.*

## Standalone Container
NOT recommended, instructions are included for completeness.

### Run
Run a network accessible container (and destroy it upon completion):

`docker run -it --rm -e EXTRA_LAUNCH_ARGS="--listen --verbose" --gpus all -p 7860:7860 atinoda/text-generation-webui:default-nvidia`

### Build and run (optional)
Build the image for the default target and tag it as `local` :

`docker build --target default-nvidia -t text-generation-webui:local .`

Run the local image with local network access (and destroy it upon completion):

`docker run -it --rm -e EXTRA_LAUNCH_ARGS="--listen --verbose" --gpus all -p 7860:7860 text-generation-webui:local`

# Known Issues
## AMD GPU ROCM 
The `rocm` variant is reported to be working, but it is blind-built and not regularly tested due to a lack of hardware. User reports and insights are welcomed.

*Thanks to [@Alkali-V2](https://github.com/Alkali-V2) for confirming successful deployment with RX 6800 on Unraid.*

## Intel Arc GPU
The `arc` variant is blind-built and untested due to a lack of hardware. User reports and insights are welcomed.

## Extensions
The following are known issues and they are planned to be investigated. Testing and insights are welcomed!
- `multimodal`: Crashes because model is not loaded at start
- `ngrok`: Requires an account, causes a crash
- `silero_tts`: Does not work due to pydantic dependency problem
- `superbooga`/`superboogav2`: Crashes on startup

## Kubernetes
Please see [EXTRA_LAUNCH_ARGS are not honored #25](https://github.com/Atinoda/text-generation-webui-docker/issues/25) for fixing deployments. *Thanks to @jrsperry for reporting, and @accountForIssues for sharing a workaround (TLDR: Escape space characters with `\ `, instead of writing as ` ` .)*

# Contributions
Contributions are welcomed - please feel free to submit a PR. More variants (e.g., AMD/ROC-M support) and Windows support can help lower the barrier to entry, make this technology accessible to as many people as possible, and push towards democratising the severe impacts that AI is having on our society.

*Also - it's fun to code and LLMs are cool.*

# DISCLAIMER
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
