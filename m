From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/7] vfs: Fix shrink_submounts
Date: Thu, 6 Nov 2008 17:22:21 -0800
Message-ID: <20081106172221.dbeb5b12.akpm@linux-foundation.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754865AbYKGBXV@vger.kernel.org>
In-Reply-To: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 06 Nov 2008 02:38:49 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> In the last refactoring of shrink_submounts a variable was
> not completely renamed.  So finish the renaming of mnt to m
> now.
> 
> Without this if you attempt to mount an nfs mount that has
> both automatic nfs sub mounts on it, and has normal mounts
> on it.  The unmount will succeed when it should not.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  fs/namespace.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index cce4670..65b3dc8 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1815,8 +1815,8 @@ static void shrink_submounts(struct vfsmount *mnt, struct list_head *umounts)
>  		while (!list_empty(&graveyard)) {
>  			m = list_first_entry(&graveyard, struct vfsmount,
>  						mnt_expire);
> -			touch_mnt_namespace(mnt->mnt_ns);
> -			umount_tree(mnt, 1, umounts);
> +			touch_mnt_namespace(m->mnt_ns);
> +			umount_tree(m, 1, umounts);
>  		}
>  	}
>  }

OK, so that's a for-2.6.28 bugfix, yes?

The other six patches will fall under Alexey's procfs tree.
