From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/8] cgroup: mount cgroupns-root when inside non-init
	cgroupns
Date: Wed, 25 Nov 2015 00:01:56 -0600
Message-ID: <20151125060156.GA678__12893.8432703309$1448431338$gmane$org@mail.hallyn.com>
References: <1447703505-29672-1-git-send-email-serge@hallyn.com>
	<1447703505-29672-8-git-send-email-serge@hallyn.com>
	<20151124171610.GS17033@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151124171610.GS17033-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 24, 2015 at 12:16:10PM -0500, Tejun Heo wrote:
...
> > +		if (ns != &init_cgroup_ns) {
> > +			struct dentry *nsdentry;
> > +			struct cgroup *cgrp;
> > +
> > +			cgrp = cset_cgroup_from_root(ns->root_cgrps, root);
> > +			nsdentry = kernfs_obtain_root(dentry->d_sb,
> > +				cgrp->kn);
> > +			dput(dentry);
> > +			dentry = nsdentry;
> > +		}
> > +	}
> 
> So, this would effectively allow namespace mounts to claim controllers
> which aren't configured otherwise which doesn't seem like a good idea.
> I think the right thing to do for namespace mounts is to always
> require an existing superblock.

that was my goal with https://git.kernel.org/cgit/linux/kernel/git/sergeh/linux-security.git/commit/?h=cgroupns.v4&id=8eb75d2bb24df59e262f050dce567d2332adc5f3
(which was sent inline earlier in this thread in response to Eric)  Does
that look sufficient?

thanks,
-serge
