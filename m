From: John Ogness <dazukolist3@ogness.net>
Subject: Re: container support in DazukoFS
Date: Sun, 04 Jul 2010 01:15:57 +0200
Message-ID: <87tyog2m36.fsf@lonestar.fn.ogness.net>
References: <87tyogde9l.fsf@lonestar.fn.ogness.net>
	<m1vd8wr2qb.fsf@fess.ebiederm.org> <m18w5splhz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <dazuko-devel-bounces+gldd-dazuko-devel=gmane.org@nongnu.org>
In-Reply-To: <m18w5splhz.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Sat\, 03 Jul 2010 09\:40\:08 -0700")
List-Unsubscribe: <http://lists.nongnu.org/mailman/listinfo/dazuko-devel>,
	<mailto:dazuko-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/dazuko-devel>
List-Post: <mailto:dazuko-devel@nongnu.org>
List-Help: <mailto:dazuko-devel-request@nongnu.org?subject=help>
List-Subscribe: <http://lists.nongnu.org/mailman/listinfo/dazuko-devel>,
	<mailto:dazuko-devel-request@nongnu.org?subject=subscribe>
Sender: dazuko-devel-bounces+gldd-dazuko-devel=gmane.org@nongnu.org
Errors-To: dazuko-devel-bounces+gldd-dazuko-devel=gmane.org@nongnu.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.osdl.org>, linux-fsdevel@vger.kernel.org, dazuko-devel@nongnu.org
List-Id: containers.vger.kernel.org

On 2010-07-03, ebiederm@xmission.com (Eric W. Biederman) wrote:
>> I've been wondering what we could do to make DazukoFS more acceptable
>> for mainline inclusion.
>>
>> [...]
>
> I just looked back at the reviews, and what I see is that your code
> essentially got the a brush off, as not really being worth
> reviewing.

I didn't get that impression. Especially since posting the patches led
to a relatively positive LWN.net article from Jake Edge.

> The comments were largely to point out giant design flaws in your
> approach to you, more than a serious hey this is a good idea, here a
> couple of little problems you need to fix to make it a good
> implementation.

The only giant design flaws that were discussed were related to
stackable filesystems in general and affect current mainline code
(eCryptfs) just as much as DazukoFS. Since eCryptfs also has these
issues and was accepted mainline, I did not view this as a reason to
reject DazukoFS.

As I stated in the original patch posts, one of the reasons for adding
another stackable filesystem to mainline would be to help identify
common functionality between the stackable filesystems. And then
together figure out how we can solve these problems, which currently
affect any stackable filesystem in Linux.

> [...]
>
> In particular Al was saying that the scenario you warn about in your
> readme is impossible to avoid, and thus Dazuko is broken by design.

His comments were saying that stackable filesystems are broken by
design. Do we need to fix filesystem stacking in Linux before
accepting any more broken stackable filesystems? Or do we just pretend
that eCryptfs doesn't have these problems while brushing off any other
stackable filesystem submissions?

> [...]
>
> I am a bit puzzled why you are making something like this a kernel
> feature at all instead of treating virus scanning as something that
> apps can voluntarily participate in.

Getting every possible application on a system to participate is a lot
more work than simply letting the filesystem handle it. All file
access must go through the filesystem, so if you want to control file
access I think it makes sense to implement that at the filesystem
level.

> With so many races and holes in your implementation I don't see how
> a userspace implemenation in something like the gnome-vfs would be
> less effective.

The only races and holes are related to stackable filesystems on Linux
in general.

> [...]
>
> If you are going around creating control devices dynamically, I
> suggest a control pseudo filesystem like devpts might be more
> appropriate.  The you can keep your per instance configuration as
> per mount data in your control fs.

That is an interesting suggestion. I will think about how we
could/should do that.

> [...]
>
> What I was objecting to long ago is the existence of group names,
> your current design has global group names.  I can't understand what
> your groups are doing, or why your groups need names, but having
> group names in a new interface makes them global and unusable by
> containers, and pretty much so fragile that you are going to wish
> you had sense to design something less prone to problems later on.
>
> Also using the concept of a dazuko group when we already have the
> concept of process group is to put it mildly confusing.
>
> I looked at your tracking code a little bit I don't understand what
> you are trying to accomplish but the code certainly does not track
> the process that opens the dazuko group as the description indicates
> it should.

A Dazuko group is not associated with processes. Instead, processes
decide if they want to do work for an existing group. Maybe "file
access event queue" is a more appropriate description than
"group". There is no restriction on which processes can handle an item
of a file access event queue except for the Linux security permissions
on the queue itself (which is currently a device node).

I can see how using Linux process groups to implement this feature
would be possible. But it would be changing the semantics of the
feature considerably and making things IMHO unnecessarily complicated.

Perhaps I need technical documentation that is geared towards kernel
rather than userspace developers. Then such misunderstandings and
incorrect associations could be (possibly) avoided.

> [...]
>
> Since you asked you should not use current->pid.  You want something
> that is struct pid based for your notifications, or you will never
> figure out which process is doing what in the presence of pid
> namespaces.

Thank you. These changes were implemented after your comment on LKML.

> [...]
>
> For the mount namespace which sounds like you primarily care about
> the APIs are:
> clone( ... CLONE_NEWNS ... )
> unshare( CLONE_NEWNS )
> mount( ... )
> chroot( ... )
>
> They have been in the kernel since at least 2.5.early.  If you are
> doing interesting things with filesystems and you don't understand
> those APIs I don't see how you can possibly create correct code.

I am interested in creating correct code. That is why I have asked
questions.

John Ogness
