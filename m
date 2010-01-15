From: Matthew Helsley <matt.helsley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/4] fanotify: Add pids to events
Date: Thu, 14 Jan 2010 20:41:10 -0800
Message-ID: <6a12d2f31001142041j7f917b07l1e1a728790175321__33171.5093031109$1263530618$gmane$org@mail.gmail.com>
References: <20091202141452.12819.93536.stgit@paris.rdu.redhat.com>
	<20091202141458.12819.96170.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091202141458.12819.96170.stgit-E+B5uJFuEZf0UfVguI6niVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, agruen-l3A5Bk7waGM@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Dec 2, 2009 at 6:14 AM, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> From: Andreas Gruenbacher <agruen-l3A5Bk7waGM@public.gmane.org>
>
> Pass the process identifiers of the triggering processes to fanotify
> listeners: this information is useful for event filtering and logging.
>
> Signed-off-by: Andreas Gruenbacher <agruen-l3A5Bk7waGM@public.gmane.org>
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>
> =A0fs/notify/fanotify/fanotify.c =A0 =A0 =A0| =A0 =A05 +++--
> =A0fs/notify/fanotify/fanotify_user.c | =A0 =A01 +
> =A0fs/notify/notification.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +++
> =A0include/linux/fanotify.h =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0include/linux/fsnotify_backend.h =A0 | =A0 =A01 +
> =A05 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
> index 5b0b6b4..881067d 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
> @@ -10,8 +10,9 @@ static bool should_merge(struct fsnotify_event *old, st=
ruct fsnotify_event *new)
> =A0{
> =A0 =A0 =A0 =A0pr_debug("%s: old=3D%p new=3D%p\n", __func__, old, new);
>
> - =A0 =A0 =A0 if ((old->to_tell =3D=3D new->to_tell) &&
> - =A0 =A0 =A0 =A0 =A0 (old->data_type =3D=3D new->data_type)) {
> + =A0 =A0 =A0 if (old->to_tell =3D=3D new->to_tell &&
> + =A0 =A0 =A0 =A0 =A0 old->data_type =3D=3D new->data_type &&
> + =A0 =A0 =A0 =A0 =A0 old->tgid =3D=3D new->tgid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (old->data_type) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case (FSNOTIFY_EVENT_PATH):
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((old->path.mnt =3D=3D =
new->path.mnt) &&
> diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fano=
tify_user.c
> index 7646111..7cfb2f6 100644
> --- a/fs/notify/fanotify/fanotify_user.c
> +++ b/fs/notify/fanotify/fanotify_user.c
> @@ -108,6 +108,7 @@ static ssize_t fill_event_metadata(struct fsnotify_gr=
oup *group,
> =A0 =A0 =A0 =A0metadata->event_len =3D FAN_EVENT_METADATA_LEN;
> =A0 =A0 =A0 =A0metadata->vers =3D FANOTIFY_METADATA_VERSION;
> =A0 =A0 =A0 =A0metadata->mask =3D fanotify_outgoing_mask(event->mask);
> + =A0 =A0 =A0 metadata->pid =3D pid_vnr(event->tgid);

Eric, you never replied to my point about pid namespaces
(http://lkml.org/lkml/2009/7/1/2). I'm still concerned that it's a
problem for this patch. I've cc'd some pid namespace folks, listed the
problems, and some alternative solutions (where I could think of any)
below:

1. Since fanotify doesn't hold a reference to the struct pid then the
pid can become stale before the event is acted upon.
    solution a: Just ignoring this problem, like other interfaces
often do, is probably ok.
    ... ?
    solution z: Seems to require taking a reference to the pid and
giving userspace a way to drop the reference after it's done using
this value to refer to the process (yuck).

2. If the event recipient does a clone and enters a new pidns the pid
number will be incorrect without any indication.
  solution a: The events could be flushed during clone(CLONE_NEWPID)
but then userspace would miss
      them.
  solution b: Translating the pids wouldn't work because the tasks
generaly won't exist in the new
      namespace. So perhaps just write negative values in the pid
fields during clone(CLONE_NEWPID).

3. If the listening process is not in the same or an ancestor pid
namespace of the triggering process then there is no correct pid
corresponding to the event.  (Note: Always using the initial pid
namespace isn't a good [interim] solution -- then programs relying on
fanotify couldn't run in other pid namespaces).
    solution a: Again, perhaps they should be set to negative values.
    ... ?
    solution z: Disable fanotify in non-initial pid namespaces (yuck).

Cheers,
    -Matt Helsley
