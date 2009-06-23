From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] proc connector: add event for process becoming session
	leader
Date: Tue, 23 Jun 2009 14:01:10 -0700
Message-ID: <20090623210110.GB7931__5926.88253750584$1245790969$gmane$org@count0.beaverton.ibm.com>
References: <E1MGUmL-00036A-EE@zelda.netsplit.com>
	<20090622161909.e5706885.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090622161909.e5706885.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Scott James Remnant <scott-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jun 22, 2009 at 04:19:09PM -0700, Andrew Morton wrote:
> Let's cc the Process Events developer..
> 
> On Mon, 15 Jun 2009 13:03:08 +0100
> Scott James Remnant <scott-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > The act of a process becoming a session leader is a useful signal to a
> > supervising init daemon such as Upstart.
> > 
> > While a daemon will normally do this as part of the process of becoming
> > a daemon, it is rare for its children to do so.  When the children do,
> > it is nearly always a sign that the child should be considered detached
> > from the parent and not supervised along with it.
> > 
> > The poster-child example is OpenSSH; the per-login children call setsid()
> > so that they may control the pty connected to them.  If the primary daemon
> > dies or is restarted, we do not want to consider the per-login children
> > and want to respawn the primary daemon without killing the children.
> > 
> > This patch adds a new PROC_SID_EVENT and associated structure to the
> > proc_event event_data union, it arranges for this to be emitted when
> > the special PIDTYPE_SID pid is set.
> > 
> 
> hm, well, I don't have much useful to say about the overall idea, but
> it seems to slot into the existing code simply enough.

No comment on the usefulness of the event here. The code is consistent
with the process events interface though and I see no problems with
the code.

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> 
> > ---
> >  drivers/connector/cn_proc.c |   25 +++++++++++++++++++++++++
> >  include/linux/cn_proc.h     |   10 ++++++++++
> >  kernel/exit.c               |    4 +++-
> >  3 files changed, 38 insertions(+), 1 deletions(-)
> 
> We seem to have forgotten to document this entire interface, so I can't
> ding you for forgetting to update the forgotten documentation.

I've written down the essentials for Documentation/. I've included it as
a patch including the SID info and following my reply to the container issue
below.

Cc'ing manpages folks in case they'd like to review comment on missing
information in the patch.

> > diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
> > index c5afc98..7d48cd9 100644
> > --- a/drivers/connector/cn_proc.c
> > +++ b/drivers/connector/cn_proc.c
> > @@ -139,6 +139,31 @@ void proc_id_connector(struct task_struct *task, int which_id)
> >  	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
> >  }
> >  
> > +void proc_sid_connector(struct task_struct *task)
> 
> It would be nice to have a nice comment explaining what this function
> does.  Ditto all the others in there, really.
> 
> > +{
> > +	struct cn_msg *msg;
> > +	struct proc_event *ev;
> > +	struct timespec ts;
> > +	__u8 buffer[CN_PROC_MSG_SIZE];
> > +
> > +	if (atomic_read(&proc_event_num_listeners) < 1)
> > +		return;
> > +
> > +	msg = (struct cn_msg*)buffer;
> > +	ev = (struct proc_event*)msg->data;
> 
> Please pass all patches through scripts/checkpatch.pl.
> 
> > +	get_seq(&msg->seq, &ev->cpu);
> > +	ktime_get_ts(&ts); /* get high res monotonic timestamp */
> > +	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
> > +	ev->what = PROC_EVENT_SID;
> > +	ev->event_data.sid.process_pid = task->pid;
> 
> This is a bit of a worry.  In a containerised environment, pids are not
> unique.  Now what do we do?

An excellent point. It's broadcast via a netlink multicast address. That
means we'd have pids and listeners from arbitrary combinations of pid
namespaces.

One obvious but poor solution is to only send the pid of the initial
pid namespace. Then it's not ambiguous what an event refers to. However
it also means that the events would only be useful to tasks running
in the initial pid namespace -- not a good solution given Scott's example
and our desire to run things like sshd in separate pid namespaces.

Alternatively, we may be able to split up the connector such that the
listeners only see events from their own pid namespace. I'm not
sure that netlink and connectors can enable this change though.

Cc'ing pidns and containers folks
--

From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add documentation for the process events connector

    Document the process events connector user/kernel interface.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
    Cc: Scott James Remnant <scott-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>a
    Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

diff --git a/Documentation/connector/process-events.txt b/Documentation/connector/process-events.txt
new file mode 100644
index 0000000..3760b8c
--- /dev/null
+++ b/Documentation/connector/process-events.txt
@@ -0,0 +1,173 @@
+OVERVIEW
+
+The process events connector is a kernel-userspace multicast socket
+ that reports process events like fork, exec, id change (real and effective
+user and group ids), and exit events to userspace. Applications that may 
+find these events useful include auditing, system activity monitoring 
+(e.g. top), security, and likely many more.
+
+	The low-level details describing the permissions needed and how to
+read messages from the connector are best described in
+Documentation/connector/connector.txt and netlink(3). This document describes
+messages sent back and forth between the kernel and userspace listeners using
+the connector message format.
+
+GETTING STARTED
+
+	The necessary definitions of the connector address and userspace/kernel
+data can be found by including:
+
+	#include <linux/connector.h>
+	#include <linux/cn_proc.h>
+
+	To listen for process events a task must open a netlink socket and
+bind to a special address:
+
+struct sockaddr_nl cn_addr = {
+	.nl_family = AF_NETLINK,
+	.nl_groups = CN_IDX_PROC,
+	.nl_pid = getpid()
+};
+
+Once bound the listener must inform the kernel that at least one task is
+interested in receiving multicast process events on this socket. This requires
+sending a message with PROC_CN_MCAST_LISTEN in it's payload:
+
+union {
+	struct cn_msg listen_msg = {
+		.id = {
+			.idx = CN_IDX_PROC,
+			.val = CN_VAL_PROC,
+		},
+		.seq = X,
+		.ack = Y,
+		.len = sizeof(enum proc_cn_mcast_op)
+	};
+	char bytes[sizeof(struct cn_msg) + sizeof(enum proc_cn_mcast_op)];
+} buf;
+...
+*((enum proc_cn_mcast_op*)buf.listen_msg.data) = PROC_CN_MCAST_LISTEN;
+
+After sending this message to the kernel the application should expect
+an acknowledgement message (more on ack messages below). Similar to the
+PROC_CN_MCAST_LISTEN message, userspace may send a message with
+PROC_CN_MCAST_IGNORE as its sole payload. Because it is bound to a multicast
+address the IGNORE "control" operation does not necessarily prevent process
+events from becoming available on the socket. Only the last application to
+issue IGNORE ensures that no more process events will be delivered.
+
+Packets received from the kernel are either an acknowledgement of a control
+message or a proper event. Both are described by struct proc_event:
+
+struct proc_event {
+        enum what {
+                PROC_EVENT_NONE = 0x00000000,
+                PROC_EVENT_FORK = 0x00000001,
+                PROC_EVENT_EXEC = 0x00000002,
+                PROC_EVENT_UID  = 0x00000004,
+                PROC_EVENT_GID  = 0x00000040,
+                /* "next" should be 0x00000400 */
+                /* "last" is the last process event: exit */
+                PROC_EVENT_EXIT = 0x80000000
+        } what;
+        __u32 cpu;
+        __u64 __attribute__((aligned(8))) timestamp_ns;
+                /* Number of nano seconds since system boot */
+        union { /* must be last field of proc_event struct */
+                struct {
+                        __u32 err;
+                } ack;
+
+                struct fork_proc_event {
+                        pid_t parent_pid;
+                        pid_t parent_tgid;
+                        pid_t child_pid;
+                        pid_t child_tgid;
+                } fork;
+
+                struct exec_proc_event {
+                        pid_t process_pid;
+                        pid_t process_tgid;
+                } exec;
+
+                struct id_proc_event {
+                        pid_t process_pid;
+                        pid_t process_tgid;
+                        union {
+                                __u32 ruid; /* task uid */
+                                __u32 rgid; /* task gid */
+                        } r;
+                        union {
+                                __u32 euid;
+                                __u32 egid;
+                        } e;
+                } id;
+		struct sid_proc_event {
+			pid_t process_pid;
+			pid_t process_tgid;
+		} sid;
+                struct exit_proc_event {
+                        pid_t process_pid;
+                        pid_t process_tgid;
+                        __u32 exit_code, exit_signal;
+                } exit;
+        } event_data;
+};
+
+All events have valid what, cpu, and timestamp_ns fields. These record what
+the event is, which cpu reported it, and a monotonically-increasing timestamp
+in nanosecond units. Note that while the timestamp is reported in nanoseconds
+the actual time resolution may vary depending on the kernel's clock source(s).
+The cpu, timestamp, and sequence number from the netlink message wrapper
+provide a best-effort means of reassembling events from multiple CPUs
+"in order". It is best-effort because strictly speaking the parallel nature of 
+execution between CPUs precludes offering the strongest ordering guarantees.
+
+Another wrinkle to consider: pids, tgids, session ids, exist in pid namespaces
+while the netlink sockets are part of a network namespace. If these namespaces
+do not coincide then the pids, tgids, and session ids may not exist or may
+refer to the wrong tasks.
+
+TYPES OF PACKETS
+
+There are several types of messages, each with a corresponding .what value:
+	Acknowledgement		PROC_EVENT_NONE
+	Fork			PROC_EVENT_FORK
+	Exec			PROC_EVENT_EXEC
+	UID Change		PROC_EVENT_UID
+	GID Change		PROC_EVENT_GID
+	Session ID Change	PROC_EVENT_SID
+	Exit			PROC_EVENT_EXIT
+
+(Note that while these values are encoded as bits (1 << n) the
+kernel does not report multiple events in the same message.) Each event also
+has a corresponding struct in the event_data union which describes the data
+that is valid for the event.
+
+ACKNOWLEDGEMENT
+
+Acknowledgement messages contain an err field in their
+event_data. When non-zero the err field indicates that the control operation 
+did not succeed. The value is suitable for, but not stored in, errno. For
+example an illegal or unrecognized control operation returns an acknowledgement
+message with event_data.ack.err == EINVAL.
+
+All other messages include at least one pid and a corresponding tgid describing
+which task(s) the event relates to. As with normal Linux convention, pid == tid.
+Each task described in the event has a pid and tgid pair.
+
+FORK
+
+Fork messages are emitted when a task calls the fork() or clone() system calls. 
+They contain the pid and tgid of the parent and child tasks.
+
+EXEC messages indicate via pid and tgid which task exec'd.
+
+UID messages indicate that the task's real and/or effective user id has changed.
+
+GID messages indicate that the task's real and/or effective group id has changed.
+
+SID messages indicate that the task has started a new session.
+
+EXIT messages indicate that the task has exitted and provide the exit code and
+exit signal.
