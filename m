From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Wed, 9 Dec 2009 00:50:16 -0500
Message-ID: <20091209055016.GA12342__8502.68990402601$1260338005$gmane$org@andrew.cmu.edu>
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

Unless I'm gravely mistaken, you can't have deadlock on an rwsem when
it's being taken for reading in both cases? You would have to have at
least one of the cases being down_write.

In fairness to readability, perhaps subsys_mutex should instead be
subsys_rwsem? It seemed to me to be that calling it "mutex" was
conventional anyway.

-- bblum
