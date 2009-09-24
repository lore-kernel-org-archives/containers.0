From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
Date: Thu, 24 Sep 2009 15:41:39 -0700
Message-ID: <20090924154139.2a7dd5ec.akpm__43083.1724698239$1253832168$gmane$org@linux-foundation.org>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 23 Sep 2009 19:50:40 -0400
Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> wrote:

> Q: How useful is this code as it stands in real-world usage?
> A: The application can be single- or multi-processes and threads. It
>    handles open files (regular files/directories on most file systems,
>    pipes, fifos, af_unix sockets, /dev/{null,zero,random,urandom} and
>    pseudo-terminals. It supports shared memory. sysv IPC (except undo
>    of sempahores). It's suitable for many types of batch jobs as well
>    as some interactive jobs. (Note: it is assumed that the fs view is
>    available at restart).

That's encouraging.

> Q: What can it checkpoint and restart ?
> A: A (single threaded) process can checkpoint itself, aka "self"
>    checkpoint, if it calls the new system calls. Otherise, for an
>    "external" checkpoint, the caller must first freeze the target
>    processes. One can either checkpoint an entire container (and
>    we make best effort to ensure that the result is self-contained),
>    or merely a subtree of a process hierarchy.

What is "best effort"?  Will the operation appear to have succeeded,
only it didn't?

IOW, how reliable and robust is code at detecting that it was unable to
successfully generate a restartable image?

> Q: What about namespaces ?
> A: Currrently, UTS and IPC namespaces are restored. They demonstrate
>    how namespaces are handled. More to come.

Will this new code muck up the kernel?

> Q: What additional work needs to be done to it?
> A: Fill in the gory details following the examples so far. Current WIP
>    includes inet sockets, event-poll, and early work on inotify, mount
>    namespace and mount-points, pseudo file systems

Will this new code muck up the kernel, or will it be clean?

> and x86_64 support.

eh?  You mean the code doesn't work on x86_64 at present?


What is the story on migration?  Moving the process(es) to a different
machine?
