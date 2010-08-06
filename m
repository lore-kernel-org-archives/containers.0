From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v4 1/2] cgroups: read-write lock CLONE_THREAD forking
	per threadgroup
Date: Fri, 6 Aug 2010 16:08:27 +0900
Message-ID: <20100806160827.d73ae050.kamezawa.hiroyu__17880.3648370833$1281078964$gmane$org@jp.fujitsu.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100730235754.GB22644@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikpNG2Y3S3AyxAbCkMynKu1u5yKPrw=bh+uy=9R@mail.gmail.com>
	<20100804043328.GB11950@ghc17.ghc.andrew.cmu.edu>
	<AANLkTi=dhym3c+XJVjoObROcw=mz2Y+a2R5oMdePK3Ng@mail.gmail.com>
	<20100806060224.GA1351@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100806060224.GA1351-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 6 Aug 2010 02:02:24 -0400
Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Tue, Aug 03, 2010 at 09:34:22PM -0700, Paul Menage wrote:
> > On Tue, Aug 3, 2010 at 9:33 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > >> As far as the #ifdef mess goes, it's true that some people don't have
> > >> CONFIG_CGROUPS defined. I'd imagine that these are likely to be
> > >> embedded systems with a fairly small number of processes and threads
> > >> per process. Are there really any such platforms where the cost of a
> > >> single extra rwsem per process is going to make a difference either in
> > >> terms of memory or lock contention? I think you should consider making
> > >> these additions unconditional.
> > >
> > > That's certainly an option, but I think it would be clean enough to put
> > > static inline functions just under the signal_struct definition.
> > 
> > Either sounds fine to me. I suspect others have a stronger opinion.
> > 
> > Paul
> > 
> 
> Any other votes? One set of static inline functions (I'd call them
> threadgroup_fork_{read,write}_{un,}lock) or just remove the ifdefs
> entirely? I'm inclined to go with the former.
> 

I vote for the former. #ifdef can be easily removed if someone finds it useful
for other purpose...and static inline function is usual way.

Thanks,
-Kame
