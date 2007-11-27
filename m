From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: consolidate sem_exit_ns(),
 msg_exit_ns and shm_exit_ns()
Date: Mon, 26 Nov 2007 22:46:36 -0800
Message-ID: <20071126224636.ca1ef92e.akpm@linux-foundation.org>
References: <20071123175250.0f584913.pierre.peiffer@bull.net>
	<20071126224438.df547263.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071126224438.df547263.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 26 Nov 2007 22:44:38 -0800 Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Fri, 23 Nov 2007 17:52:50 +0100 Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org> wrote:
> 
> > sem_exit_ns(), msg_exit_ns() and shm_exit_ns() are all called when an ipc_namespace is
> > released to free all ipcs of each type.
> > But in fact, they do the same thing: they loop around all ipcs to free them
> > individually by calling a specific routine.
> > 
> > This patch proposes to consolidate this by introducing a common function, free_ipcs(),
> > that do the job. The specific routine to call on each individual ipcs is passed as
> > parameter. For this, these ipc-specific 'free' routines are reworked to take a
> > generic 'struct ipc_perm' as parameter.
> 
> This conflicts in more-than-trivial ways with Pavel's
> move-the-ipc-namespace-under-ipc_ns-option.patch, which was in
> 2.6.24-rc3-mm1.
> 

err, no, it wasn't that patch.  For some reason your change assumes that
msg_exit_ns() (for example) doesn't have these lines:

        kfree(ns->ids[IPC_MSG_IDS]);
        ns->ids[IPC_MSG_IDS] = NULL;

in it.
