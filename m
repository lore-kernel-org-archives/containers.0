From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v4 0/2] cgroups: implement moving a threadgroup's
	threads atomically with cgroup.procs
Date: Wed, 4 Aug 2010 08:45:23 +0900
Message-ID: <20100804084523.768cd353.kamezawa.hiroyu__15465.5984290459$1280879691$gmane$org@jp.fujitsu.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100803125827.0822e6ab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100803125827.0822e6ab.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 3 Aug 2010 12:58:27 -0700
Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Fri, 30 Jul 2010 19:56:49 -0400
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> 
> > This patch series implements a write function for the 'cgroup.procs'
> > per-cgroup file, which enables atomic movement of multithreaded
> > applications between cgroups. Writing the thread-ID of any thread in a
> > threadgroup to a cgroup's procs file causes all threads in the group to
> > be moved to that cgroup safely with respect to threads forking/exiting.
> > (Possible usage scenario: If running a multithreaded build system that
> > sucks up system resources, this lets you restrict it all at once into a
> > new cgroup to keep it under control.)
> 
> I can see how that would be useful.  No comments from anyone else?
> 

I think the feature itself is good and useful. I welcome this.

> patch 1/2 makes me cry with all those ifdefs.  Maybe helper functions
> would help, but not a lot.
> 
Add static inline functions ?


> patch 2/2 looks very complicated.

yes. that's a concern.
I'd like to look deeper, today.

Thanks,
-Kame
