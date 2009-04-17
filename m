From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Fri, 17 Apr 2009 11:55:56 +0200
Message-ID: <20090417095555.GD8689__48563.5394616567$1239962792$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417102417.88a0ef93.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417102417.88a0ef93.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 10:24:17AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 14 Apr 2009 22:21:12 +0200
> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > +Example:
> > +* Create an association between an io-throttle group and a bio-cgroup group
> > +  with "bio" and "blockio" subsystems mounted in different mount points:
> > +  # mount -t cgroup -o bio bio-cgroup /mnt/bio-cgroup/
> > +  # cd /mnt/bio-cgroup/
> > +  # mkdir bio-grp
> > +  # cat bio-grp/bio.id
> > +  1
> > +  # mount -t cgroup -o blockio blockio /mnt/io-throttle
> > +  # cd /mnt/io-throttle
> > +  # mkdir foo
> > +  # echo 1 > foo/blockio.bio_id
> 
> Why do we need multiple cgroups at once to track I/O ?
> Seems complicated to me.
> 
> Thanks,
> -Kame

I totally agree. I could easily merge the bio-cgroup functionality in
io-throttle or implement this as an infrastructure framework, using a
single controller and remove this complication.

For now, since the decisions on IO controllers are not definitive at
all, I privileged flexibility and I simply decided to be a plain user of
bio-cgroup to quickly adapt my patch to the future bio-cgroup
development.

Thanks,
-Andrea
