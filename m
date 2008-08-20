From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 4/7] bio-cgroup: Split the cgroup memory subsystem into
	two parts
Date: Wed, 20 Aug 2008 14:47:36 +0900 (JST)
Message-ID: <20080820.144736.16128062.taka__46060.4396452711$1219211383$gmane$org@valinux.co.jp>
References: <48AA4594.1000908@linux.vnet.ibm.com>
	<20080819.214635.70071441.taka@valinux.co.jp>
	<48AACF41.5090905@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AACF41.5090905-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> >>>> I'm now writing remove-lock-page-cgroup patches. it works well.
> >>>> please wait for a while...
> >>> I'm looking forward to those patches.
> >>>
> >>> By the way, I'm glad if memory-cgroup has a feature which can make a
> >>> page_cgroup move between cgroups with small overhead. It makes
> >>> bio-cgroup improve the accuracy of tracking down pages.
> >> Page movement can be a very expensive operation and is proportional to the size
> >> of the control group. I think movement should be an optional feature, if we ever
> >> add it.
> > 
> > Yes, we should avoid moving pages as far as it is balanced fairly well
> > between groups.
> > 
> > But I want to move pages between bio-cgoups in case it started charging
> > quite a few I/O requests to a wrong bio-cgroup. I think it will be okay
> > if pages moves between bio-cgroups, but they don't need to move between
> > memory cgroups. I know the latter is really heavy and the effect seems
> > to be so limited.
> 
> I was under the impression that you wanted memory-cgroup to provide the page
> movement feature. That is not on the TODO list for us now.

I think it's practically enough to implement this feature only on
bio-cgroup side and leave the memory controller untouched.
This kind of requests will happen only when making pages dirty.

Of cousrse I'd be happier if you put it on your list to implement
this as a generic feature.

Thanks,
Hirokazu Takahsahi.
