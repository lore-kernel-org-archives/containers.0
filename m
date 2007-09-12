From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [NETNS][patch 1/1] fix allnoconfig compilation error
Date: Wed, 12 Sep 2007 15:27:42 -0600
Message-ID: <m14phz8tgx.fsf@ebiederm.dsl.xmission.com>
References: <20070912204826.676639734@mai.toulouse-stg.fr.ibm.com>
	<20070912205028.838067239@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070912205028.838067239-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
	(dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org's message of "Wed, 12 Sep 2007 22:48:27 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org writes:

> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>
> When CONFIG_NET=no, init_net is unresolved because net_namespace.c
> is not compiled and the include pull init_net definition.
>
> This problem was very similar with the ipc namespace where the kernel
> can be compiled with SYSV ipc out.
>
> This patch fix that defining a macro which simply remove init_net
> initialization from nsproxy namespace aggregator.
>
> Compiled and booted on qemu-i386 with CONFIG_NET=no and CONFIG_NET=yes.
>
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

This looks good and is quite simple.

My apologies for over looking the case where the networking stack is not
compiled in. 

Eric
