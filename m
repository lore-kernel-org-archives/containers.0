From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Thu, 26 Mar 2015 12:29:31 -0700
Message-ID: <CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA__43965.2389650748$1427398235$gmane$org@mail.gmail.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Ping?  It's been over a month.

On Fri, Feb 20, 2015 at 5:04 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> It's currently impossible to mount devpts in a user namespace that
> has no root user, since ptmx can't be created.  This adds options
> ptmx_uid and ptmx_gid that override the default uid and gid of 0.
>
> These options are not shown in mountinfo because they have no effect
> other than changing the initial mode of ptmx, and, in particular, it
> wouldn't make any sense to change them on remount.  Instead, we
> disallow them on remount.
>
> This could be changed, but we'd probably want to fix the userns
> behavior of uid and gid at the same time if we did so.
>
> Signed-off-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> ---
>  Documentation/filesystems/devpts.txt |  4 +++
>  fs/devpts/inode.c                    | 58 ++++++++++++++++++++++++++----------
>  2 files changed, 46 insertions(+), 16 deletions(-)
>
> diff --git a/Documentation/filesystems/devpts.txt b/Documentation/filesystems/devpts.txt
> index 68dffd87f9b7..7808e77d0d72 100644
> --- a/Documentation/filesystems/devpts.txt
> +++ b/Documentation/filesystems/devpts.txt
> @@ -121,6 +121,10 @@ once), following user-space issues should be noted.
>
>         chmod 666 /dev/pts/ptmx
>
> +   The ownership for /dev/pts/ptmx can be specified using the ptmxuid
> +   and ptmxgid options.  Both default to zero, which, in user namespaces
> +   that have no root user, will cause mounting to fail.
> +
>  7. A mount of devpts without the 'newinstance' option results in binding to
>     initial kernel mount.  This behavior while preserving legacy semantics,
>     does not provide strict isolation in a container environment. i.e by
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index cfe8466f7fef..b60d1438c660 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -102,6 +102,8 @@ struct pts_mount_opts {
>         int setgid;
>         kuid_t   uid;
>         kgid_t   gid;
> +       uid_t ptmx_uid;
> +       gid_t ptmx_gid;
>         umode_t mode;
>         umode_t ptmxmode;
>         int newinstance;
> @@ -109,8 +111,8 @@ struct pts_mount_opts {
>  };
>
>  enum {
> -       Opt_uid, Opt_gid, Opt_mode, Opt_ptmxmode, Opt_newinstance,  Opt_max,
> -       Opt_err
> +       Opt_uid, Opt_gid, Opt_ptmx_uid, Opt_ptmx_gid, Opt_mode, Opt_ptmxmode,
> +       Opt_newinstance,  Opt_max, Opt_err,
>  };
>
>  static const match_table_t tokens = {
> @@ -118,6 +120,8 @@ static const match_table_t tokens = {
>         {Opt_gid, "gid=%u"},
>         {Opt_mode, "mode=%o"},
>  #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
> +       {Opt_ptmx_uid, "ptmxuid=%u"},
> +       {Opt_ptmx_gid, "ptmxgid=%u"},
>         {Opt_ptmxmode, "ptmxmode=%o"},
>         {Opt_newinstance, "newinstance"},
>         {Opt_max, "max=%d"},
> @@ -162,14 +166,17 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
>         char *p;
>         kuid_t uid;
>         kgid_t gid;
> -
> -       opts->setuid  = 0;
> -       opts->setgid  = 0;
> -       opts->uid     = GLOBAL_ROOT_UID;
> -       opts->gid     = GLOBAL_ROOT_GID;
> -       opts->mode    = DEVPTS_DEFAULT_MODE;
> +       bool setptmxid = false;
> +
> +       opts->setuid   = 0;
> +       opts->setgid   = 0;
> +       opts->uid      = GLOBAL_ROOT_UID;
> +       opts->gid      = GLOBAL_ROOT_GID;
> +       opts->ptmx_uid = 0;
> +       opts->ptmx_gid = 0;
> +       opts->mode     = DEVPTS_DEFAULT_MODE;
>         opts->ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
> -       opts->max     = NR_UNIX98_PTY_MAX;
> +       opts->max      = NR_UNIX98_PTY_MAX;
>
>         /* newinstance makes sense only on initial mount */
>         if (op == PARSE_MOUNT)
> @@ -209,6 +216,22 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
>                         opts->mode = option & S_IALLUGO;
>                         break;
>  #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
> +               case Opt_ptmx_uid:
> +                       if (match_int(&args[0], &option))
> +                               return -EINVAL;
> +                       if (op != PARSE_MOUNT)
> +                               return -EINVAL;
> +                       opts->ptmx_uid = option;
> +                       setptmxid = true;
> +                       break;
> +               case Opt_ptmx_gid:
> +                       if (match_int(&args[0], &option))
> +                               return -EINVAL;
> +                       if (op != PARSE_MOUNT)
> +                               return -EINVAL;
> +                       opts->ptmx_gid = option;
> +                       setptmxid = true;
> +                       break;
>                 case Opt_ptmxmode:
>                         if (match_octal(&args[0], &option))
>                                 return -EINVAL;
> @@ -232,6 +255,9 @@ static int parse_mount_options(char *data, int op, struct pts_mount_opts *opts)
>                 }
>         }
>
> +       if (setptmxid && !opts->newinstance)
> +               return -EINVAL;
> +
>         return 0;
>  }
>
> @@ -245,12 +271,12 @@ static int mknod_ptmx(struct super_block *sb)
>         struct dentry *root = sb->s_root;
>         struct pts_fs_info *fsi = DEVPTS_SB(sb);
>         struct pts_mount_opts *opts = &fsi->mount_opts;
> -       kuid_t root_uid;
> -       kgid_t root_gid;
> +       kuid_t ptmx_uid;
> +       kgid_t ptmx_gid;
>
> -       root_uid = make_kuid(current_user_ns(), 0);
> -       root_gid = make_kgid(current_user_ns(), 0);
> -       if (!uid_valid(root_uid) || !gid_valid(root_gid))
> +       ptmx_uid = make_kuid(current_user_ns(), opts->ptmx_uid);
> +       ptmx_gid = make_kgid(current_user_ns(), opts->ptmx_gid);
> +       if (!uid_valid(ptmx_uid) || !gid_valid(ptmx_gid))
>                 return -EINVAL;
>
>         mutex_lock(&root->d_inode->i_mutex);
> @@ -282,8 +308,8 @@ static int mknod_ptmx(struct super_block *sb)
>
>         mode = S_IFCHR|opts->ptmxmode;
>         init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
> -       inode->i_uid = root_uid;
> -       inode->i_gid = root_gid;
> +       inode->i_uid = ptmx_uid;
> +       inode->i_gid = ptmx_gid;
>
>         d_add(dentry, inode);
>
> --
> 2.3.0
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
