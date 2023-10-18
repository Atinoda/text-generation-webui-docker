# Introduction
This project dockerises the deployment of [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) and its variants. It provides a default configuration (corresponding to a vanilla deployment of the application) as well as pre-configured support for other set-ups (e.g., `llama-cpu` for CPU-only inferencing). Pre-built images are available on Docker Hub: [https://hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui) for convenience.

*The goal of this project is to be to [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui), what [AbdBarho/stable-diffusion-webui-docker](https://github.com/AbdBarho/stable-diffusion-webui-docker) is to [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui).*

# Quick-Start
- Pull the repo: `git clone https://github.com/Atinoda/text-generation-webui-docker`
- Point your terminal to the downloaded folder (e.g., `cd text-generation-webui-docker`)
- *(Optional) Edit `docker-compose.yml` to your requirements*
- Start the server (the image will be pulled automatically for the first run): `docker compose up`
- Navigate to `127.0.0.1:7860` and enjoy your local instance of oobabooga's text-generation-webui!

# Usage
This repo provides a template `docker-compose.yml` and a structured `config` folder to store the application files. The project officially targets Linux as the deployment platform, however the images are reported to work on Docker Desktop for Windows, and this should continue to be the case. There may be some additional steps required for networking and file management when using WSL2. Some Mac users have been able to run the images, although the Dockerfile may require modifications for Apple Silicon compatibility.

*Check the issues for hints and tips for your platform (and remember to search closed issues too!)*

## Pre-Requisites
- docker
- docker compose
- CUDA docker runtime *(optional, for GPU-powered inferencing)*

*Ask your favourite LLM how to install and configure `docker`, `docker-compose`, and the Nvidia CUDA docker runtime for your platform!*

## Docker Compose
This is the recommended deployment method (it is the easiest and quickest way to manage folders and settings through updates and reinstalls). The recommend variant is `default` (it is an enhanced version of the vanilla application).

### Select variant
Each variant has the 'extras' included in `default` but has some changes made as described in the table. Tagged release versions are published on a regular basis - check [hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui) for available tags. Pseudo-versions may be selected periodically from the main branch and uploaded with a date tag to establish more frequent stable milestones, *but this should be rare because the upstream project has implemented weekly rolling releaese snapshots.* Pulling an untagged variant will pull either the latest release version or latest pseudo-version, whichever is most recent. Bleeding-edge is available via nightly builds of each variant. Choose the desired variant by setting the image `:tag` in `docker-compose.yml` to one of the following options:

| Variant | Description | 
|---|---|
| `default` | Implementation of the vanilla deployment from source. Plus pre-installed `ExLlamaV2` library from `turboderp/exllamav2` with `flash-attn` enabled, and CUDA GPU offloading enabled for `llama-cpp`. *This version is recommended for most users.*  |
| `triton` | Updated `GPTQ-for-llama` using the latest `triton` branch from `qwopqwop200/GPTQ-for-LLaMa`. Suitable for Linux only. *This version is accurate but a little slow.* ***DEPRECATION WARNING:** This version is outdated, but will remain for now.* |
| `cuda` | Updated `GPTQ-for-llama` using the latest `cuda` branch from `qwopqwop200/GPTQ-for-LLaMa`. *This version is very slow!* ***DEPRECATION WARNING:** This version is outdated, but will remain for now.* |
| `llama-cpu` | GPU supported is REMOVED from `llama-cpp`. Suitable for systems without a CUDA-capable GPU. *This is only for when GPU acceleration is not available and is a slower way to run models!* |
| `{VARIANT}-{VERSION}` | Build of each {VARIANT} tagged with the release {VERSION} of the text-generation-webui (e.g., `default-v1.5`). *Visit [obabooga/text-generation-webui/releases](https://github.com/oobabooga/text-generation-webui/releases) for release notes.*  Dated milestone pseudo-version tags are also available (e.g., `default-2023.09.02`). *Visit [hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui) to see the available milestones.*|
| `{VARIANT}-nightly` | Automated nightly build of the {VARIANT}. These images are built and pushed automatically - they are untested and may be unstable. *Suitable when more frequent updates are required and instability is not an issue.* |

*See: [oobabooga/text-generation-webui/blob/main/docs/GPTQ-models-(4-bit-mode).md](https://github.com/oobabooga/text-generation-webui/blob/main/docs/GPTQ-models-(4-bit-mode).md), [obabooga/text-generation-webui/blob/main/docs/llama.cpp-models.md](https://github.com/oobabooga/text-generation-webui/blob/main/docs/llama.cpp-models.md), and [oobabooga/text-generation-webui/blob/main/docs/ExLlama.md](https://github.com/oobabooga/text-generation-webui/blob/main/docs/ExLlama.md) for more information on variants.*

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

**Kubernetes users:** Please see [EXTRA_LAUNCH_ARGS are not honored #25](https://github.com/Atinoda/text-generation-webui-docker/issues/25) for fixing deployments. *Thanks to @jrsperry for reporting, and @accountForIssues for sharing a workaround (TLDR: Escape space characters `\ ` instead of ` `.)*

### Runtime extension build
Extensions which should be built during startup can be defined in the environment variable `BUILD_EXTENSIONS_LIVE` (e.g., `"silero_tts whisper_stt"`, will rebuild those extensions at launch). This feature may be useful if you are developing a third-party extension and need its dependencies to refresh at launch.

**Startup times will be much slower** if you use this feature, because it will rebuild the named extensions every time the container is started (i.e., don't use this feature unless you are certain that you need it.)

*Extension names for runtime build should be defined as a space-separated list.*

### Updates
These projects are moving quickly! To update to the most recent version on Docker hub, pull the latest image:

`docker compose pull`

Then recreate the container:

`docker compose up`

*When the container is launched, it will print out how many commits behind origin the current build is, so you can decide if you want to update it. Docker hub images will be periodically updated. The `default-nightly` image is built every day but it is not manually tested. If you need bleeding edge versions you must build locally.*

### Build (optional)
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

`docker run -it --rm -e EXTRA_LAUNCH_ARGS="--listen --verbose" --gpus all -p 7860:7860 atinoda/text-generation-webui:default`

### Build and run (optional)
Build the image for the default target and tag it as `local` :

`docker build --target default -t text-generation-webui:local .`

Run the local image with local network access (and destroy it upon completion):

`docker run -it --rm -e EXTRA_LAUNCH_ARGS="--listen --verbose" --gpus all -p 7860:7860 text-generation-webui:local`

# Contributions
Contributions are welcomed - please feel free to submit a PR. More variants (e.g., AMD/ROC-M support) and Windows support can help lower the barrier to entry, make this technology accessible to as many people as possible, and push towards democratising the severe impacts that AI is having on our society.

*Also - it's fun to code and LLMs are cool.*

# DISCLAIMER
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
