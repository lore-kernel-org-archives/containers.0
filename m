From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 04/11] cgroup: use kzalloc() and list_del_init()
Date: Wed, 12 Jun 2013 19:56:23 -0700
Message-ID: <20130613025623.GB7432@mtj.dyndns.org>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
	<1371070996-20613-5-git-send-email-tj@kernel.org>
	<51B93038.9010202@huawei.com> <20130613023831.GB10979@localhost>
	<CAOS58YPv_uKeTqZSNF=sXTEnLn=LTbsdpBPM5K_ykXoVT-+CpA@mail.gmail.com>
	<20130613024310.GC10979@localhost>
	<20130613024859.GA7432@mtj.dyndns.org>
	<20130613025202.GD10979@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130613025202.GD10979@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jun 12, 2013 at 07:52:02PM -0700, Kent Overstreet wrote:
> On Wed, Jun 12, 2013 at 07:48:59PM -0700, Tejun Heo wrote:
> > On Wed, Jun 12, 2013 at 07:43:10PM -0700, Kent Overstreet wrote:
> > > list_del() does do poisoning - and list debugging is cheaper to enable
> > > than full slab debugging.
> > 
> > Ah, right, now we have DEBUG_LIST.  Completely forgot about that.  I
> > don't think the cost difference matters that much as long as there are
> > enough people running with slab debugging, but, yeah, with DEBUG_LIST,
> > leaving list_del() alone would actually be better.  I'll drop that
> > part.
> 
> I can't remember if it was Fedora or RH (or both?) but in one of those
> they actually leave it enabled in their production kernels. Someone was
> blogging about the bugs it found...

And we poison regardless of DEBUG_LIST and looks like have been doing
that forever.  I have no idea why I was thinking list_del() didn't
poison.  Maybe it was something which got stuck in my brain from
before the git history or I'm just hallucinating.  Anyways, yeap,
list_del() is better.

Thanks.

-- 
tejun
