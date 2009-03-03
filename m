From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] cgroups: show correct file mode
Date: Mon, 2 Mar 2009 17:16:03 -0800
Message-ID: <6599ad830903021716o20f8a7a7k66045ad75dbab5b1@mail.gmail.com>
References: <49AB40BF.4030706@cn.fujitsu.com>
	<6599ad830903021019p3b29c173oc7772af6679d90e0@mail.gmail.com>
	<49AC8307.7090008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49AC8307.7090008-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 2, 2009 at 5:08 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> Those patches are small and trivial, but it's ok for me to do this
> automatically. How about below patch.
>
> Note cpuset.memory_pressure is read-only though it has read handler.
> Since if the read handler is removed, it'll return EINVAL instead of
> the current EACCESS, I think it's better to leave as it is.

Hmm. I find it hard to believe that anyone would have behaviour that
depends on cpuset.memory_pressure returning EACCES rather than EINVAL,
but I guess it's not a big deal.

On the += or |= issue, I think |= is slightly more familiar to most
readers given that you're doing bit options, although the end result
is the same in this case.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

>
> =====================
>
> cgroups: show correct file mode
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/cgroup.h |    5 +++++
>  kernel/cgroup.c        |   30 ++++++++++++++++++++++++++++++
>  kernel/cpuset.c        |    1 +
>  3 files changed, 36 insertions(+)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 6ad1989..af3c10f 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -258,6 +258,11 @@ struct cftype {
>         */
>        char name[MAX_CFTYPE_NAME];
>        int private;
> +       /*
> +        * If not 0, file mode is set to this value, otherwise it will
> +        * be figured out automatically
> +        */
> +       int mode;
>
>        /*
>         * If non-zero, defines the maximum length of string that can
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 379baa3..0b19204 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1750,6 +1750,33 @@ static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
>        return error;
>  }
>
> +/**
> + * cgroup_file_mode - deduce file mode of a control file
> + * @cft: the control file in question
> + *
> + * returns cftype->mode if ->mode is not 0
> + * returns 0644 if it has both a read and a write handler
> + * returns 0444 if it has only a read handler
> + * returns 0200 if it has only a write hander
> + */
> +static int cgroup_file_mode(const struct cftype *cft)
> +{
> +       int mode = 0;
> +
> +       if (cft->mode)
> +               return cft->mode;
> +
> +       if (cft->read || cft->read_u64 || cft->read_s64 ||
> +           cft->read_map || cft->read_seq_string)
> +               mode += 0444;
> +
> +       if (cft->write || cft->write_u64 || cft->write_s64 ||
> +           cft->write_string || cft->trigger)
> +               mode += 0200;
> +
> +       return mode;
> +}
> +
>  int cgroup_add_file(struct cgroup *cgrp,
>                       struct cgroup_subsys *subsys,
>                       const struct cftype *cft)
> @@ -1757,6 +1784,7 @@ int cgroup_add_file(struct cgroup *cgrp,
>        struct dentry *dir = cgrp->dentry;
>        struct dentry *dentry;
>        int error;
> +       int mode;
>
>        char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
>        if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
> @@ -1767,6 +1795,7 @@ int cgroup_add_file(struct cgroup *cgrp,
>        BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
>        dentry = lookup_one_len(name, dir, strlen(name));
>        if (!IS_ERR(dentry)) {
> +               mode = cgroup_file_mode(cft);
>                error = cgroup_create_file(dentry, 0644 | S_IFREG,
>                                                cgrp->root->sb);
>                if (!error)
> @@ -2349,6 +2378,7 @@ static struct cftype files[] = {
>                .write_u64 = cgroup_tasks_write,
>                .release = cgroup_tasks_release,
>                .private = FILE_TASKLIST,
> +               .mode = 0644,
>        },
>
>        {
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index a46d693..31e28b3 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1678,6 +1678,7 @@ static struct cftype files[] = {
>                .read_u64 = cpuset_read_u64,
>                .write_u64 = cpuset_write_u64,
>                .private = FILE_MEMORY_PRESSURE,
> +               .mode = 0444,
>        },
>
>        {
>
>
