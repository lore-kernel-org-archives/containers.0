From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into devpts
Date: Wed, 4 Feb 2009 17:49:05 -0600
Message-ID: <20090204234905.GB17354@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com>
	<20090204043640.GA26202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090204043640.GA26202-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 27 Jan 2009 22:58:18 -0800
> Subject: [v2][PATCH 1/5] Unroll essentials of do_remount_sb() into devpts
> 
> On remount, devpts fs only needs to parse the mount options. Users cannot
> directly create/dirty files in /dev/pts so the MS_RDONLY flag and
> shrinking the dcache does not really apply to devpts.
> 
> So effectively on remount, devpts only parses the mount options and updates
> these options in its super block. As such, we could replace do_remount_sb()
> call with a direct parse_mount_options().
> 
> Doing so enables subsequent patches to avoid parsing the mount options twice
> and simplify the code.

You've dropped the update_ptmx_mode() which you used to do
inside devpts_remount().  Is that also on purpose?

> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  fs/devpts/inode.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index ad186b4..de15e73 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -442,6 +442,8 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
>  		void *data, struct vfsmount *mnt)
>  {
>  	struct super_block *s;
> +	struct pts_mount_opts *opts;
> +	struct pts_fs_info *fsi;
>  	int error;
> 
>  	s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
> @@ -458,7 +460,10 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
>  		}
>  		s->s_flags |= MS_ACTIVE;
>  	}
> -	do_remount_sb(s, flags, data, 0);
> +	fsi = DEVPTS_SB(s);
> +	opts = &fsi->mount_opts;
> +	parse_mount_options(data, PARSE_REMOUNT, opts);
> +
>  	simple_set_mnt(mnt, s);
>  	return 0;
>  }
> -- 
> 1.5.2.5
