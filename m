From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 22:35:19 +0200
Message-ID: <4BDB3F07.2030900@free.fr>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org, David Miller <davem@davemloft.net>
List-Id: containers.vger.kernel.org

Dan Smith wrote:
> This patch adds support for checkpointing and restoring route information.
> It keeps enough information to restore basic routes at the level of detail
> of /proc/net/route.  It uses RTNETLINK to extract the information during
> checkpoint and also to insert it back during restore.  This gives us a
> nice layer of isolation between us and the various "fib" implementations.
>
> Changes in v2:
>
> This version of the patch actually moves the current task into the
> desired network namespace temporarily, for the purposes of examining and
> restoring the route information.  This is a instead of creating a cross-
> namespace socket to do the job, as was done in v1.
>
> This is just an RFC to see if this is an acceptable method.  For a final
> version, adding a helper to nsproxy.c would allow us to create a new
> nsproxy with the desired netns instead of creating one with
> copy_namespaces() just to kill it off and use the target one.
>
> I still think the previous method is cleaner, but this way may violate
> fewer namespace boundaries (I'm still undecided :)
>
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: jamal <hadi@cyberus.ca>
> ---
Hi Dan,

Eric did a patchset (as Jamal mentioned it) where you can have a process 
to enter a specific namespace from userspace.

http://git.kernel.org/?p=linux/kernel/git/ebiederm/linux-2.6.33-nsfd-v5.git;a=commit;h=9c2f86a44d9ca93e78fd8e81a4e2a8c2a4cdb054

Is it possible to enter the namespace and dump / restore the routes with 
NETLINK_ROUTE from userspace ? Or is it something not possible ?

Thanks
  -- Daniel


