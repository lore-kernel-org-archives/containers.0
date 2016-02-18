From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Make core_pattern support namespace
Date: Thu, 18 Feb 2016 14:18:03 -0600
Message-ID: <877fi122o4.fsf@x220.int.ebiederm.org>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>
	<20160216142608.GA16757@mguzik> <87k2m33xgj.fsf@x220.int.ebiederm.org>
	<20160217205407.GD16757@mguzik>
	<009601d16a43$de01fb80$9a05f280$@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <009601d16a43$de01fb80$9a05f280$@cn.fujitsu.com> (Zhao Lei's
	message of "Thu, 18 Feb 2016 19:59:48 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> Hi, Mateusz Guzik
>
>> -----Original Message-----
>> From: Mateusz Guzik [mailto:mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
>> Sent: Thursday, February 18, 2016 4:54 AM
>> To: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Cc: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
>> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Subject: Re: [PATCH] Make core_pattern support namespace
>> 
>> On Wed, Feb 17, 2016 at 02:15:24PM -0600, Eric W. Biederman wrote:
>> > Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> > > On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
>> > >> For container based on namespace design, it is good to allow
>> > >> each container keeping their own coredump setting.
>> > >
>> > > Sorry if this is a false alarm, I don't have easy means to test it, but
>> > > is not this an immediate privilege escalation?
>> >
>> > It is.  This is why we do not currently have a per namespace setting.
>> >
>> 
>> Thanks for confimation.
>> 
>> > Solving the user mode helper problem is technically a fair amount of
>> > work, if not theoretically challenging.
>> >
>> 
>> Well, I would say custom core_patterns without pipe support are still
>> better than none.
>> 
> +1.

-1.

The problem is solvable.  It is just a matter of effort to build the
necessary infrastructure and make certain everything works correctly.

>> Say one would ensure a stable core_pattern (i.e. that it cannot be
>> modified as it is being parsed) and a restricted set of allowed
>> characters in the pattern (which would not include the pipe), validated
>> when one attempts to set the pattern.
>> 
>> Does this sound acceptable? If so, and there are no counter ideas from
>> Lei, I can get around to that.
>> 
> If we can let kernel select pipe_program in vm's filesystem, and run
> pipe_program with vm's filesystem, set a pipe for core_patterm in vm
> will be safe.
> What is your opinion on above solution?

Please see the other thread about user mode helpers that is current
active on the container mailling list.

> If above way is not acceptable, or impossible to realize, I also
> agree your solution of limit vm setting pipe.

I honestly think have a fully capable system that we have now that is
capable of using setns and entering a containers context is better than
something half baked.  The solution either needs to support everything
core_pattern does today but correctly in a container environment.

To make the case that something does not need to be supported, a
convincing argument needs to be presented and tested that no one ever
does that.  Without such an argument you will be breaking userspace
in a different way.  Not actually fixing things.

My baseline reference implementation of all of this is that it is
possible when a sufficiently privileged process writes to core_pattern
to fork a child with the same environment and context as the writer.
That forked child could then become a kernel thread and fork any
additional children needed as user mode helpers.

Eric
