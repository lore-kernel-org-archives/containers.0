From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Wed, 24 Sep 2008 14:20:16 -0500
Message-ID: <20080924192016.GA31664@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175308.GI17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080912175308.GI17350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> >From 8886ef518c1855890be7fbc6bea853ce7feb263e Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 9 Sep 2008 18:42:44 -0700
> Subject: [PATCH 08/10] Define get_sb_ref()
> 
> See comments in fs/super.c (in patch below) for need for this interface.
> This interface will be used in follow-on patch to enable multiple
> instances of devpts.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/super.c         |   37 +++++++++++++++++++++++++++++++++++++
>  include/linux/fs.h |    2 ++
>  2 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index e931ae9..ba7059c 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -882,6 +882,43 @@ int get_sb_single(struct file_system_type *fs_type,
>  }
> 
>  EXPORT_SYMBOL(get_sb_single);
> +/*
> + * int get_sb_ref(struct super_block *sb, int flags, void *data,
> +                struct vfsmount *mnt)
> + *
> + * 	This interface is needed to support multiple mounts in devpts while
> + * 	preserving backward compatibility of the current 'single-mount'
> + * 	semantics i.e all mounts of devpts without the 'newinstance' mount
> + * 	option should bind to the initial kernel mount, like get_sb_single().
> + * 	Mounts with 'newinstance' option create a new private namespace.
> + *
> + * 	But for single-mount semantics, devpts cannot use get_sb_single(),
> + * 	because get_sb_single()/sget() find and use the super-block from
> + * 	the most recent mount of devpts. But that recent mount may be a
> + * 	'newinstance' mount and get_sb_single() would pick the newinstance
> + * 	super-block instead of the initial super-block.
> + *
> + * 	This is a simplified version of get_sb_single() and assumes that
> + * 	caller has a properly initialized @sb.
> + */
> +int get_sb_ref(struct super_block *sb, int flags, void *data,
> +                struct vfsmount *mnt)
> +{
> +        int err;
> +
> +        spin_lock(&sb_lock);
> +
> +        if (!grab_super(sb))
> +                return -EAGAIN;
> +
> +        err = do_remount_sb(sb, flags, data, 0);
> +        if (err) {
> +                /* Don't deactivate_super() - its from initial pts mount */

But you did increment sb->s_active, and you're not decrementing it?

> +                up_write(&sb->s_umount);
> +                return err;
> +        }
> +        return simple_set_mnt(mnt, sb);
> +}
> 
>  struct vfsmount *
>  vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 580b513..3bda46d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1512,6 +1512,8 @@ extern int get_sb_single(struct file_system_type *fs_type,
>  	int flags, void *data,
>  	int (*fill_super)(struct super_block *, void *, int),
>  	struct vfsmount *mnt);
> +extern int get_sb_ref(struct super_block *sb, int flags, void *data,
> +	struct vfsmount *mnt);
>  extern int get_sb_nodev(struct file_system_type *fs_type,
>  	int flags, void *data,
>  	int (*fill_super)(struct super_block *, void *, int),
> -- 
> 1.5.2.5
