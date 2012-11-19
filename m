From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 01/17] cgroup: remove incorrect dget/dput() pair in
	cgroup_create_dir()
Date: Mon, 19 Nov 2012 08:28:55 -0800
Message-ID: <20121119162855.GD15971@htj.dyndns.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-2-git-send-email-tj@kernel.org>
	<50A9E8E4.4050004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50A9E8E4.4050004-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Nov 19, 2012 at 04:08:04PM +0800, Li Zefan wrote:
> > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > index 0f8fa6a..d0803f0 100644
> > --- a/kernel/cgroup.c
> > +++ b/kernel/cgroup.c
> > @@ -2684,9 +2684,7 @@ static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
> >  		dentry->d_fsdata = cgrp;
> >  		inc_nlink(parent->d_inode);
> >  		rcu_assign_pointer(cgrp->dentry, dentry);
> > -		dget(dentry);
> >  	}
> > -	dput(dentry);
> >  
> 
> The code has been there since cgroup was merged into mainline!

I know.  Sometimes it's scary how many latent bugs we have in the
kernel and how long many of them have been around.  At other times,
it's comforting.  I mean, there's a pretty good chance that other
people don't notice my screw ups, right?  :P

-- 
tejun
