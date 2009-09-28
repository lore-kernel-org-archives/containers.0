From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [patch 1/4][resend] fuse-procfs: proxy proc files
Date: Mon, 28 Sep 2009 17:47:51 +0200
Message-ID: <4AC0DAA7.9090907@free.fr>
References: <20090904162556.407556958@mai-009101017029.toulouse-stg.fr.ibm.com>	
	<20090904165149.491603361@mai-009101017029.toulouse-stg.fr.ibm.com>	
	<ac1c4bf20909141338p3e13c1d6sc71899b7859bd963@mail.gmail.com>	
	<4AAEB1FA.3070102@free.fr>
	<ac1c4bf20909280233r5cd94343m30ac00c6ef9e1d10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20909280233r5cd94343m30ac00c6ef9e1d10-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Krzysztof Taraszka wrote:
> Thank you Daniel.
> I have a little problem with fuse and containers. Do I have to add the fuse
> device to the container?
> When I tried to mount procfs I received:
>
> container2:/# ./procfs -odirect_io /proc/meminfo
> fuse: device not found, try 'modprobe fuse' first
>
> The fuse module was loaded on host. What I did wrong? I am asking because I
> am working around user space scripts for managing lxc (written in bash,
> init.d script, few lxc-create-* scripts based on distro, etc) and I would
> like to add this development future to this scripts.
> Right now I have few nice and good looking userspace scripts.
> Would be great If I may do the deb and rpm package with lxc user scripts and
> lxc-tools or add my scripts to lxc-tools tree.
>   
Let's see :)

> More about that in this week in the different thread. Hope you will give me
> the direction guys.
>   

I think the command line is not right. Fuse uses at the /proc directory 
when initializating, so that have to be done in two steps:

Can you try:

lxc-execute -n foo /bin/bash

(from the shell in the container):
procfs -o direct_io /tmp/<tmpdir>
mount --bind /tmp/<tmpdir> /proc
echo 268435456 > /cgroup/foo/memory.memsw.limit_in_bytes
echo 268435456 > /cgroup/foo/memory.limit_in_bytes

* before exiting the container:
umount /proc
fusermount -u /tmp/<tmpfile>

If you do 'ls /proc', you should see everything expect the /proc/sys 
directory.
If you do 'cat /proc/meminfo', you should see:
MemTotal: 262144 kB
MemFree: 250684 kB
SwapTotal: 262144 kB
SwapFree: 0 kB
