From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 6/7] bio-cgroup: Implement the bio-cgroup
Date: Fri, 08 Aug 2008 17:30:45 +0900 (JST)
Message-ID: <20080808.173045.112614776.ryov__29071.5877119966$1218184462$gmane$org@valinux.co.jp>
References: <20080804.175934.112619046.ryov@valinux.co.jp>
	<20080804.180022.183027902.ryov@valinux.co.jp>
	<489BF14D.6050009@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489BF14D.6050009-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Yoshikawa-san,

> > +static void bio_cgroup_move_task(struct cgroup_subsys *ss,
> > +				struct cgroup *cont,
> > +				struct cgroup *old_cont,
> > +				struct task_struct *p)
> > +{
> > +	struct mm_struct *mm;
> > +	struct bio_cgroup *biog, *old_biog;
> > +
> > +	if (bio_cgroup_disabled())
> > +		return;
> > +
> > +	mm = get_task_mm(p);
> > +	if (mm == NULL)
> > +		return;
> > +
> > +	biog = cgroup_bio(cont);
> > +	old_biog = cgroup_bio(old_cont);
> > +
> > +	mmput(mm);
> > +	return;
> > +}
> 
> Is this function fully implemented?

This function can be more simplified, there is some unnecessary code 
from old version.

> I tried to put a process into a group by writing to
> "/cgroup/bio/BGROUP/tasks" but failed.

Could you tell me what you actually did? I will try the same thing.

--
Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
