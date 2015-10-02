From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] lib/kobject_uevent.c: disable broadcast of uevents to
	other namespaces
Date: Fri, 2 Oct 2015 13:40:58 -0400
Message-ID: <CAA4jN2bQu8T5_RwLJDcA1oNGZOfKxufaL4JBjyPB+8GT7n4+XQ@mail.gmail.com>
References: <cover.1441762578.git.michael.coss@alcatel-lucent.com>
	<51c185b6fa89f0b8e9e7dcaffb3c21c975c84302.1441762578.git.michael.coss@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51c185b6fa89f0b8e9e7dcaffb3c21c975c84302.1441762578.git.michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Michael,

While experimenting with your patches, I discovered a couple of issues:

1) One problem is that the test to disable broadcast has an undesired
side-effect: it silently drops kernel uevents designated to specific net
namespace(s). For example, uevents related to the "net" subsystem are now
gone.

More specifically, kobject_uevent_env() eventually calls
netlink_broadcast_filtered() with "kobj_bcast_filter()" as the @filter
argument; This filter is invoked by the netlink delivery code  (for each
target socket): if the respective kobject has a valid "struct
kobj_ns_type_operations ops" then it will use the ops->netlink_ns() as the
target network namespace, and only post to sockets that belong to that
target network namespace.

To remedy this, I suggest to move the test into "kobj_bcast_filter()", by
replacing the final "return 0;" with "return !net_eq(sock_net(dsk),
&init_net);".

2) Another problem is that when a task writes to the special file "uevent"
in /sys/..., e.g. "/sys/devices/virtual/block/dm-0/uevent", it should
ideally expect to see the resulting uevent in the network namespace to
which it belongs, and only there. With broadcast disabled it will instead
reach only the init network namespace (while before the patch it would
reach all network namespaces).

This could be fixed by having the userspace daemon that listens in the init
network namespace forward such uevents to the "origin" network namespace
(i.e. where the task belongs). However, I couldn't figure out a way for
userspace to tell whether a particular uevent was "task made" via the
respective "uevent" file and if so, in which network namespace - or by
which task/pid - it was done.

So I can't think of another solution but to do it in the kernel: handle
writes to "uevent" in a way that only posts them in the network namespace
of the writer task.

Do you see a better option?


Thanks,

Oren.


On Wed, Sep 9, 2015 at 2:53 PM, Michael J. Coss <
michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org> wrote:

> Restrict sending uevents to only those listeners operating in the same
> network namespace as the system init process.  This is the first step
> toward allowing policy control of the forwarding of events to other
> namespaces in userspace.
>
> Signed-off-by: Michael J. Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
> ---
>  lib/kobject_uevent.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
> index f6c2c1e..d791e33 100644
> --- a/lib/kobject_uevent.c
> +++ b/lib/kobject_uevent.c
> @@ -295,6 +295,10 @@ int kobject_uevent_env(struct kobject *kobj, enum
> kobject_action action,
>                 if (!netlink_has_listeners(uevent_sock, 1))
>                         continue;
>
> +               /* forward event only to the host systems network
> namespaces */
> +               if (!net_eq(sock_net(uevent_sock), &init_net))
> +                       continue;
> +
>                 /* allocate message with the maximum possible size */
>                 len = strlen(action_string) + strlen(devpath) + 2;
>                 skb = alloc_skb(len + env->buflen, GFP_KERNEL);
> --
> 2.4.6
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
