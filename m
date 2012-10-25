From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroup: cgroup_subsys->fork() should be called
	after the task is added to css_set
Date: Thu, 25 Oct 2012 19:42:33 +0200
Message-ID: <20121025174233.GC7650@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-2-git-send-email-tj@kernel.org>
	<20121021191141.GA26218@redhat.com>
	<20121021192222.GB5951@atj.dyndns.org>
	<20121022180445.GB21553@redhat.com>
	<20121022211631.GE5951@atj.dyndns.org>
	<20121023155128.GB16201@redhat.com>
	<20121024190458.GB12182@atj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121024190458.GB12182-OlzNCW9NnSVy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/24, Tejun Heo wrote:
>
> Hello,
>
> On Tue, Oct 23, 2012 at 05:51:28PM +0200, Oleg Nesterov wrote:
> > Yes, yes. But in this case (I mean, for uprobes) "threadgroup" in the name
> > is misleading. It should be called unconditially without any argument.
> >
> > Please see
> >
> > 	[PATCH 1/2] brw_mutex: big read-write mutex
> > 	http://marc.info/?l=linux-kernel&m=135032816223715
>
> Ooh... that's something completely different.
>
> > 	[PATCH 2/2] uprobes: Use brw_mutex to fix register/unregister vs dup_mmap() race
> > 	http://marc.info/?l=linux-kernel&m=135032817823720
> >
> > for details, but in short 2/2 needs this giant lock to block dup_mmap()
> > system-wide, while cgroup (currently) only needs threadgroup lock if
> > CLONE_THREAD (ignoring do_exit) and per-task.
> >
> > So please forget, I no longer think it makes sense to use the same
> > thing for uprobes and cgroups.
>
> It is quite tempting to reduce hot path overhead and penalize cgroup
> migration ops more tho.  Write-locking brw_mutex on migration might
> not be too bad.  Why did you change your mind?

Well, mostly because I do not think 1/2 will be ever applied ;)

Since we already have (to my surprise!) percpu_rw_semaphore, I do
not think I can add another similar lock.

Perhaps uprobes can use percpu_rw_semaphore, but I am not sure...

Oleg.
