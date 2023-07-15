# Introduction
This project dockerises the deployment of [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) and its variants. It provides a default configuration (corresponding to a vanilla deployment of the application) as well as pre-configured support for other set-ups (e.g., latest `llama-cpp-python` with GPU offloading, the more recent `triton` and `cuda` branches of GPTQ). The images are available on Docker Hub: [https://hub.docker.com/r/atinoda/text-generation-webui](https://hub.docker.com/r/atinoda/text-generation-webui)

*This goal of this project is to be to [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui), what [AbdBarho/stable-diffusion-webui-docker](https://github.com/AbdBarho/stable-diffusion-webui-docker) is to [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui).*

# Usage
*This project currently supports Linux as the deployment platform. It will also probably work using WSL2.*

## Pre-Requisites
- docker
- docker compose
- CUDA docker runtime

## Docker Compose
This is the recommended deployment method (it is the easiest and quickest way to manage folders and settings through updates and reinstalls). The recommend variant is `default` (it is an enhanced version of the vanilla application).

### Select variant
Each variant has the 'extras' incuded in `default` but has some changes made as described in the table. Choose the desired variant by setting the image `:tag` in `docker-compose.yml` to one of the following options:

| Variant | Description | 
|---|---|
| `default` | Implementation of the vanilla deployment from source. Plus pre-installed `ExLlAMA` library from `turboderp/exllama`, and CUDA GPU offloading enabled for `llama-cpp`. *This version is recommended for most users.*  |
| `default-nightly` | Automated nightly build of the `default` variant. This image is built and pushed automatically - it is untested and may be unstable. *Suitable when more frequent updates are required and instability is not an issue.*  |
| `triton` | Updated `GPTQ-for-llama` using the latest `triton` branch from `qwopqwop200/GPTQ-for-LLaMa`. Suitable for Linux only. *This version is accurate but a little slow.* |
| `cuda` | Updated `GPTQ-for-llama` using the latest `cuda` branch from `qwopqwop200/GPTQ-for-LLaMa`. *This version is very slow!* |
| `monkey-patch` | Use LoRAs in 4-Bit `GPTQ-for-llama` mode. ***DEPRECATION WARNING:** This version is outdated, but will remain for now.* |
| `llama-cublas` | CUDA GPU offloading enabled for `llama-cpp`. Use by setting option `n-gpu-layers` > 0. ***DEPRECATION WARNING:** This capability has been rolled into the default. The variant will be removed if the upstream dependency does not conflict with `default`.* |

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
