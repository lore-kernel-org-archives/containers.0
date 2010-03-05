From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 2/4] page_cgroup: introduce file cache flags
Date: Fri, 5 Mar 2010 23:35:20 +0100
Message-ID: <20100305223519.GC1578__45321.3657871403$1267828561$gmane$org@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-3-git-send-email-arighi@develer.com>
	<20100305063249.GH3073@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305063249.GH3073-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 05, 2010 at 12:02:49PM +0530, Balbir Singh wrote:
> * Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> [2010-03-04 11:40:13]:
> 
> > Introduce page_cgroup flags to keep track of file cache pages.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > ---
> 
> Looks good
> 
> 
> Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>  
> 
> >  include/linux/page_cgroup.h |   49 +++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 49 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index 30b0813..1b79ded 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -39,6 +39,12 @@ enum {
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> >  	PCG_ACCT_LRU, /* page has been accounted for */
> > +	PCG_MIGRATE_LOCK, /* used for mutual execution of account migration */
> > +	PCG_ACCT_FILE_MAPPED, /* page is accounted as file rss*/
> > +	PCG_ACCT_DIRTY, /* page is dirty */
> > +	PCG_ACCT_WRITEBACK, /* page is being written back to disk */
> > +	PCG_ACCT_WRITEBACK_TEMP, /* page is used as temporary buffer for FUSE */
> > +	PCG_ACCT_UNSTABLE_NFS, /* NFS page not yet committed to the server */
> >  };
> > 
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -73,6 +79,27 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
> > 
> > +/* File cache and dirty memory flags */
> > +TESTPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +SETPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +CLEARPCGFLAG(FileMapped, ACCT_FILE_MAPPED)
> > +
> > +TESTPCGFLAG(Dirty, ACCT_DIRTY)
> > +SETPCGFLAG(Dirty, ACCT_DIRTY)
> > +CLEARPCGFLAG(Dirty, ACCT_DIRTY)
> > +
> > +TESTPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +SETPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +CLEARPCGFLAG(Writeback, ACCT_WRITEBACK)
> > +
> > +TESTPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +SETPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +CLEARPCGFLAG(WritebackTemp, ACCT_WRITEBACK_TEMP)
> > +
> > +TESTPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +SETPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +CLEARPCGFLAG(UnstableNFS, ACCT_UNSTABLE_NFS)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > @@ -83,6 +110,9 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
> >  	return page_zonenum(pc->page);
> >  }
> > 
> > +/*
> > + * lock_page_cgroup() should not be held under mapping->tree_lock
> > + */
> 
> May be a DEBUG WARN_ON would be appropriate here?

Sounds good. WARN_ON_ONCE()?

Thanks,
-Andrea
