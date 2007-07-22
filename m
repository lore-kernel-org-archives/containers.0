From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/4] sysfs: Remove first pass at shadow directory support
Date: Mon, 23 Jul 2007 03:35:27 +0900
Message-ID: <46A3A36F.9070904@gmail.com>
References: <4676C798.2090404@bull.net>
	<1182446577.8138.29.camel@localhost>	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>	<20070621211637.GB10583@suse.de>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>
	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14pk13svx.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

Hope my late review isn't too late.

Eric W. Biederman wrote:
> While shadow directories appear to be a good idea, the current scheme
> of controlling their creation and destruction outside of sysfs appears
> to be a locking and maintenance nightmare in the face of sysfs
> directories dynamically coming and going.

Yeah, shadow directory was a real PITA while restructuring sysfs.  I
tried hard to keep it working but, without test case and detailed
documentation, I'm pretty sure I broke something.

My feeling was that it was merged too early and implementation was too
tightly coupled with other more regular paths.  Anyways, glad shadow
dirs are getting some loving care.  If properly done, we should be able
to simplify sysfs_get_dentry(), removal logic and save a pointer in
sysfs_dirent.

> Which can now occur for
> directories containing network devices when CONFIG_SYSFS_DEPRECATED is
> not set.

Shadow directories were always pinned - both the shadowed one and
shadows.  Well, that was the theory at least.

> -int sysfs_rename_dir(struct kobject *kobj, struct sysfs_dirent *new_parent_sd,
> -		     const char *new_name)
> +int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
>  {
> -	struct sysfs_dirent *sd = kobj->sd;
> -	struct dentry *new_parent = NULL;
> +	struct sysfs_dirent *sd;
> +	struct dentry *parent = NULL;
>  	struct dentry *old_dentry = NULL, *new_dentry = NULL;
> +	struct sysfs_dirent *parent_sd;
>  	const char *dup_name = NULL;
>  	int error;
>  
> +	if (!kobj->parent)
> +		return -EINVAL;

Please don't do this.  The goal is to decouple sysfs and kobj.

>  	/* get dentries */
> +	sd = kobj->sd;
>  	old_dentry = sysfs_get_dentry(sd);
>  	if (IS_ERR(old_dentry)) {
>  		error = PTR_ERR(old_dentry);
>  		goto out_dput;
>  	}
>  
> -	new_parent = sysfs_get_dentry(new_parent_sd);
> -	if (IS_ERR(new_parent)) {
> -		error = PTR_ERR(new_parent);
> +	parent_sd = kobj->parent->sd;
> +	parent = sysfs_get_dentry(parent_sd);
> +	if (IS_ERR(parent)) {
> +		error = PTR_ERR(parent);
>  		goto out_dput;

You can simply do parent = old_dentry->d_parent.  parent is guaranteed
to be there as long as we hold old_dentry.  In the original code,
new_parent needed to be looked because new_parent wasn't necessarily
old_dentry's parent.

> @@ -965,10 +957,10 @@ int sysfs_rename_dir(struct kobject *kobj, struct sysfs_dirent *new_parent_sd,
>   out_drop:
>  	d_drop(new_dentry);
>   out_unlock:
> -	mutex_unlock(&new_parent->d_inode->i_mutex);
> +	mutex_unlock(&parent->d_inode->i_mutex);
>   out_dput:
>  	kfree(dup_name);
> -	dput(new_parent);
> +	dput(parent);

So, dput(parent) can go away too.

> diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
> index f318b73..4606f7c 100644
> --- a/fs/sysfs/group.c
> +++ b/fs/sysfs/group.c
> @@ -13,7 +13,6 @@
>  #include <linux/dcache.h>
>  #include <linux/namei.h>
>  #include <linux/err.h>
> -#include <linux/fs.h>
>  #include <asm/semaphore.h>
>  #include "sysfs.h"

Can you explain this one a bit?

Thanks.

-- 
tejun
