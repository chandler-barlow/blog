---
author: Chandler Barlow
tags:
  - docker
title: Intro to Docker Commands
date: 2019-08-13
draft: false
---

Docker is a wildly successful solution to a common problem in the computing world.

> But it works on my machine…

By packaging applications into Docker containers companies can assure that their solutions are going to work on any machine. Using containers lowers the cost and difficulty of deploying software. Containers are portable, easy to use (for the most part), and stable. It’s no surprise that Docker has been, and most likely will continue to be, gaining considerable support.

But if you would like to get started with Docker there are a few console commands you must know.

## Containers

Containers are what make Docker so useful. You will need to know how to manage containers at each step of their lifecycle.

Before you can do anything with a container, it has to be built from an image.

`docker build` builds an image from a Dockerfile. This command takes a Dockerfile and turns produces an image you can use to start containers. To see more information about images look a little further down, or check out the [official documentation](https://docs.docker.com/engine/reference/commandline/image/).

Once a container is running you’ll be able to stop it, start it, or even remove it. Though, if you want to interact with a container you’ll need to know some information about it first.

To see all your running containers use

```bash
$ docker ps
```

From here you can see all the relevant information about your containers, like name or Id. Container Id is important, it’s how you tell Docker what container you’re trying to interact with.

For all of these next commands you need to include the container’s Id, or at-least enough of the Id that Docker is able to determine which exact container is being referenced.

```bash
$ docker container <command>
```

- run runs a container. Add -d if you want to run the container in the background (detached mode). When running a container you must specify the ports and image to use. For example

```bash
$ docker run -p 3306:3306 mysql -d
```

- `stop` stops a container. This is like putting the container to sleep. The container data isn’t removed and it can be started again easily.
- `start` starts a stopped container that has not been removed.
- `rm` removes a container. If a container is removed its data is also removed. This data will not persist unless you set up a volume.

But wait, what if you need to remove a running container, or all containers at once?

```bash
$ docker rm <id of container> -f
```

The `f` flag forces the container to be removed, even if it’s currently running.

```bash
$ docker rm $(docker ps -aq) -f
```

This removes every container even if it’s running or stopped. docker rm should look familiar because it’s the command for removing a container, the only difference here is the `$(docker ps -aq)` . This small difference makes a large change though.

`$(docker ps -aq)` returns the Id of every container.

By having this function as the argument to `docker rm` you’re telling docker to remove everything.

## Docker Compose

Containers are great, but it can be annoying to write multiple Dockerfiles then run multiple commands to get everything running. Luckily, docker-compose files make it possible to start and stop multiple containers in tandem.

```bash
$ docker-compose <command>
```

- `up` starts all containers. This is similar to run.
- `down` stops all containers. This command is similar to stop.

Again you can add the d flag to run everything in the background (detached mode) if you would like.

The way you remove or view containers remains the same.

## Images

Images are the bricks necessary to build containers. Images tell Docker what kind of environment to spin up when launching containers. Often time when you go to build a Dockerfile you won’t have the required images locally. Have no fear though, not having the image locally usually won’t cause any problems. Docker automatically pulls the necessary images from the DockerHub, if it can find them there. The DockerHub is a Docker GitHub, the main difference being that the repositories only contain images.

Every image you use doesn’t have to come from the DockerHub though. You can build your own. In fact when you build a Dockerfile you’re actually creating an image on your machine.

To build an image from a Dockerfile use `docker build` or `docker image build` . I mentioned this earlier in the containers section, but knowing how to build images is really import in the Docker world. Images are a core part of Docker, if you want to know more check out the official documentation.

Once images are built, or pulled from the DockerHub, they’re saved locally to your machine.

To see every image stored locally run

```bash
$ docker images
```

If you see a long list of images with the name `<none>` after running that last command, don’t worry. These mysterious images are dangling images. Dangling images aren’t anything terrible, but they are garbage and should be removed. Removing them won’t harm any of your containers or images, there’s even a special command just for this purpose.

```bash
$ docker rmi $(docker images -f "dangling=true" -q)
```

This will free up some space on your machine. Removing dangling images will also simplify keeping track of real images on your machine.

Hopefully this list was helpful! Knowing all of these commands will definitely help anyone working with Docker.
