From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Tue, 08 Jan 2008 10:26:26 -0800
Message-ID: <1199816786.9834.70.camel@localhost>
References: <20080108113502.184459371@szeredi.hu>
	 <20080108113626.895583537@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080108113626.895583537@szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 2008-01-08 at 12:35 +0100, Miklos Szeredi wrote:
> @@ -510,10 +533,16 @@ static struct vfsmount *clone_mnt(struct
>                                         int flag)
>  {
>         struct super_block *sb = old->mnt_sb;
> -       struct vfsmount *mnt = alloc_vfsmnt(old->mnt_devname);
> +       struct vfsmount *mnt;
> 
> +       if (flag & CL_SETUSER) {
> +               int err = reserve_user_mount();
> +               if (err)
> +                       return ERR_PTR(err);
> +       }
> +       mnt = alloc_vfsmnt(old->mnt_devname);
>         if (!mnt)
> -               return ERR_PTR(-ENOMEM);
> +               goto alloc_failed;
> 
>         mnt->mnt_flags = old->mnt_flags;
>         atomic_inc(&sb->s_active); 

I think there's a little race here.  We could have several users racing
to get to this point when nr_user_mounts==max_user_mounts-1.  One user
wins the race and gets their mount reserved.  The others get the error
out of reserve_user_mount(), and return.

But, the winner goes on to error out on some condition further down in
clone_mnt() and never actually instantiates the mount.

Do you think this is a problem?

I think just about the one solution is to block new mounters on a
sleepable lock until the race winner actually finishes their mount
operation.  

-- Dave

