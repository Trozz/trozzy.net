+++
date = "2016-07-04T22:51:30+01:00"
draft = false
title = "Automating Hugo Deployments"
tags = [ "git", "devops", "automation", "codeship" ]
categories = [
  "automation"
]
+++

As you may notice I have done a few updates today, I have always had the strong believe that if a task is repeated more than once that it **should** be automated, now deploying something like [Hugo](https://gohugo.io) can be very easy as if you simply commit the `public` folder then this folder can be deployed, personally I do not commit this folder and infact exclude it via my `.gitignore`, this is a habit due to the fact that I believe in reproducible builds, yes even for something as simple as Hugo.

Enter [CodeShip](https://codeship.com) as I didn't want to setup Jenkin's simply for deploying this site I looked for a deployment company that would offer a `free` account, using CodeShip I am now monitoring my website repository and building the public files as required, it then logs in to my web servers and deploys the code

## CodeShip setup
As I had said there is not a great deal to the CodeShip setup, I selected a `go` project as this would install the requirements for building Hugo from source, then I simply run the hugo command specifying the theme that I require.

```bash
go get -v github.com/spf13/hugo
hugo --theme blackburn
```

Under the deployment I simply setup a `rsync` to clone the data to the web servers, I added the `--delete` argument as anything that has not been generated should no longer exist, I also added the `-r` tag rather than `-a` to ensure that files are correctly owned by the user that is used for the rsync

```bash
rsync -rvz --delete . {user}@{server}:
```


And there we have it, that is an extremely basic deployment of a website using Hugo so that when I am finished writing a post I no longer need to run the rsync myself...
