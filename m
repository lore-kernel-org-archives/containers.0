From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 1/2] fs: Extend mount_ns with support for a fast
	namespace to vfsmount function
Date: Fri, 23 Mar 2018 23:15:11 +0000
Message-ID: <20180323231511.GK30522__20050.7253328853$1521846805$gmane$org@ZenIV.linux.org.uk>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
	<87k1u3ti9e.fsf@xmission.com> <87fu4qo4ff.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fu4qo4ff.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Mar 23, 2018 at 04:41:40PM -0500, Eric W. Biederman wrote:

>  struct dentry *mount_ns(struct file_system_type *fs_type,
>  	int flags, void *data, void *ns, struct user_namespace *user_ns,
> +	struct vfsmount *(*ns_to_mnt)(void *ns),
>  	int (*fill_super)(struct super_block *, void *, int))
>  {
>  	struct super_block *sb;
> -
> +	int (*test_super)(struct super_block *, void *) = ns_test_super;
>  	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
>  	 * over the namespace.
>  	 */
>  	if (!(flags & SB_KERNMOUNT) && !ns_capable(user_ns, CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
>  
> -	sb = sget_userns(fs_type, ns_test_super, ns_set_super, flags,
> -			 user_ns, ns);
> +	if (ns_to_mnt) {
> +		test_super = NULL;
> +		if (!(flags & SB_KERNMOUNT)) {
> +			struct vfsmount *m = ns_to_mnt(ns);
> +			if (IS_ERR(m))
> +				return ERR_CAST(m);
> +			atomic_inc(&m->mnt_sb->s_active);
> +			down_write(&m->mnt_sb->s_umount);
> +			return dget(m->mnt_root);

This is completely wrong.  Look:
	* SB_KERNMOUNT and !SB_KERNMOUNT cases are almost entirely isolated;
completely so once that ns_to_mnt becomes unconditionally non-NULL.  
	* in !SB_KERNMOUNT passing ns_to_mnt() is pointless - you might as
well pass existing vfsmount (or ERR_PTR()) and use _that_.  fill_super()
is not used at all in that case.
	* is SB_KERNMOUNT ns_to_mnt serves only as a flag, eventually
constant true.

So let's split it in two helpers and give them sane arguments.
