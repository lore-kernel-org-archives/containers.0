From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC patch 0/2] posix mqueue namespace (v11)
Date: Tue, 16 Dec 2008 09:11:09 +0100
Message-ID: <4947629D.9040807@fr.ibm.com>
References: <20081215233747.GA27553@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081215233747.GA27553-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> (Ok I don't know what the actual version number is - it's
> high but 11 is probably safe)
> 
> Cedric and Nadia took several approaches to making posix
> message queues per-namespace.  I ended up mamking some
> deep changes so am not retaining their Signed-off-by:s
> on this version, but this is definately very much based
> on work by both of them.

you can keep mine. i have had a similar version on 2.6.26. 

http://legoater.free.fr/patches/2.6.26/2.6.26/

and it's easier to track where the patches go.

> Patch 2 hopefully explains my approach.  Briefly,
> 
> 	1. sysv and posix ipc are both under CLONE_NEWIPC
> 	2. the mqueue sb is per-ipc-namespace
> 
> So to create a new ipc namespace, you would
> 
> 	unshare(CLONE_NEWIPC|CLONE_NEWNS);

does CLONE_NEWIPC requires CLONE_NEWNS ? 

> 	umount /dev/mqueue
> 	mount -t mqueue mqueue /dev/mqueue

the semantic looks good, much better than a 'newinstance' mount 
option.

if CLONE_NEWNS is not required, what happens to the user mount (and
the mq_ns below it) when the task dies. that's the big issue. if 
CLONE_NEWNS is required were safe, but I think Pavel made
some objection to that. 

> It's perfectly valid to do vfs operations on files
> in another ipc_namespace's /dev/mqueue, but any use
> of mq_open(3) and friends will act in your own ipc_ns.

ok.

C.
