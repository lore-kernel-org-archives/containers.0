From: "Ian jonhson" <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container userspace tools
Date: Sat, 25 Oct 2008 22:39:06 +0800
Message-ID: <8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
References: <48EF35F1.2060308@fr.ibm.com>
	<8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49031A54.70806-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

> The container will be more or less isolated depending of what you specify in
> the configuration file.
>
yes

> Without any configuration file, you will have pid, ipc and mount points
> isolated. If you specify the utsname, it will be isolated and if you specify
> the network you will have a new network stack allowing to run for example a
> new sshd server.
>

hmm.... then, how to configure the container to get the isolation of
pid, ipc and
mount points? I have looked through the whole configuration example in README
and fond the following settings(which are not tried in my test because
I don't understand
them very well)

 * lxc.mount: is it to mount a file (or volume) so that all the
processes in this container can
    access the content in file?
 * lxc.utsname: I don't know what exact functionlity of this setting is.
 * lxc.network.xxx: are there other options expect
"link","hwaddr","ipv4" and "ipv6"?
 * lxc.rootfs:for application writing data in it?

I am now looking into the codes and find some information about what the
container can do maximally. It seems all the configuration settings are
binding with a container and all the schedules are based on container unit.
Configuration settings only can be setup before container creation and
can not be changed in container lifecycle, right?


> In the other side, the cgroup are tied with the container, so you can
> freeze/unfreeze all processes belonging to the container, change the
> priority or assign an amount of physical memory to be used by the container.
>

In my brain, the cgroup is mainly used in multiple CPUs. In traditional single
CPU machine, can the container separate or determine how much CPU cycle
are used by its processes now? Also, administrator has to configure cgroup
before it takes action. I have no idea whether both of cgroup and container are
totally integrate with each other, or both of them have to be handle
in some cases.


> Allowing to assign quota per container is a good idea, but I don't think it
> is supported by the kernel right now. Perhaps there is a trick to do that
> but I don't know it :)
>
I would like to do this part of job. Also, I need to control several groups of
processes (belonged to same user) in the same time, isolating them,
enforced them with given resource quota, and freeze/unfreeze some of
them.

BTW, as for checkpointing of container, is it easy to checkpoint/restart
given group of processes in above example?

> The rootfs option allows you to specify the root file system to be used by
> the container, so if you specify it, your container will be chrooted inside.
> This feature is at a very early stage and will be improved in the future,
> allowing to example to specify a iso image of a file system tree and make
> use of it.
>

Good. what kinds of rootfs are supported now?  I fond there are a debian file
in sourceforge, is it a rootfs image?


> There are two contributions which are good examples on how to setup a
> container, I added them to:
>
> http://sourceforge.net/projects/lxc/
>
> The first one is a chroot of a sshd server and the second one is a
> minimalist debian showing a full distro booting.
>

In sourceforge, there are

*  	sshd.tar.gz
*  	debian.tar.gz
*       utsname (actually, utstest.c)

I wonder what is the utstest.c?


Thanks again,

Ian
