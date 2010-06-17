From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ptrace: allow restriction of ptrace scope
Date: Thu, 17 Jun 2010 13:45:02 -0700
Message-ID: <m1typ175ip.fsf@fess.ebiederm.org>
References: <20100616221833.GM24749@outflux.net>
	<m1hbl1eta6.fsf@fess.ebiederm.org>
	<20100617165940.GU24749@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20100617165940.GU24749@outflux.net> (Kees Cook's message of "Thu\, 17 Jun 2010 09\:59\:40 -0700")
Sender: linux-doc-owner@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Cc: linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Dave Young <hidave.darkstar@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Roland McGrath <roland@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-doc@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, "Serge E. Hallyn" <serge@hallyn.com>
List-Id: containers.vger.kernel.org

Kees Cook <kees.cook@canonical.com> writes:

> Hi,
>
> On Thu, Jun 17, 2010 at 05:29:53AM -0700, Eric W. Biederman wrote:
>> Kees Cook <kees.cook@canonical.com> writes:
>> > running state of any of their processes. For example, if one application
>> > (e.g. Pidgin) was compromised, it would be possible for an attacker to
>> > attach to other running processes (e.g. Firefox, SSH sessions, GPG agent,
>> > etc) to extract additional credentials and continue to expand the scope
>> > of their attack without resorting to user-assisted phishing.
>> 
>> This is ineffective.  As an attacker after I gain access to a users
>> system on ubuntu I can wait around until a package gets an update,
>> and then run sudo and gain the power to do whatever I want.
>
> I doesn't stop phishing, correct.  But it does stop immediate expansion of
> an attack using already-existing credentials.

sudo last I checked caches your password for a couple of seconds.
So if you can probe the system to see when those couple of seconds
are.


>> Either that or I can inject something nasty into the suid pulse-audio.
>
> Hmm?
>
> $ ls -la /usr/bin/pulseaudio
> -rwxr-xr-x 1 root root 71712 2010-06-10 11:59 /usr/bin/pulseaudio
>
> But I take your meaning to be "can still exploit other vulnerabilities".
> That'll always be true, but that's why I'm looking to make the attack
> surface smaller.

Yes.  Apparently pulseaudio has been fixed recently.


>> I tell you what.  If you really want something effective, help Serge
>> and I finish getting the cross namespace issues fixed for the user
>> namespace.  When complete, it will possible for an unprivileged process
>> to create a new one, and since kernel capabilities along with everything
>> else will be local to it, running pidgin, or firefox, or another network
>> facing potentially buggy application in such a namespace will ensure that
>> even if the process is compromised it won't have privileges to ptrace another
>> process or do much else on the system.
>
> It sounds pretty good, but isolating desktop applications is no simple
> task.  They tend to like to have free reign over a user's entire home
> directory.  But I think that's a bit of a tangent.  That said, I'd like to
> know more; where can I find details?

The archives of the containers list.
https://lists.linux-foundation.org/pipermail/containers/ or just
looking.

> I'm all for better separations.  In fact, I'd like to see /proc/sys using
> caps instead of DAC so that containers mounting /proc can't fiddle with the
> entire system.  Has anyone done anything with this?  It seems like it's
> only seen sporadic attention (e.g. my patch to test CAP_SYS_RAWIO for
> changing mmap_min_addr).

Ugh. CAP_SYS_RAWIO????  That certainly does not feel like the proper
capability there.   Which is among the reason I'm not a particular
fan of capabilities.

> I would assume there are others that need a similar protection?

Let me quickly summarize the plan.  The current implementation of the
user_namespace is not much more than a place holder for what should be
implemented.  We may want to rename the user_namespace to the security
credentials namespace when we are done.

All uids, gids, capabilities comparisons should change from.
if ( uid1 == uid2 ) to if ((user_ns1 == user_ns2) && uid1 == uid2).

Somewhere Serge has a git tree where he started making the capabilities
tests user_namespace local.  Which means that when you create a process
that does not share the current user_namespace you will get a full
set of capabilities relative to the current user_namespace.

The tricky bits are:
- Working through the vfs logic, so that filesystems can be aware
  of multiple user namespaces and can do what best suits them when
  presented with a DAC security test.

  proc will need to become uid namespace aware, different files
  will become user namespace aware.

  Things like /proc/sys/ will be default stay in the same user_namespace
  and root in other user namespaces will only get world permissions when
  accessing files.

- Correctly implementing and using ns_capable.  Which makes the capabilities
  caparison hierarchical.  A few key capability comparisons like CAP_NET_ADMIN
  will gradually be switched from a global capability comparison to a local one.

  If you are inside a user_namespace your capabilities will only be
  good for manipulating other objects (like the network namespace)
  that you have created after you entered the user namespace, other
  capability checks will fail because they will require the global
  capability namespace.

  The cute detail is that if you are not in a user namespace but are
  the creator of that user_namespace you will be treated for the purposes
  of security checks as having all capabilities that user_namespace
  posses.  Which will allow important things like the ability to kill
  your children in a child user_namespace.

Eric

