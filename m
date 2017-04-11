From: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC snapshot using overlayfs fsfreeze
Date: Tue, 11 Apr 2017 18:28:39 +0300
Message-ID: <CAOQ4uxgG4QqANg088Jh0D+eZgU-5OnTR0tzeRW_MKiPKq15m1A__44710.6338725009$1491924534$gmane$org@mail.gmail.com>
References: <CAOQ4uxigD1=+nFXRrzsygxbceYwp5+owwHvu1y2x+o8Vzacq0w@mail.gmail.com>
	<20170410142023.3qgq7frbq25jcyur@smitten>
	<CAOQ4uxi8QcGX=qhb2Qw7KHWHe_D4rwf0zzgV_NOw94aM4eKtjg@mail.gmail.com>
	<20170411145927.qnwjhbpbunhhosqb@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170411145927.qnwjhbpbunhhosqb@smitten>
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

On Tue, Apr 11, 2017 at 5:59 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
> Hi Amir,
>
> On Tue, Apr 11, 2017 at 01:37:53PM +0300, Amir Goldstein wrote:
>> On Mon, Apr 10, 2017 at 5:20 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
>> > Hi Amir,
>> >
>> > On Sat, Apr 08, 2017 at 09:35:01PM +0200, Amir Goldstein wrote:
>> >> [moving this discussion over from fsdevel to containers list and
>> >> changing the title]
>> >>
>> >> On Tue, Apr 4, 2017 at 9:07 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
>> >> > On Tue, Apr 04, 2017 at 09:59:16PM +0300, Amir Goldstein wrote:
>> >> >> On Tue, Apr 4, 2017 at 9:01 PM, Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org> wrote:
>> >> >> > On Tue, Apr 04, 2017 at 12:47:52PM -0500, Serge E. Hallyn wrote:
>> >> >> >> > Would lxc-snapshot gain anything from the ability to fsfreeze an overlay
>> >> >> >> > mount?
>> >> >> >>
>> >> >> >> lxc-snapshot only works on stopped containers.  'lxc snapshot' can do live
>> >> >> >> snapshots using criu.  Tycho, does that do anything right now to freeze the
>> >> >> >> fs?
>> >> >> >
>> >> >> > Not that I'm aware of (CRIU might, but we don't in liblxc).
>> >> >> >
>> >> >> >> I'm not sure that freezing all the tasks is necessarily enough to settle
>> >> >> >> the fs, but I assume you're doing something about that already?
>> >> >> >
>> >> >> > I suspect it's not, but we're not doing anything besides freezing the
>> >> >> > tasks. In fact, we freeze the tasks by using the freezer cgroup,
>> >> >> > which itself is buggy, since the freezer cgroup can race with various
>> >> >> > filesystems. So, freezing tasks is hard, and I haven't even thought
>> >> >> > about how to freeze the fs for real :)
>> >> >> >
>> >> >> > But in any case, an fs freezing primitive does sound useful for
>> >> >> > checkpoint restore, assuming that we're right and freezing the tasks
>> >> >> > is simply not enough.
>> >> >> >
>> >> >>
>> >> >> So I already asked Pavel that question and he said that freezing
>> >> >> the tasks is enough. I am not convinced it is really enough to bring
>> >> >> a file system image (i.e. underlying blockdev) to a quiescent state,
>> >> >> but I think it may be enough for getting a stable view of the mounted
>> >> >> file system, so the files could be dumped somewhere.
>> >> >> I am guessing is what lxc snapshot does?
>> >> >
>> >> > Yes, lxc snapshot is basically just a frontend for CRIU.
>> >> >
>> >> >> I still didn't understand wrt lxc snapshot, is there a use case for
>> >> >> taking live snapshots without using CRIU? (because freezer cgroup
>> >> >> mentioned races or whatnot?).
>> >> >
>> >> > No, I think CRIU is the only project that will ever attempt to do
>> >> > checkpoint restore this way ;-).
>> >>
>> >> I don't doubt that.
>> >>
>> >> My question is whether it is interesting to snapshot a live container fs
>> >> without having to checkpoint not restore at all.
>> >>
>> >> >  CRIU supports two different ways of
>> >> > freezing tasks: one using the freezer cgroup and one without. The one
>> >> > without doesn't work against fork bombs very well, and the one with
>> >> > doesn't work because of some filesystems. So it's mostly a container
>> >> > engine implementation choice which to use.
>> >> >
>> >> >> It's definitely possible with btrfs and if my overlayfs freeze patches
>> >> >> are not terribly wrong, then it should be easy with overlayfs as well.
>> >> >> Does lxc snapshot already support live snapshot of btrfs container?
>> >> >
>> >> > Yes, it does. It freezes the tasks via the cgroup freezer and then
>> >> > does a btrfs snapshot of the filesystem once the tasks are frozen.
>> >> >
>> >>
>> >> So what I am not sure is if there are use cases where criu cannot be
>> >> used or maybe there are reasons not to use it. and for these cases
>> >> if it may be interesting to support snapshot of the storage by:
>> >> - fsfreeze -f
>> >> - copy upper dir
>> >> - fsfreeze -u
>> >
>> > I don't see a reason for it, but perhaps I'm not being very
>> > imaginative. Without the memory state, the potentially inconsistent fs
>> > state doesn't seem very helpful.
>> >
>>
>> Hi Tycho,
>>
>> The use case is quite simple really.
>> Same use case as any LVM snapshot and btrfs snapshot on a
>> non-containerized system:
>> Before installing some stuff, sync, take a snapshot of the root fs and
>> you can always
>> restart your system from that snapshot of root fs if something went wrong.
>>
>> You don't need to save any memory state for that and you don't need to dump any
>> processes info for that.
>> It's simply a snapshot that you can *start* from and not *resume* from.
>>
>> I am quite surprised to learn that containers don't have that
>> functionality (they don't?).
>> I guess it may be because containers CAN freeze processes, so they do it,
>> but it's really not a prerequisite for live *image* snapshot -
>> fsfreeze is enough.
>
> Well, the problem is when some container has some state in memory that
> it hasn't tried to commit to disk yet. Doing an fsfreeze on a running
> container doesn't seem safe in the general case. Of course offline

If it wasnt safe for containers it wouldnt have been safe for real servers
as well, but it is. This type of snapshotting does not gauranty consistency
of applications, but it is useful and being used all the same.

> (i.e. the container is not currently running) freezes are safe and in
> wide use today, I was speaking only of online freezes.
>
>> The thing is it is easy to snapshot container image based on LVM and btrfs today
>> (lvm snapshot command does fsfreeze on the file system on top of lvm volume),
>> but it is not possible to snapshot container image based on overlayfs
>> the same way.
>>
>> My patches implement fsfreeze for overlayfs, and quite frankly, I am
>> taken by surprise,
>> that container users don't find this useful. I may be missing something.
>
> I don't think you are. Container engines today use the snapshotting
> features of LVM, btrfs (and zfs) for offline freezes (and indeed,
> features like `btrfs send` and online snapshots to speed up live
> migration).
>

I believe I was missing something. Two things to be accurate.

One is that cgroup freeze is more appropriate for containers because
it freezes writers to all the mounted file systems in containers and not
just one.

The other thing is that the use case of using fsfreeze to snapshot root
fs is mostly relevant when the snapshot tool is run from inside the container.
For example, if anyone would want to run snapper inside the container
to manage snapshots of the container and not take snapshots of the
containers from the host, using fsfreeze would make some sense.

In that case, snapper would have to communicate with container
manager to take the snapshot and then container manager can freeze
the fs and take the snapshot. snapper would not be expecting for the
snapshot API to freeze all processes or the snapper process itself.
Though maybe it doesnt matter much.
Anyway, that is as far as my imagination can go wrt why fsfreeze would
be prefered over cgroup freeze in container case.

Maybe someone else has a more creative imagination than mine...

Thanks for taking the time to answer my question.
Amir.
