From: Masami Ichikawa <masami256-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 64fa03de33: BUG:Dentry_still_in_use
Date: Mon, 8 May 2017 20:47:38 +0900
Message-ID: <CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170508044408.GA11400-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 8, 2017 at 1:44 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> From 6a3fb632f67f8425c6e76c65dad8115f1550d2a0 Mon Sep 17 00:00:00 2001
> From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Date: Sun, 7 May 2017 23:40:42 -0500
> Subject: [PATCH 1/1] cap_inode_getsecurity: don't pin dentry (fold up)
>
> This should fix the "Dentry_still_in_use" reported by the kernel
> test robot.
>
> Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> ---
>  security/commoncap.c | 27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
>
> diff --git a/security/commoncap.c b/security/commoncap.c
> index a1a2935..c970b71 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -406,21 +406,21 @@ int cap_inode_getsecurity(struct inode *inode, const char *name, void **buffer,
>                                  &tmpbuf, size, GFP_NOFS);
>
>         if (ret < 0)
> -               return ret;
> +               goto out;
>
>         fs_ns = inode->i_sb->s_user_ns;
>         cap = (struct vfs_cap_data *) tmpbuf;
>         if (is_v2header(ret, cap->magic_etc)) {
>                 /* If this is sizeof(vfs_cap_data) then we're ok with the
>                  * on-disk value, so return that.  */
> -               if (alloc)
> +               if (alloc) {
>                         *buffer = tmpbuf;
> -               else
> -                       kfree(tmpbuf);
> -               return ret;
> +                       tmpbuf = NULL;
> +               }
> +               goto out;
>         } else if (!is_v3header(ret, cap->magic_etc)) {
> -               kfree(tmpbuf);
> -               return -EINVAL;
> +               ret = -EINVAL;
> +               goto out;
>         }
>
>         nscap = (struct vfs_ns_cap_data *) tmpbuf;
> @@ -434,14 +434,14 @@ int cap_inode_getsecurity(struct inode *inode, const char *name, void **buffer,
>                 if (alloc) {
>                         *buffer = tmpbuf;
>                         nscap->rootid = cpu_to_le32(mappedroot);
> -               } else
> -                       kfree(tmpbuf);
> -               return size;
> +                       tmpbuf = NULL;
> +               }
> +               goto out;
>         }
>
>         if (!rootid_owns_currentns(kroot)) {
> -               kfree(tmpbuf);
> -               return -EOPNOTSUPP;
> +               ret = -EOPNOTSUPP;
> +               goto out;
>         }
>
>         /* This comes from a parent namespace.  Return as a v2 capability */
> @@ -459,6 +459,9 @@ int cap_inode_getsecurity(struct inode *inode, const char *name, void **buffer,
>                         cap->magic_etc = cpu_to_le32(magic);
>                 }
>         }
> +
> +out:
> +       dput(dentry);
>         kfree(tmpbuf);
>         return size;

If ret is set to some error code, e.g. -EINVAL, then jump to out
label, this function should return error code, doesn't it?

>  }
> --
> 2.7.4
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers



-- 
/**
* Masami Ichikawa
* email: masami256-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
*/
