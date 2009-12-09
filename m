From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Wed, 9 Dec 2009 03:36:56 -0500
Message-ID: <20091209083656.GB14114__7957.47758024863$1260347868$gmane$org@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085508.GA18912@andrew.cmu.edu>
	<4B1E0283.70108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B1E0283.70108-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 08, 2009 at 03:38:43PM +0800, Li Zefan wrote:
> > @@ -1291,6 +1324,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
> >  	struct cgroupfs_root *new_root;
> >  
> >  	/* First find the desired set of subsystems */
> > +	down_read(&subsys_mutex);
> 
> Hmm.. this can lead to deadlock. sget() returns success with sb->s_umount
> held, so here we have:
> 
> 	down_read(&subsys_mutex);
> 
> 	down_write(&sb->s_umount);
> 
> On the other hand, sb->s_umount is held before calling kill_sb(),
> so when umounting we have:
> 
> 	down_write(&sb->s_umount);
> 
> 	down_read(&subsys_mutex);
> 
> >  	ret = parse_cgroupfs_options(data, &opts);
> >  	if (ret)
> >  		goto out_err;
> > @@ -1367,6 +1401,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
> >  			free_cg_links(&tmp_cg_links);
> >  			goto drop_new_super;
> >  		}
> > +		/* done with subsys stuff and no other failure case */
> > +		up_read(&subsys_mutex);
> >  
> >  		/* EBUSY should be the only error here */
> >  		BUG_ON(ret);
> > @@ -1415,6 +1451,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
> >   drop_new_super:
> >  	deactivate_locked_super(sb);
> >   out_err:
> > +	up_read(&subsys_mutex);
> >  	kfree(opts.release_agent);
> >  	kfree(opts.name);

There's another problem here. deactivate_locked_super() calls kill_sb(),
which tries to down_read(&subsys_mutex), and rwsems can't recurse. This
can be fixed by just moving the up_read(&subsys_mutex); at the end to
before each 'goto' in each error case, though, so not a big deal.

-- bblum
