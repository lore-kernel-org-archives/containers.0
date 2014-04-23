From: Dwight Engen <dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
	kmem limit doesn't recover after disk i/o causes limit to be hit]
Date: Wed, 23 Apr 2014 08:49:42 -0400
Message-ID: <20140423084942.560ae837__20174.061766784$1398257436$gmane$org@oracle.com>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
	<20140422143943.20609800@oracle.com>
	<20140422200531.GA19334@alpha.arachsys.com>
	<535758A0.5000500@yuhu.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <535758A0.5000500-NV7Lj0SOnH0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org>
Cc: Richard Davies <richard-li8END47hbdWk0Htik3J/w@public.gmane.org>, Vladimir Davydov <vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, William Dauchy <wdauchy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 23 Apr 2014 09:07:28 +0300
Marian Marinov <mm-NV7Lj0SOnH0@public.gmane.org> wrote:

> On 04/22/2014 11:05 PM, Richard Davies wrote:
> > Dwight Engen wrote:
> >> Richard Davies wrote:
> >>> Vladimir Davydov wrote:
> >>>> In short, kmem limiting for memory cgroups is currently broken.
> >>>> Do not use it. We are working on making it usable though.
> > ...
> >>> What is the best mechanism available today, until kmem limits
> >>> mature?
> >>>
> >>> RLIMIT_NPROC exists but is per-user, not per-container.
> >>>
> >>> Perhaps there is an up-to-date task counter patchset or similar?
> >>
> >> I updated Frederic's task counter patches and included Max
> >> Kellermann's fork limiter here:
> >>
> >> http://thread.gmane.org/gmane.linux.kernel.containers/27212
> >>
> >> I can send you a more recent patchset (against 3.13.10) if you
> >> would find it useful.
> >
> > Yes please, I would be interested in that. Ideally even against
> > 3.14.1 if you have that too.
> 
> Dwight, do you have these patches in any public repo?
> 
> I would like to test them also.

Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:

git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
 
> Marian
> 
> >
> > Thanks,
> >
> > Richard.
> > --
> > To unsubscribe from this list: send the line "unsubscribe cgroups"
> > in the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> 
