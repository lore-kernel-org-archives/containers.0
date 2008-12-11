From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Network namespaces tool
Date: Thu, 11 Dec 2008 10:23:28 +0100
Message-ID: <4940DC10.6020609@free.fr>
References: <7c9d57ea0812110053o4a2753e0m3937ede52955ce4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7c9d57ea0812110053o4a2753e0m3937ede52955ce4c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <xbmodder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-pyega4qmqnRoyOMFzWx49A@public.gmane.org
List-Id: containers.vger.kernel.org

Sargun Dhillon wrote:
> I'm getting an error when I try to compile the netunshare tool.
> Do you have any ideas to the error:
>
> netunshare.c:50: error: conflicting types for 'unshare'
> /usr/include/bits/sched.h:78: error: previous declaration of 'unshare' was here
>   

There is the lxc tools at:

http://sourceforge.net/projects/lxc/

In these tools there is the lxc-unshare allowing you to do the same.
    lxc-unshare -n /bin/bash

If you find some problems with it, feel free to ask :)
I will release a new lxc-0.5.1, version fixing a few bugs very soon.
> Additionally, are there any plans to merge in sysfs support into the kernel?
>   
The sysfs patchset has been rejected and the sysfs itself should be 
reworked before submitting the sysfs per namespace. This is a long work, 
Eric can probably say more on that.
In the meantime, a patch to make netns and sysfs to co-exist has been 
pushed upstream, so we can create a network namespace without sysfs 
virtualization. This modification will be available for 2.6.29. Until 
this version is released, you can use the netdev development tree 
available at:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

Thanks.
  -- Daniel
