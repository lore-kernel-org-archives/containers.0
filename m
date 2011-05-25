From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: use init_cred when populating new cgroupfs mount
Date: Wed, 25 May 2011 15:16:01 -0700
Message-ID: <BANLkTim4T168wDqPUwZ=n_Yr2KdKAOs0Ww@mail.gmail.com>
References: <20110525213534.28016.33058.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110525213534.28016.33058.stgit-E+B5uJFuEZf0UfVguI6niVaTQe2KTcn/@public.gmane.org>
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
Cc: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, rhel6-cc-external-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 25, 2011 at 2:35 PM, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks,
Paul

> ---
>
> =A0kernel/cgroup.c | =A0 =A05 +++++
> =A01 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 909a355..38b32dd 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -27,9 +27,11 @@
> =A0*/
>
> =A0#include <linux/cgroup.h>
> +#include <linux/cred.h>
> =A0#include <linux/ctype.h>
> =A0#include <linux/errno.h>
> =A0#include <linux/fs.h>
> +#include <linux/init_task.h>
> =A0#include <linux/kernel.h>
> =A0#include <linux/list.h>
> =A0#include <linux/mm.h>
> @@ -1513,6 +1515,7 @@ static struct dentry *cgroup_mount(struct file_syst=
em_type *fs_type,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *root_cgrp =3D &root->top_cg=
roup;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct inode *inode;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroupfs_root *existing_root;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cred *cred;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(sb->s_root !=3D NULL);
> @@ -1592,7 +1595,9 @@ static struct dentry *cgroup_mount(struct file_syst=
em_type *fs_type,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(&root_cgrp->children));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(root->number_of_cgroups !=3D 1);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cred =3D override_creds(&init_cred);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cgroup_populate_dir(root_cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 revert_creds(cred);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&inode->i_mutex);
> =A0 =A0 =A0 =A0} else {
>
>
