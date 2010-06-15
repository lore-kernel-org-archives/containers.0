From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 9/9][cr][v2]: Restore file-locks
Date: Tue, 15 Jun 2010 00:22:24 -0400
Message-ID: <4C170000.8040600__15225.4939931028$1276575893$gmane$org@cs.columbia.edu>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-10-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100526074811.GA19011@fogou.chygwyn.com>
	<20100526235713.GA12768@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100526235713.GA12768-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



On 05/26/2010 07:57 PM, Sukadev Bhattiprolu wrote:
> steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org [steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org] wrote:
> | Hi,
> | 
> | On Tue, May 18, 2010 at 08:07:32PM -0700, Sukadev Bhattiprolu wrote:
> | > Restore POSIX file-locks of an application from its checkpoint image.
> | > 
> | > Read the saved file-locks from the checkpoint image and for each POSIX
> | > lock, call flock_set() to set the lock on the file.
> | > 
> | > As pointed out by Matt Helsley, no special handling is necessary for a
> | > process P2 in the checkpointed container that is blocked on a lock, L1
> | > held by another process P1.  Since processes in the restarted container
> | > begin execution only after all processes have restored. If the blocked
> | > process P2 is restored first, first, it will prepare to return an
> | > -ERESTARTSYS from the fcntl() system call, but wait for P1 to be
> | > restored. When P1 is restored, it will re-acquire the lock L1 before P1
> | > and P2 begin actual execution. This ensures that even if P2 is scheduled
> | > to run before P1, P2 will go back to waiting for the lock L1.
> | >
> | Does that imply certain conditions wrt checkpointed processes and
> | NFS exports? I'm not sure I exactly undertstand the use case which
> | this is intended to address.
> 
> Well, yes this assumes some pre-requisites are met.
> 
> First lets look at a single system.  We expect that the application
> process tree is run inside a container. This means that the file
> system(s) (and other resources like pipes, IPC) that the application
> is working with are not modified by a process outside the container.

To be precise, we require that (a) resources won't change during
the checkpoint, and (b) the filesystem view at restart would be
the same as at checkpoint.

Running applications inside an isolated container is one way to
achieve that (and more so, to provide guarantees on that). Doing
that provides certain assurance on the resulting checkpoint image.

However, the requirements may be satisfied even outside a container
by, for example, a well behaved applications; except that then we
can't say it's safe -  it depends on the application.

> We also require that the application process tree be frozen before
> checkpointing the application. So even if the checkpoint process takes
> a few minutes, the state of the resources (files, pipes, signals etc)
> does not change since a) application is containerized b) container is
> frozen.
> 
> We already have the ability to run applications inside containers, using
> the clone() system call (see lxc.sf.net for example) and the ability to
> freeze the application using the freezer cgroup in the linux kenrnel.
> 
> | 
> | I was hoping to figure out whether it would also still be safe on
> | a cluster filesystem as well,
> 
> For clusters and NFS, an external protocol has to be established so that
> the distrubuted application can be started/frozen/checkpointed/restarated
> in a coordinated way.
> 
> I think that is something that would have to be built on top of the
> checkpoint/restart functionality that we are working on. Or maybe there
> are existing implementations that we would need to plug into.
> 
> Hope that helps, but its possible I missed your question :-). If so
> please let me know.

What you refer to is checkpoint in a cluster, or distributed checkpoint
of multiple cooperating processes/applications that run on multiple
hosts. Indeed, one simple way to do it is coordinated distributed
checkpoint and restart.

However, I think the question was about a single application (or
container) that is accessing remote and clustered (and possibly
distributed) *file systems*.

Ideally, we would like to have a method to snapshot a filesystem
at checkpoint to guarantee that at restart we have a consistent
view of that file system. This is regardless of whether the file
system is local or remote.  In the absence of such a mechanism,
we will have to rely on the file system not being changed (at least
those parts that the checkpoint application expects to remain as
they had been) until the restart.

Oren.
