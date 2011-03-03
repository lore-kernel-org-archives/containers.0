From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH, v7] cgroups: introduce timer slack controller
Date: Thu, 3 Mar 2011 08:34:25 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1103030829310.2701__49076.9244883724$1299137844$gmane$org@localhost6.localdomain6>
References: <1299084001-3916-1-git-send-email-kirill@shutemov.name>
	<1299084001-3916-2-git-send-email-kirill@shutemov.name>
	<alpine.LFD.2.00.1103021912090.2701@localhost6.localdomain6>
	<4D6F3C5B.8020307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6F3C5B.8020307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 3 Mar 2011, Li Zefan wrote:

> >> +unsigned long get_task_timer_slack(struct task_struct *tsk)
> >> +{
> >> +	struct cgroup_subsys_state *css;
> >> +	struct tslack_cgroup *tslack_cgroup;
> >> +	unsigned long ret;
> >> +
> >> +	rcu_read_lock();
> > 
> > Did you just remove the odd comment or actually figure out why you
> > need rcu_read_lock() here ?
> > 
> 
> It's necessary to protect against task exiting or task moving between cgroups.

I know, though after the last review I wanted to make sure, that the
author understands it as well and not just removed the odd comment
just because I ranted about it :)

Thanks,

	tglx
