From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations v2
Date: Mon, 27 Oct 2008 13:19:27 -0700
Message-ID: <m1skqh4wq8.fsf__20006.686615716$1225139262$gmane$org@frodo.ebiederm.org>
References: <20081022212124.GA9910@us.ibm.com> <49003019.40904@bull.net>
	<m1fxmni9uv.fsf_-_@frodo.ebiederm.org>
	<20081027.124126.74749150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081027.124126.74749150.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's
	message of "Mon, 27 Oct 2008 12:41:26 -0700 (PDT)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
> Date: Thu, 23 Oct 2008 08:56:08 -0700
>
>> To make testing of the network namespace simpler allow
>> the network namespace code and the sysfs code to be
>> compiled and run at the same time.  To do this only
>> virtual devices are allowed in the additional network
>> namespaces and those virtual devices are not placed
>> in the kobject tree.
>> 
>> Since virtual devices don't actually do anything interesting
>> hardware wise that needs device management there should
>> be no loss in keeping them out of the kobject tree and
>> by implication sysfs.  The gain in ease of testing
>> and code coverage should be significant.
>> 
>> Changelog:
>> 
>> v2: As pointed out by Benjamin Thery it only makes sense to call
>>     device_rename in the initial network namespace for now.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
>> Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>
> So let's figure out what happens with this patch.
> I'm personally ok with the change, the question is when
> and where.
>
> My net-2.6 tree was closed to new features long ago, so I really
> don't want to try to merge this sucker into 2.6.28-rcX :-)  But if
> you guys think that is prudent, feel free to submit it directly to
> Linus and add my signoff:
>
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>
> otherwise if we shoot for 2.6.29 I would suggest that we wait until
> the merge window to see if the sysfs issues get sorted, and if not
> we slip this patch into to tree instead.
>
> Let me know what you guys plan to do with this.

What I was thinking is that it goes into your tree for 2.6.29.  Allowing
for better test coverage in the short term, and removing the pressure
to do a hack job on sysfs just to reduce the pain of testing.

The patch was sent during the merge window just because that is
when the conversation was happening.

I guess the pain with sysfs is having multiple patches in different
trees in this area causing conflicts in linux-next.  Ugh.  I can see
why you would want to hold back.  On the contrary point of view we
need that patch in someones tree or else we might as well merge it
now, if the plan is to merge it without it sitting in anyone's
development tree.

So my plan is I'm not going to worry about that patch, and leave it to
Ben and Daniel (if it needs a retransmit).  If it happens to merge
into net-next and that causes conflicts when we do a good job on
sysfs I will handle it.

Eric
