From: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC snapshot using overlayfs fsfreeze
Date: Sat, 8 Apr 2017 21:35:01 +0200
Message-ID: <CAOQ4uxigD1=+nFXRrzsygxbceYwp5+owwHvu1y2x+o8Vzacq0w__7738.51568014852$1491680116$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>
Cc: Oren Laadan <orenlaadan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

[moving this discussion over from fsdevel to containers list and
changing the title]

On Tue, Apr 4, 2017 at 9:07 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Apr 04, 2017 at 09:59:16PM +0300, Amir Goldstein wrote:
>> On Tue, Apr 4, 2017 at 9:01 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
>> > On Tue, Apr 04, 2017 at 12:47:52PM -0500, Serge E. Hallyn wrote:
>> >> > Would lxc-snapshot gain anything from the ability to fsfreeze an overlay
>> >> > mount?
>> >>
>> >> lxc-snapshot only works on stopped containers.  'lxc snapshot' can do live
>> >> snapshots using criu.  Tycho, does that do anything right now to freeze the
>> >> fs?
>> >
>> > Not that I'm aware of (CRIU might, but we don't in liblxc).
>> >
>> >> I'm not sure that freezing all the tasks is necessarily enough to settle
>> >> the fs, but I assume you're doing something about that already?
>> >
>> > I suspect it's not, but we're not doing anything besides freezing the
>> > tasks. In fact, we freeze the tasks by using the freezer cgroup,
>> > which itself is buggy, since the freezer cgroup can race with various
>> > filesystems. So, freezing tasks is hard, and I haven't even thought
>> > about how to freeze the fs for real :)
>> >
>> > But in any case, an fs freezing primitive does sound useful for
>> > checkpoint restore, assuming that we're right and freezing the tasks
>> > is simply not enough.
>> >
>>
>> So I already asked Pavel that question and he said that freezing
>> the tasks is enough. I am not convinced it is really enough to bring
>> a file system image (i.e. underlying blockdev) to a quiescent state,
>> but I think it may be enough for getting a stable view of the mounted
>> file system, so the files could be dumped somewhere.
>> I am guessing is what lxc snapshot does?
>
> Yes, lxc snapshot is basically just a frontend for CRIU.
>
>> I still didn't understand wrt lxc snapshot, is there a use case for
>> taking live snapshots without using CRIU? (because freezer cgroup
>> mentioned races or whatnot?).
>
> No, I think CRIU is the only project that will ever attempt to do
> checkpoint restore this way ;-).

I don't doubt that.

My question is whether it is interesting to snapshot a live container fs
without having to checkpoint not restore at all.

>  CRIU supports two different ways of
> freezing tasks: one using the freezer cgroup and one without. The one
> without doesn't work against fork bombs very well, and the one with
> doesn't work because of some filesystems. So it's mostly a container
> engine implementation choice which to use.
>
>> It's definitely possible with btrfs and if my overlayfs freeze patches
>> are not terribly wrong, then it should be easy with overlayfs as well.
>> Does lxc snapshot already support live snapshot of btrfs container?
>
> Yes, it does. It freezes the tasks via the cgroup freezer and then
> does a btrfs snapshot of the filesystem once the tasks are frozen.
>

So what I am not sure is if there are use cases where criu cannot be
used or maybe there are reasons not to use it. and for these cases
if it may be interesting to support snapshot of the storage by:
- fsfreeze -f
- copy upper dir
- fsfreeze -u

Thanks,
Amir.
