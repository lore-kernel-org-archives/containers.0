From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Tue, 30 Sep 2008 10:13:25 -0500
Message-ID: <20080930151325.GA26713@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175308.GI17350@us.ibm.com>
	<1222286127.15523.66.camel@nimitz>
	<20080926212115.GD31505@us.ibm.com>
	<1222464662.25451.23.camel@nimitz>
	<20080927004727.GA2161@us.ibm.com> <48E0DF71.2070007@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48E0DF71.2070007-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> > | On Fri, 2008-09-26 at 14:21 -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> > | > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> > | > | On Fri, 2008-09-12 at 10:53 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > | > | > + *     But for single-mount semantics, devpts cannot use get_sb_single(),
> > | > | > + *     because get_sb_single()/sget() find and use the super-block from
> > | > | > + *     the most recent mount of devpts. But that recent mount may be a
> > | > | > + *     'newinstance' mount and get_sb_single() would pick the newinstance
> > | > | > + *     super-block instead of the initial super-block.
> > | > | 
> > | > | Can't you just override the test() function to get what you want here?
> > | > 
> > | > get_sb_single() does not take a test() parameter and so I would still
> > | > need a get_sb_ref() or get_sb_special() interface right ? 
> > | > 
> > | > This special interface could call sget() with a custom-test function,
> > | > to get the super-block.  But in case of devpts, we already have the
> > | > super-block. So we don't need to call sget(). We just need get a reference
> > | > and remount.
> > | 
> > | Well, you shouldn't be using get_sb_single() at all any more, right?
> > 
> > You mean define something like get_sb_multi_mode() and define a  new
> > test function ? I can try that.
> > 
> > | 
> > | At this point, you're doing something super-specialized for devpts.  So,
> > | why do this in super.c.  Just put it in place of devpts_get_sb()'s
> > | current contents.
> > 
> > grab_super() is static. I have to either externalize it or define the
> > new interface in fs/super.c.  I am not sure if mqueue ns or others have
> > similar semantics and if so, defining interface in fs/super.c has a better
> > chance of being found/generalized when there is another user.
> 
> mqueue ns and proc have similar needs but there are those special little
> things that make difficult to share a common routine.
> 
> Here's the get_sb_single_ns() we would like to share. 
> 
> C.
>   
> From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> This patch defines the mqueuefs ->get_sb routine as follows:
>   . when allocating a new super_block, the mq namespace is stored in that
>     super_block s_fs_info attribute.
>   . when looking for a super_block, a comparison is done against the
>     s_fs_info attribute (it should be equal to the mq namespace that will
>     be passed in as a data parameter).
> 
> Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> ---
>  ipc/mqueue.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 51 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.27-rc7/ipc/mqueue.c
> ===================================================================
> --- linux-2.6.27-rc7.orig/ipc/mqueue.c	2008-09-25 15:03:58.000000000 +0200
> +++ linux-2.6.27-rc7/ipc/mqueue.c	2008-09-25 16:28:13.000000000 +0200
> @@ -201,6 +201,48 @@ static int mqueue_fill_super(struct supe
>  	return 0;
>  }
> 
> +static int compare_sb_single_ns(struct super_block *sb, void *data)
> +{
> +	return sb->s_fs_info == data;
> +}
> +
> +static int set_sb_single_ns(struct super_block *sb, void *data)
> +{
> +	struct mq_namespace *mq_ns = (struct mq_namespace *) data;
> +	int error;
> +
> +	sb->s_fs_info = get_mq_ns(mq_ns);
> +	error = set_anon_super(sb, NULL);
> +	if (error)
> +		put_mq_ns(mq_ns);

Hmm, how come fs/proc/root.c doesn't do a put_pid_ns if set_anon_super()
failed?  Does it need to do that, or is there some part of the error
path cleanup at a higher level that would cause that to happen anyway
(i.e. kill_sb ends up being called anyway)?

> +	return error;
> +}
> +
> +static int get_sb_single_ns(struct file_system_type *fs_type,
> +	int flags, void *data,
> +	int (*fill_super)(struct super_block *, void *, int),
> +	struct vfsmount *mnt)
> +{
> +	struct super_block *s;
> +	int error;
> +
> +	s = sget(fs_type, compare_sb_single_ns, set_sb_single_ns, data);
> +	if (IS_ERR(s))
> +		return PTR_ERR(s);
> +	if (!s->s_root) {
> +		s->s_flags = flags;
> +		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
> +		if (error) {
> +			up_write(&s->s_umount);
> +			deactivate_super(s);
> +			return error;
> +		}
> +		s->s_flags |= MS_ACTIVE;
> +	}
> +	do_remount_sb(s, flags, data, 0);
> +	return simple_set_mnt(mnt, s);
> +}
> +
>  static int mqueue_get_sb(struct file_system_type *fs_type,
>  			 int flags, const char *dev_name,
>  			 void *data, struct vfsmount *mnt)
> @@ -208,6 +250,14 @@ static int mqueue_get_sb(struct file_sys
>  	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
>  }
> 
> +static void mqueue_kill_sb(struct super_block *sb)
> +{
> +	struct mq_namespace *mq_ns = (struct mq_namespace *) sb->s_fs_info;
> +
> +	kill_litter_super(sb);
> +	put_mq_ns(mq_ns);
> +}
> +
>  static void init_once(void *foo)
>  {
>  	struct mqueue_inode_info *p = (struct mqueue_inode_info *) foo;
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
