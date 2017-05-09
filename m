From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 09 May 2017 11:55:19 -0500
Message-ID: <87a86mvuko.fsf@xmission.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170508181156.GA23112-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Mon, 8 May 2017 13:11:56 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> Changelog:
[snip]
>    May 8, 2017:
>       . fix leaking dentry refcount in cap_inode_getsecurity
>
[snip]
> +/*
> + * getsecurity: We are called for security.* before any attempt to read the
> + * xattr from the inode itself.
> + *
> + * This gives us a chance to read the on-disk value and convert it.  If we
> + * return -EOPNOTSUPP, then vfs_getxattr() will call the i_op handler.
> + *
> + * Note we are not called by vfs_getxattr_alloc(), but that is only called
> + * by the integrity subsystem, which really wants the unconverted values -
> + * so that's good.
> + */
> +int cap_inode_getsecurity(struct inode *inode, const char *name, void **buffer,
> +			  bool alloc)
> +{
> +	int size, ret;
> +	kuid_t kroot;
> +	uid_t root, mappedroot;
> +	char *tmpbuf = NULL;
> +	struct vfs_cap_data *cap;
> +	struct vfs_ns_cap_data *nscap;
> +	struct dentry *dentry;
> +	struct user_namespace *fs_ns;
> +
> +	if (strcmp(name, "capability") != 0)
> +		return -EOPNOTSUPP;
> +
> +	dentry = d_find_alias(inode);
> +	if (!dentry)
> +		return -EINVAL;
> +
> +	size = sizeof(struct vfs_ns_cap_data);
> +	ret = (int) vfs_getxattr_alloc(dentry, XATTR_NAME_CAPS,
> +				 &tmpbuf, size, GFP_NOFS);
> +	dput(dentry);

This looks like a good fix but ouch! That interface is wrong.

The dentry is needed because vfs_getxattr_alloc does:
	error = handler->get(handler, dentry, inode, name, NULL, 0);

Which is has no business taking a dentry as xattrs are inode concepts.

I have no issue with your patch but it looks like that handler issue
is going to need to be fixed with xattrs.

Eric
