From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Add the trigger callback to struct cftype
Date: Thu, 13 Mar 2008 05:19:04 -0700
Message-ID: <6599ad830803130519k468f3caj54e59d51bf46a4b7@mail.gmail.com>
References: <47D9114F.6020301@openvz.org> <47D911B1.1010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D911B1.1010309-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 13, 2008 at 4:36 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> Trigger callback can be used to receive a kick-up from the
>  user space. The string written is ignored.
>
>  The cftype->private is used for multiplexing events.
>
>  Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

I'm not sure about the behaviour of passing cft->private rather than
just cft, but we can always change that later if it turns that some
user needs the cft pointer for some other reason.

Paul

>
>  ---
>   include/linux/cgroup.h |    8 ++++++++
>   kernel/cgroup.c        |    4 ++++
>   2 files changed, 12 insertions(+), 0 deletions(-)
>
>  diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>  index 785a01c..2d1d151 100644
>  --- a/include/linux/cgroup.h
>  +++ b/include/linux/cgroup.h
>  @@ -243,6 +243,14 @@ struct cftype {
>          */
>         int (*write_s64) (struct cgroup *cgrp, struct cftype *cft, s64 val);
>
>  +       /*
>  +        * trigger() callback can be used to get some kick from the
>  +        * userspace, when the actual string written is not important
>  +        * at all. The private field can be used to determine the
>  +        * kick type for multiplexing.
>  +        */
>  +       int (*trigger)(struct cgroup *cgrp, unsigned int event);
>  +
>         int (*release) (struct inode *inode, struct file *file);
>   };
>
>  diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>  index e8e8ec4..f2d8f25 100644
>  --- a/kernel/cgroup.c
>  +++ b/kernel/cgroup.c
>  @@ -1410,6 +1410,10 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
>                 return cft->write(cgrp, cft, file, buf, nbytes, ppos);
>         if (cft->write_u64 || cft->write_s64)
>                 return cgroup_write_X64(cgrp, cft, file, buf, nbytes, ppos);
>  +       if (cft->trigger) {
>  +               int ret = cft->trigger(cgrp, (unsigned int)cft->private);
>  +               return ret ? ret : nbytes;
>  +       }
>         return -EINVAL;
>   }
>
>  --
>  1.5.3.4
>
>
