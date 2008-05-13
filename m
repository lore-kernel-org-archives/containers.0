From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC/PATCH 1/8]: CGroup Files: Add locking mode to cgroups
	control files
Date: Tue, 13 May 2008 14:32:06 -0700
Message-ID: <20080513143206.ef259829.akpm__9374.29453847489$1210714476$gmane$org@linux-foundation.org>
References: <20080513063707.049448000@menage.corp.google.com>
	<20080513071522.133586000@menage.corp.google.com>
	<20080513130127.fcd46a41.akpm@linux-foundation.org>
	<6599ad830805131417m4f8cc2e6iac42c0fb089a8cb1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830805131417m4f8cc2e6iac42c0fb089a8cb1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 13 May 2008 14:17:29 -0700
"Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, May 13, 2008 at 1:01 PM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >
> >  This, umm, doesn't seem to do much to make the kernel a simpler place.
> >
> >  Do we expect to gain much from this?  Hope so...  What?
> >
> 
> The goal is to prevent cgroup_mutex becoming a BKL for cgroups, to
> make it easier for subsystems to lock just the bits that they need to
> remain stable rather than everything.

OK.

But do we ever expect that cgroup_mutex will be taken with much
frequency, or held for much time?  If it's only taken during, say,
configuration of a group or during a query of that configuration then
perhaps we'll be OK.

otoh a per-cgroup lock would seem more appropriate than a global.

> >
> >  Vague handwaving: lockdep doesn't know anything about any of this.
> >  Whereas if we were more conventional in using separate locks and
> >  suitable lock types for each application, we would retain full lockdep
> >  coverage.
> 
> That's a good point - I'd not thought about lockdep. That's a good
> argument in favour of not having the locking done in the framework.
> 
> Stepping back a bit, the idea is definitely that where appropriate
> subsystems will use their own fine-grained locking. E.g. the
> res_counter abstraction does this already with a spinlock in each
> res_counter, and cpusets has the global callback_mutex that just
> synchronizes cpuset operations. But there are some cases where they
> need a bit of help from cgroups, such as when doing operations that
> require stable hierarchies, task membership of cgroups, etc.
> 
> Right now the default behaviour is to call cgroup_lock(), which I'd
> like to get away from. Having the framework do the locking results in
> less need for cleanup code in the subsystem handlers themselves, but
> that's not an unassailable argument for doing it that way.

Yes, caller-provided locking is the usual pattern in-kernel.  Based on
painful experience :(

> >  I'm trying to work out what protects static_buffer?
> >
> >  Why does it need to be static anyway?  64 bytes on-stack is OK.
> >
> 
> As Matt observed, this is just a poorly-named variable. How about
> "small_buffer"?

local_buffer ;)
