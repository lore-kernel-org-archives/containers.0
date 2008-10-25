From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Sat, 25 Oct 2008 15:08:36 +0200
Message-ID: <49031A54.70806@fr.ibm.com>
References: <48EF35F1.2060308@fr.ibm.com>
	<8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0810250406s4f1c9337ha2bccc10faed1948-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ian jonhson wrote:
> Dear Daniel,
> 
> I have tested the container tools in my VM.
> It runs very well. But I can not see any highlight
> show via container. 

The container will be more or less isolated depending of what you 
specify in the configuration file.

Without any configuration file, you will have pid, ipc and mount points 
isolated. If you specify the utsname, it will be isolated and if you 
specify the network you will have a new network stack allowing to run 
for example a new sshd server.

In the other side, the cgroup are tied with the container, so you can 
freeze/unfreeze all processes belonging to the container, change the 
priority or assign an amount of physical memory to be used by the container.

> I believe that two group of
> user's processes (with same uid) can be isolated
> via container when both of them access files or
> are enforced with different quota. But I don't know
> how to get the functionalities run.

Allowing to assign quota per container is a good idea, but I don't think 
it is supported by the kernel right now. Perhaps there is a trick to do 
that but I don't know it :)

The rootfs option allows you to specify the root file system to be used 
by the container, so if you specify it, your container will be chrooted 
inside. This feature is at a very early stage and will be improved in 
the future, allowing to example to specify a iso image of a file system 
tree and make use of it.

There are two contributions which are good examples on how to setup a 
container, I added them to:

http://sourceforge.net/projects/lxc/

The first one is a chroot of a sshd server and the second one is a 
minimalist debian showing a full distro booting.

> Any help?
> 
> Thanks in advance.
> 
> On Wed, Oct 15, 2008 at 9:11 PM, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
>> Ian jonhson wrote:
>>>> The problem is related to the kernel version you have and a missing
>>>> functionality.
>>>>
>>>> You should use the kernel coming from:
>>>>
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
>>>>
>>> It needs not to set "Container support"  if I run with above kernel,
>>> right?
>>> I have downloaded the source codes.
>> The container support will enable at the compile time the different features
>> in the kernel. I added this kernel option because I was tired to activate
>> the different features one by one as described in the README file. If you
>> don't specify this option, the container code will be there in the kernel
>> but the not active. So you have to set it.
>>
> 
> OK, I have activated the "container support" step by step according to
> README, but I met a mismatch setting:

It looks like there is a piece missing at the end of the email.
