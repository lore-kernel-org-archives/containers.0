From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 17:03:33 -0800
Message-ID: <6599ad830802281703hb3cff06r8ba4755f705a0879@mail.gmail.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<20080228173618.139f5bb4.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080228173618.139f5bb4.pj-sJ/iWh9BUns@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Feb 28, 2008 at 3:36 PM, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
>
>  We could accomplish that much by decreeing that future new kernel
>  generated names that we might add follow some stronger convention,
>  such as the cgroup_ or appropriate subsystem prefix.

Subsystem-created files already have an appropriate prefix.

> No need to
>  change the existing well known names for this reason.

But that's part of my point - is it reasonable to describe a system
that was only introduced in 2.6.24 as "well-known"?

>
>    Actually, in terms of 'common names used
>  by humans' some of these names, "tasks" and "notify_on_release", date
>  back much earlier than that.  Please don't rename these two files in
>  cgroups; and of course absolutely don't rename them in cpusets.

No, I wasn't planning to make any changes to cpusets.

>
>  Please don't end up with different names of these files, depending on
>  whether you're in cgroups or cpusets, either.

That already happens - when mounted as the "cpuset" filesystem, we
have names like "mems_allowed". When mounted as cgroups, we have names
like cpuset.mems_allowed.

>
> > Could we do something like auto-prefixing user-created directories with a
>  > fixed string so that there is no way in which the user can cause a
>  > collision with kernel-created files?
>
>  Lordy lordy -- a bunch of intrusive, complicating crap to solve a
>  non-existent problem (sorry for the indelicate choice of words ;).

No, I don't like that idea either.

Paul
