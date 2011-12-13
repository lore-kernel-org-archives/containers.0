From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v6
Date: Tue, 13 Dec 2011 12:49:18 -0800
Message-ID: <20111213204918.GK25802@google.com>
References: <1317668832-10784-1-git-send-email-fweisbec@gmail.com>
	<20111213155848.GI25802@google.com>
	<20111213190642.GB2421@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111213190642.GB2421-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Tue, Dec 13, 2011 at 08:06:46PM +0100, Frederic Weisbecker wrote:
> On Tue, Dec 13, 2011 at 07:58:48AM -0800, Tejun Heo wrote:
> > Can you please rebase the patchset on top of cgroup/for-3.3?
> 
> Sure. But please note its fate is still under discussion. Whether
> we want it upstream is still a running debate. But I certainly
> need to rebase against your tree.

I see.

> > I primarily like the idea of being able to track process usage w/ cgroup
> > and enforce limits on it but hope that it could somehow integrate w/
> > cgroup freezer.  ie. trigger freezer if it goes over limit and let the
> > userland tool / administrator deal with the frozen cgroup.  I'm
> > planning on extending cgroup freezer such that it supports recursive
> > freezing and killing of frozen tasks.  If we can fit task counters
> > into that, we'll have general method of handling problematic cgroups -
> > freeze, notify userland and let it deal with it.
> 
> Hmm, so you suggest a kernel trigger that freeze the cgroup when the
> task limit is reached?

Yeah, something like that.  I'm not really sure about how it would
actually work tho.

> What about rather implementing register_event() for the tasks.usage such
> that the user can be notified using eventfd when the limit is reached.
> Then it would be up to the user to decide to freeze or any other thing.
> Sounds like a more generic solution.

Maybe, the problem would be how to ensure that the userland manager
can respond fast enough (whatever that means...).

Thanks.

-- 
tejun
