From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: sysfs : fix kobject rename with multiple namespaces
Date: Mon, 5 May 2008 11:56:15 -0500
Message-ID: <20080505165614.GA14956@sergelap.austin.ibm.com>
References: <481E43FF.9070905@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <481E43FF.9070905-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> To be applied on top of the sysfs per namespace patchset.

> Subject: avoid kobject name conflict with different namespaces
> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> The renaming of a kobject will fail if there is another kobject
> with the same name belonging to another namespace.
> 
> This patch makes the kobject lookup in kobject_rename to check if
> the object exists _and_ belongs to the same namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/sysfs/dir.c        |   10 ++++++++++
>  include/linux/sysfs.h |    7 +++++++
>  lib/kobject.c         |    2 +-
>  3 files changed, 18 insertions(+), 1 deletion(-)
> 
> Index: net-next-2.6/fs/sysfs/dir.c
> ===================================================================
> --- net-next-2.6.orig/fs/sysfs/dir.c
> +++ net-next-2.6/fs/sysfs/dir.c
> @@ -899,6 +899,16 @@ err_out:
>  	return error;
>  }
> 
> +int sysfs_tag_cmp(struct kobject * kobj1, struct kobject *kobj2)

The patch looks good to me, except I'd really rename this to
'sysfs_tag_eq'.  Calling it 'cmp', returning 't1!=t2', then checking for
!sysfs_tag_cmp really increases the amount of thinking i have to do to
make sure everything is kosher :)

Maybe it's just me.

thanks,
-serge

> +{
> +	struct sysfs_dirent *sd1 = kobj1->sd;
> +	struct sysfs_dirent *sd2 = kobj2->sd;
> +	const void *tag1 = sysfs_dirent_tag(sd1);
> +	const void *tag2 = sysfs_dirent_tag(sd2);
> +
> +	return tag1 != tag2;
> +}
> +
>  int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
>  {
>  	struct sysfs_dirent *sd = kobj->sd;
> Index: net-next-2.6/include/linux/sysfs.h
> ===================================================================
> --- net-next-2.6.orig/include/linux/sysfs.h
> +++ net-next-2.6/include/linux/sysfs.h
> @@ -95,6 +95,8 @@ int sysfs_schedule_callback(struct kobje
> 
>  int __must_check sysfs_create_dir(struct kobject *kobj);
>  void sysfs_remove_dir(struct kobject *kobj);
> +int sysfs_tag_cmp(struct kobject * kobj1, struct kobject *kobj2);
> +
>  int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
>  int __must_check sysfs_move_dir(struct kobject *kobj,
>  				struct kobject *new_parent_kobj);
> @@ -152,6 +154,11 @@ static inline void sysfs_remove_dir(stru
>  	;
>  }
> 
> +static inline int sysfs_tag_cmp(struct kobject * kobj1, struct kobject *kobj2)
> +{
> +	return 0;
> +}
> +
>  static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
>  {
>  	return 0;
> Index: net-next-2.6/lib/kobject.c
> ===================================================================
> --- net-next-2.6.orig/lib/kobject.c
> +++ net-next-2.6/lib/kobject.c
> @@ -418,7 +418,7 @@ int kobject_rename(struct kobject *kobj,
>  	if (kobj->kset) {
>  		struct kobject *temp_kobj;
>  		temp_kobj = kset_find_obj(kobj->kset, new_name);
> -		if (temp_kobj) {
> +		if (temp_kobj && !sysfs_tag_cmp(temp_kobj, kobj)) {
>  			printk(KERN_WARNING "kobject '%s' cannot be renamed "
>  			       "to '%s' as '%s' is already in existence.\n",
>  			       kobject_name(kobj), new_name, new_name);
