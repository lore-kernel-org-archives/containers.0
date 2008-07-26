From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: C/R minisummit notes (namespace naming)
Date: Sat, 26 Jul 2008 00:32:53 -0700
Message-ID: <m1wsj9p0be.fsf@frodo.ebiederm.org>
References: <4887163F.5090801@fr.ibm.com> <m1zlo7a9nq.fsf@frodo.ebiederm.org>
	<20080725191356.GE28136@us.ibm.com> <488A28E4.6080902@fr.ibm.com>
	<20080725193458.GA12356@us.ibm.com> <488A32FC.7020803@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <488A32FC.7020803-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Fri,
	25 Jul 2008 22:09:32 +0200")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

>>> Eric will post a patch to automatically destroy the virtual devices when the
>>> netns is destroyed, so there is no way to know if a network  namespace is
>>> dead or not as the uevent socket will not deliver an event  outside of the
>>> container.
>>
>> My question remains: who cares?
>
> The container implementation in userspace. Let's imagine it sets some routes
> outside of the container to route the traffic to the container. It should remove
> these routes when the container dies. And the container should be considered as
> dead when the network has died and not when the last process of the container
> exits.

Namespaces can definitely live on long past the time when there are any tasks
that point to them from nsproxy, and knowing when that happens would be nice.
So settling on pids for names would be nice as that would allows us to restructure
/proc so that we could see those kinds of things.

That said I am less certain of the need to actually wait for a network namespace
to exit, once we start killing virtual network devices.

It was mentioned that ip over ip tunnels don't currently have a dellink method so we need
will still need a wait to handle that case.

Similarly in general we need to wait until the network namespace exits to ensure
we flush all of the outgoing packets at container shutdown.

So I propose we remove merge the code to wait on delete virtual devices and then
recheck to see what uses we actually have left.

Eric
