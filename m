From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Thu, 04 Sep 2008 04:14:35 -0400
Message-ID: <48BF98EB.5080602__23633.4268040538$1220516207$gmane$org@cs.columbia.edu>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-1-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Andrey Mirkin wrote:
> This patchset introduces kernel based checkpointing/restart as it is
> implemented in OpenVZ project. This patchset has limited functionality and
> are able to checkpoint/restart only single process. Recently Oren Laaden
> sent another kernel based implementation of checkpoint/restart. The main
> differences between this patchset and Oren's patchset are:

Thanks Andrey. I'll take a close look at it by the weekend. Just a couple
of comments after a very brief look at the code:

> 
> * In this patchset checkpointing initiated not from the process
> (right now we do not have a container, only namespaces), Oren's patchset
> performs checkpointing from the process context.

Actually, my patch is written to checkpoint from outside the context of the
target task;  for simplicity only, it is applied to the current process.

> 
> * Restart in this patchset is initiated from process, which restarts a new
> process (in new namespaces) with saved state. Oren's patchset uses the same
> process from which restart was initiated and restore saved state over it.

Here, too, handling of namespaces was left out in order to provide a simple
proof of concept. In fact, spawning a new process and entering a new namespace
can be easily done in user-space.

Oren.

> 
> * Checkpoint/restart functionality in this patchset is implemented as a kernel
> module
> 
> 
> As checkpointing is initiated not from the process which state should be saved
> we should freeze a process before saving its state. Right now Container Freezer
> from Matt Helsley can be used for this.
> 
> This patchset introduce only a concept how kernel based checkpointing/restart
> can be implemented and are able to checkpoint/restart only a single process
> with simple VMAs. 
> 
> I've tried to split my patchset in small patches to make review more easier.
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
