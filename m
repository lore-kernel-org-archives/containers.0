From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [REVIEW][PATCH 3/4] vfs: Add a function to lazily unmount all
	mounts from any dentry. v3
Date: Tue, 22 Oct 2013 19:08:25 +0000
Message-ID: <20131022190825.GC10600@mail.hallyn.com>
References: <CALCETrWw=htmgxqq=RQztdJQ-a8c3860vmJh9Ni=Hhs0TkO3YA@mail.gmail.com>
	<20131008161135.GK14242@tucsk.piliscsaba.szeredi.hu>
	<87li23trll.fsf@tw-ebiederman.twitter.com>
	<CAJfpegv+h7xh_2e-X7is9dq1Fp06A0eKwsyWFMPX=azbbDCX5Q@mail.gmail.com>
	<87vc15mjuw.fsf@xmission.com>
	<CAJfpegvF89LzAvNB0h0otv7sKoS3rewZzQKAauQx3P+rCkCcSg@mail.gmail.com>
	<87iox38fkv.fsf@xmission.com> <87d2nb8dxy.fsf@xmission.com>
	<87iowyxpci.fsf_-_@xmission.com> <871u3mxp8s.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <871u3mxp8s.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Linux-Fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthias Schniedermeyer <ms-QGhoYOTWWTg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> v2: Always drop the lock when exiting early.
> v3: Make detach_mounts robust about freeing several
>     mounts on the same mountpoint at one time, and remove
>     the unneeded mnt_list list test.
> 
> Signed-off-by: Eric W. Biederman <ebiederman-1v8oiQdgUNlBDgjK7y7TUQ@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  fs/mount.h     |    1 +
>  fs/namespace.c |   24 ++++++++++++++++++++++++
>  2 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/mount.h b/fs/mount.h
> index e4342b8dfab1..7a6a2bb3f290 100644
> --- a/fs/mount.h
> +++ b/fs/mount.h
> @@ -79,6 +79,7 @@ static inline int is_mounted(struct vfsmount *mnt)
>  }
>  
>  extern struct mount *__lookup_mnt(struct vfsmount *, struct dentry *, int);
> +extern void detach_mounts(struct dentry *dentry);
>  
>  static inline void get_mnt_ns(struct mnt_namespace *ns)
>  {
> diff --git a/fs/namespace.c b/fs/namespace.c
> index e4fe22c23e00..78f7c5c9e673 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1295,6 +1295,30 @@ static int do_umount(struct mount *mnt, int flags)
>  	return retval;
>  }
>  
> +void detach_mounts(struct dentry *dentry)
> +{
> +	struct mountpoint *mp;
> +	struct mount *mnt;
> +
> +	namespace_lock();
> +	if (!d_mountpoint(dentry))
> +		goto out_unlock;
> +
> +	mp = new_mountpoint(dentry);
> +	if (IS_ERR(mp))
> +		goto out_unlock;
> +
> +	br_write_lock(&vfsmount_lock);
> +	while (!list_empty(&mp->m_list)) {
> +		mnt = list_first_entry(&mp->m_list, struct mount, mnt_mp_list);
> +		umount_tree(mnt, 1);
> +	}
> +	br_write_unlock(&vfsmount_lock);
> +	put_mountpoint(mp);
> +out_unlock:
> +	namespace_unlock();
> +}
> +
>  /* 
>   * Is the caller allowed to modify his namespace?
>   */
> -- 
> 1.7.5.4
