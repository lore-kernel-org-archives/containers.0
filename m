From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup : remove the ns_cgroup
Date: Thu, 29 Jul 2010 17:39:57 -0500
Message-ID: <20100729223957.GA12387__12986.9320233867$1280443355$gmane$org@hallyn.com>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
	<20100729214008.GA2785@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100729214008.GA2785-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Thu, Jul 29, 2010 at 02:58:12PM -0500, Serge E. Hallyn wrote:
> > The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier.
> > 
> > For example, a single process can not handle a big amount of namespaces
> > without interacting with this cgroup and falling in an exponential creation
> > time due to the nested cgroup directory depth (eg. /cgroup/<pid>/.../<pid>/...).
> > 
> > That was spotted when creating a single process using multiple network namespaces,
> > the objective was 4096 network namespaces, but at 820 netns, the creation time
> > was dramatically slow and the creation time for a namespace increased from 10msec
> > to 10sec. After five hours, the expected numbers of netns was not reached.
> > Without the ns_cgroup interaction, 4K netns are created after 2 minutes.
> 
> Is this problem related to Andrew's post here re:
> 
> [Bugme-new] [Bug 16417] New: Slow context switches with SMP and CONFIG_FAIR_GROUP_SCHED

Hm, I don't think so (though it should be trivial to test :).  The
situation Daniel (the real patch and intro author) cites is I believe
mainly due to the time spent traversing very deep paths.  Whereas
Pierre doesn't seem to be even unsharing at all.  Rather he's just
creating cgroups with mkdir.

Still I could be wrong.

BTW in the past the only reason I saw for keeping ns cgroup was
to lock tasks into a devices cgroup.  Until that lazy guy who was
going to do it gets off his butt and implements user namespaces,
you'll just have to use LSMs, which is the right way.

-serge
