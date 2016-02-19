From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH] Make core_pattern support namespace
Date: Fri, 19 Feb 2016 18:24:21 +0800
Message-ID: <00b401d16aff$b299e590$17cdb0b0$@cn.fujitsu.com>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>	<20160216142608.GA16757@mguzik>
	<87k2m33xgj.fsf@x220.int.ebiederm.org>	<20160217205407.GD16757@mguzik>	<009601d16a43$de01fb80$9a05f280$@cn.fujitsu.com>
	<877fi122o4.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877fi122o4.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "'Eric W. Biederman'" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Biederman

> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
> Sent: Friday, February 19, 2016 4:18 AM
> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: 'Mateusz Guzik' <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH] Make core_pattern support namespace
> 
> Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
> > Hi, Mateusz Guzik
> >
> >> -----Original Message-----
> >> From: Mateusz Guzik [mailto:mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> >> Sent: Thursday, February 18, 2016 4:54 AM
> >> To: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> Cc: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>;
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
> >> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Subject: Re: [PATCH] Make core_pattern support namespace
> >>
> >> On Wed, Feb 17, 2016 at 02:15:24PM -0600, Eric W. Biederman wrote:
> >> > Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >> > > On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
> >> > >> For container based on namespace design, it is good to allow
> >> > >> each container keeping their own coredump setting.
> >> > >
> >> > > Sorry if this is a false alarm, I don't have easy means to test it, but
> >> > > is not this an immediate privilege escalation?
> >> >
> >> > It is.  This is why we do not currently have a per namespace setting.
> >> >
> >>
> >> Thanks for confimation.
> >>
> >> > Solving the user mode helper problem is technically a fair amount of
> >> > work, if not theoretically challenging.
> >> >
> >>
> >> Well, I would say custom core_patterns without pipe support are still
> >> better than none.
> >>
> > +1.
> 
> -1.
> 
> The problem is solvable.  It is just a matter of effort to build the
> necessary infrastructure and make certain everything works correctly.
> 
Writting a pipe for both host and container have some limit:
1: All host who wantting to run container can not custom core_patterns
   to other value, it is to say, core_patterns will turn to be a const
   value in linux release with container support.
2: If a host support 2 types of container manager, for example,
   lxc and docker, each manager will try to modify host's core_patterns
   to its internal pipe program, and cause competition.
3: container can not modify core_patterns for its need, it is not like
   a real system.

> >> Say one would ensure a stable core_pattern (i.e. that it cannot be
> >> modified as it is being parsed) and a restricted set of allowed
> >> characters in the pattern (which would not include the pipe), validated
> >> when one attempts to set the pattern.
> >>
> >> Does this sound acceptable? If so, and there are no counter ideas from
> >> Lei, I can get around to that.
> >>
> > If we can let kernel select pipe_program in vm's filesystem, and run
> > pipe_program with vm's filesystem, set a pipe for core_patterm in vm
> > will be safe.
> > What is your opinion on above solution?
> 
> Please see the other thread about user mode helpers that is current
> active on the container mailling list.
> 
User mode helpers is discussed in other threads, but we hadn't get a
conclusion to answer is user mode helpers better than letting kernel
support core_pattern in namespace, just as our discussing in this thread.

> > If above way is not acceptable, or impossible to realize, I also
> > agree your solution of limit vm setting pipe.
> 
> I honestly think have a fully capable system that we have now that is
> capable of using setns and entering a containers context is better than
> something half baked.  The solution either needs to support everything
> core_pattern does today but correctly in a container environment.
> 
If we can fix problem of "the pipe dumping data to host filesystem",
both host and container will able to support full core_pattern.

> To make the case that something does not need to be supported, a
> convincing argument needs to be presented and tested that no one ever
> does that.  Without such an argument you will be breaking userspace
> in a different way.  Not actually fixing things.
> 
It is same problem with above.
When we fixed it, all container can be free to set core_pattern without
breaking host env, and the every container manager don't need to add
special argument for setting core_pattern.

> My baseline reference implementation of all of this is that it is
> possible when a sufficiently privileged process writes to core_pattern
> to fork a child with the same environment and context as the writer.
> That forked child could then become a kernel thread and fork any
> additional children needed as user mode helpers.
> 
Thanks for detailed explanation.
I'll investigate it is possible to write piped dump data to container's
filesystem.

We still have "container-write-to-host" problem even if we don't use this
patch, in current kernel, if we run a container with privilege,
1: container can modify core_pattern of host and other container
2: container can set core_pattern to pipe, then dump data to host filesystem
3: container can use this way to do more bad thing
Each of them are not accessable.

In summary:
+-------------+----------------+-------------+--------------------------+
|             | CURRENT_KERNEL | AFTER_PATCH | AFTER_MORE_WORK_ON_PATCH |
|-------------+----------------+-------------+--------------------------+
| WITHOUT     | SAFE           | SAFE        | SAFE                     |
| PRIVILEGE   |                |             |                          |
|-------------+----------------+-------------+--------------------------+
| PRIVILEGE   | DANGEROUS      | SAFE        | SAFE                     |
| DUMPTO FILE |                |             |                          |
|-------------+----------------+-------------+--------------------------+
| PRIVILEGE   | DANGEROUS      | DANGEROUS   | SAFE                     |
| DUMPTO PIPE |                |             |                          |
+-------------+----------------+-------------+--------------------------+

So letting ns support core_pattern is also a bug fix for above case.

What is your opinion?
Any suggestions are welcome.

Thanks
Zhaolei

> Eric
