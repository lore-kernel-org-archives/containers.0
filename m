From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: use init_cred when populating new cgroupfs mount
Date: Wed, 25 May 2011 17:57:16 -0700
Message-ID: <4DDDA56C.3060708@schaufler-ca.com>
References: <20110525213534.28016.33058.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rhel6-cc-external-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
List-Id: containers.vger.kernel.org

On 5/25/2011 2:35 PM, Eric Paris wrote:
> We recently found that in some configurations SELinux was blocking the ability
> for cgroupfs to be mounted.  The reason for this is because cgroupfs creates
> files and directories during the get_sb() call and also uses lookup_one_len()
> during that same get_sb() call.  This is a problem since the security
> subsystem cannot initialize the superblock and the inodes in that filesystem
> until after the get_sb() call returns.  Thus we leave the inodes in
> an unitialized state during get_sb().  For the vast majority of filesystems
> this is not an issue, but since cgroupfs uses lookup_on_len() it does
> search permission checks on the directories in the path it walks.  Since the
> inode security state is not set up SELinux does these checks as if the inodes
> were 'unlabeled.'
>
> Many 'normal' userspace process do not have permission to interact with
> unlabeled inodes.  The solution presented here is to do the permission checks
> of path walk and inode creation as the kernel rather than as the task that
> called mount.  Since the kernel has permission to read/write/create
> unlabeled inodes the get_sb() call will complete successfully and the SELinux
> code will be able to initialize the superblock and those inodes created during
> the get_sb() call.
>
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Any idea what this change will do to the behavior of other LSMs?
In any case, it should be posted to the LSM list.


> ---
>
>  kernel/cgroup.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 909a355..38b32dd 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -27,9 +27,11 @@
>   */
>  
>  #include <linux/cgroup.h>
> +#include <linux/cred.h>
>  #include <linux/ctype.h>
>  #include <linux/errno.h>
>  #include <linux/fs.h>
> +#include <linux/init_task.h>
>  #include <linux/kernel.h>
>  #include <linux/list.h>
>  #include <linux/mm.h>
> @@ -1513,6 +1515,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>  		struct cgroup *root_cgrp = &root->top_cgroup;
>  		struct inode *inode;
>  		struct cgroupfs_root *existing_root;
> +		const struct cred *cred;
>  		int i;
>  
>  		BUG_ON(sb->s_root != NULL);
> @@ -1592,7 +1595,9 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>  		BUG_ON(!list_empty(&root_cgrp->children));
>  		BUG_ON(root->number_of_cgroups != 1);
>  
> +		cred = override_creds(&init_cred);
>  		cgroup_populate_dir(root_cgrp);
> +		revert_creds(cred);
>  		mutex_unlock(&cgroup_mutex);
>  		mutex_unlock(&inode->i_mutex);
>  	} else {
>
>
> --
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to majordomo-+05T5uksL2qpZYMLLGbcSA@public.gmane.org with
> the words "unsubscribe selinux" without quotes as the message.
>
>
