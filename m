From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup access daemon
Date: Fri, 28 Jun 2013 12:48:48 -0700
Message-ID: <CAAAKZwvKJ2p6Bv17mbPJPAQUA5pQyvJcVzQ3fyQ+Nt=h6n-mHw@mail.gmail.com>
References: <CAAAKZwuKxxYoVRn6Ye72Vs7vSd_T4cbvEwiU6Q3j4D-Z+VAPrw@mail.gmail.com>
	<20130627181108.GA26334@sergelap>
	<CAAAKZwvXYBznJ5uiWaEV7fNCHbciwLa6U+E5RUJkz1ioMu=cRg@mail.gmail.com>
	<20130628163154.GA4989@sergelap>
	<CAAAKZwv1CQbCOweUOcvFXtwDsMHB6Pay-fUqz-CNrcOAda8ghA@mail.gmail.com>
	<20130628192117.GA4553@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130628192117.GA4553@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 28, 2013 at 12:21 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Tim Hockin (thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org):
>> On Fri, Jun 28, 2013 at 9:31 AM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>> > Quoting Tim Hockin (thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org):
>> >> On Thu, Jun 27, 2013 at 11:11 AM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>> >> > Quoting Tim Hockin (thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org):
>> > Could you give examples?
>> >
>> > If you have a white/academic paper I should go read, that'd be great.
>>
>> We don't have anything on this, but examples may help.
>>
>> Someone running as root should be able to connect to the "native"
>> daemon and read or write any cgroup file they want, right?  You could
>> argue that root should be able to do this to a child-daemon, too, but
>> let's ignore that.
>>
>> But inside a container, I don't want the users to be able to write to
>> anything in their own container.  I do want them to be able to make
>> sub-cgroups, but only 5 levels deep.  For sub-cgroups, they should be
>> able to write to memory.limit_in_bytes, to read but not write
>> memory.soft_limit_in_bytes, and not be able to read memory.stat.
>>
>> To get even fancier, a user should be able to create a sub-cgroup and
>> then designate that sub-cgroup as "final" - no further sub-sub-cgroups
>> allowed under it.  They should also be able to designate that a
>> sub-cgroup is "one-way" - once a process enters it, it can not leave.
>>
>> These are real(ish) examples based on what people want to do today.
>> In particular, the last couple are things that we want to do, but
>> don't do today.
>>
>> The particular policy can differ per-container.  Production jobs might
>> be allowed to create sub-cgroups, but batch jobs are not.  Some user
>> jobs are designated "trusted" in one facet or another and get more
>> (but still not full) access.
>
> Interesting, thanks.
>
> I'll think a bit on how to best address these.
>
>> > At the moment I'm going on the naive belief that proper hierarchy
>> > controls will be enforced (eventually) by the kernel - i.e. if
>> > a task in cgroup /lxc/c1 is not allowed to mknod /dev/sda1, then it
>> > won't be possible for /lxc/c1/lxc/c2 to take that access.
>> >
>> > The native cgroup manager (the one using cgroupfs) will be checking
>> > the credentials of the requesting child manager for access(2) to
>> > the cgroup files.
>>
>> This might be sufficient, or the basis for a sufficient access control
>> system for users.  The problem comes that we have multiple jobs on a
>> single machine running as the same user.  We need to ensure that the
>> jobs can not modify each other.
>
> Would running them each in user namespaces with different mappings (all
> jobs running as uid 1000, but uid 1000  mapped to different host uids
> for each job) would be (long-term) feasible?

Possibly.  It's a largish imposition to make on the caller (we don't
use user namespaces today, though we are evaluating how to start using
them) but perhaps not terrible.

>> > It is a named socket.
>>
>> So anyone can connect?  even with SO_PEERCRED, how do you know which
>> branches of the cgroup tree I am allowed to modify if the same user
>> owns more than one?
>
> I was assuming that any process requesting management of
> /c1/c2/c3 would have to be in one of its ancestor cgroups (i.e. /c1)
>
> So if you have two jobs running as uid 1000, one under /c1 and one
> under /c2, and one as uid 1001 running under /c3 (with the uids owning
> the cgroups), then the file permissions will prevent 1000 and 1001
> from walk over each other, while the cgroup manager will not allow
> a process (child manager or otherwise) under /c1 to manage cgroups
> under /c2 and vice versa.
>
>> >> Do you have a design spec, or a requirements list, or even a prototype
>> >> that we can look at?
>> >
>> > The readme at https://github.com/hallyn/cgroup-mgr/blob/master/README
>> > shows what I have in mind.  It (and the sloppy code next to it)
>> > represent a few hours' work over the last few days while waiting
>> > for compiles and in between emails...
>>
>> Awesome.  Do you mind if we look?
>
> No, but it might not be worth it (other than the readme) :) - so far
> it's only served to help me think through what I want and need from
> the mgr.
>
>> > But again, it is completely predicated on my goal to have libvirt
>> > and lxc (and other cgroup users) be able to use the same library
>> > or API to make their requests whether they are on host or in a
>> > container, and regardless of the distro they're running under.
>>
>> I think that is a good goal.  We'd like to not be different, if
>> possible.  Obviously, we can't impose our needs on you if you don't
>> want to handle them.  It sounds like what you are building is the
>> bottom layer in a stack - we (Google) should use that same bottom
>> layer.  But that can only happen iff you're open to hearing our
>> requirements.  Otherwise we have to strike out on our own or build
>> more layers in-between.
>
> I'm definately open to your requirements - whether providing what
> you need for another layer on top, or building it right in.

Great.  That's a good place to start :)
