From: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Tue, 08 Jan 2008 20:21:35 +0100
Message-ID: <E1JCK11-0003ik-4f@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu>
	 <20080108113626.895583537@szeredi.hu> <1199816786.9834.70.camel@localhost>
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1199816786.9834.70.camel@localhost> (message from Dave Hansen on
	Tue, 08 Jan 2008 10:26:26 -0800)
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> > @@ -510,10 +533,16 @@ static struct vfsmount *clone_mnt(struct
> >                                         int flag)
> >  {
> >         struct super_block *sb = old->mnt_sb;
> > -       struct vfsmount *mnt = alloc_vfsmnt(old->mnt_devname);
> > +       struct vfsmount *mnt;
> > 
> > +       if (flag & CL_SETUSER) {
> > +               int err = reserve_user_mount();
> > +               if (err)
> > +                       return ERR_PTR(err);
> > +       }
> > +       mnt = alloc_vfsmnt(old->mnt_devname);
> >         if (!mnt)
> > -               return ERR_PTR(-ENOMEM);
> > +               goto alloc_failed;
> > 
> >         mnt->mnt_flags = old->mnt_flags;
> >         atomic_inc(&sb->s_active); 
> 
> I think there's a little race here.  We could have several users racing
> to get to this point when nr_user_mounts==max_user_mounts-1.  One user
> wins the race and gets their mount reserved.  The others get the error
> out of reserve_user_mount(), and return.
> 
> But, the winner goes on to error out on some condition further down in
> clone_mnt() and never actually instantiates the mount.
> 
> Do you think this is a problem?

For similar reasons as stated in the previous mail, I don't think this
matters.  If nr_user_mounts is getting remotely close to
max_user_mounts, then something is wrong (or the max needs to be
raised anyway).

Thanks for the review, Dave!

Miklos
