From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: C/R minisummit notes (namespace naming)
Date: Thu, 24 Jul 2008 02:55:37 -0700
Message-ID: <m1zlo7a9nq.fsf@frodo.ebiederm.org>
References: <4887163F.5090801@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4887163F.5090801-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Wed,
	23 Jul 2008 13:30:07 +0200")
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


Currently we have three possibilities on how to name pid namespaces.
- indirect via processes
- pids
- names in the filesystem

We discussed this a bit in the hallway track and pids are look like the way
to go. Pavel has a patch in progress to help sort this out.

The practical problem we have today is that we need a way to wait for the network
namespace in particular and namespaces in general to exit.

At a first glance waitid(P_NS, <pid>,....) looks like a useful way to achieve
this.  After looking at wait a bit more it really is fundamentally just an exit
status reaper of zombies, that has the option of blocking when the zombies
do not yet exist.  In any kind of event loop you would wait for SIGCHLD either
as a signal or with signalfd.

So how shall we wait for a namespace to exit?  My brainstorm tonight suggests
inotify_add_watch(ifd, "/proc/ns/<pid>", IN_DELETE);

Eric
