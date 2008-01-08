From: Szabolcs Szakacsits <szaka-IyvsvuGDJ8VAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Tue, 8 Jan 2008 22:44:20 +0200 (MET DST)
Message-ID: <Pine.LNX.4.61.0801082227050.4441@dhcppc1>
References: <20080108113502.184459371@szeredi.hu>
	<20080108113626.895583537@szeredi.hu>
	<1199815958.9834.58.camel@localhost>
	<E1JCJoQ-0003g9-Nk@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <E1JCJoQ-0003g9-Nk-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


On Tue, 8 Jan 2008, Miklos Szeredi wrote:
> > On Tue, 2008-01-08 at 12:35 +0100, Miklos Szeredi wrote:
> > > +static int reserve_user_mount(void)
> > > +{
> > > +       int err = 0;
> > > +
> > > +       spin_lock(&vfsmount_lock);
> > > +       if (nr_user_mounts >= max_user_mounts && !capable(CAP_SYS_ADMIN))
> > > +               err = -EPERM;
> > > +       else
> > > +               nr_user_mounts++;
> > > +       spin_unlock(&vfsmount_lock);
> > > +       return err;
> > > +} 
> > 
> > Would -ENOSPC or -ENOMEM be a more descriptive error here?  
> 
> The logic behind EPERM, is that this failure is only for unprivileged
> callers.  ENOMEM is too specifically about OOM.  It could be changed
> to ENOSPC, ENFILE, EMFILE, or it could remain EPERM.  What do others
> think?

I think it would be important to log the non-trivial errors. Several 
mount(8) hints to check for the reason by dmesg since it's already too 
challanging to figure out what's exactly the problem by the errno value. 
This could also prevent to mislead troubleshooters with the mount/sysctl 
race.

	Szaka

-- 
NTFS-3G:  http://ntfs-3g.org
