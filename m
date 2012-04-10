From: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Tue, 10 Apr 2012 11:23:16 -0500
Message-ID: <CAH2r5mvLVnM3Se5vBBsYzwaz5Ckp3i6SVnGp2T0XaGe9_u8YYA__26274.5973574512$1334075006$gmane$org@mail.gmail.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120407080027.GA2584-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Apr 7, 2012 at 3:00 AM, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org> wrote:
> =A0Hi Vivek,
>
> On Wed 04-04-12 10:51:34, Vivek Goyal wrote:
>> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
>> [..]
>> > IIUC, without cgroup, the current writeback code works more or less
>> > like this. =A0Throwing in cgroup doesn't really change the fundamental
>> > design. =A0Instead of a single pipe going down, we just have multiple
>> > pipes to the same device, each of which should be treated separately.
>> > Of course, a spinning disk can't be divided that easily and their
>> > performance characteristics will be inter-dependent, but the place to
>> > solve that problem is where the problem is, the block layer.
>>
>> How do you take care of thorottling IO to NFS case in this model? Current
>> throttling logic is tied to block device and in case of NFS, there is no
>> block device.
> =A0Yeah, for throttling NFS or other network filesystems we'd have to come
> up with some throttling mechanism at some other level. The problem with
> throttling at higher levels is that you have to somehow extract informati=
on
> from lower levels about amount of work so I'm not completely certain now,
> where would be the right place. Possibly it also depends on the intended
> usecase - so far I don't know about any real user for this functionality.=
..

Remember to distinguish between the two ends of the network file system.
There are slightly different problems.   The client has to be able to
expose the number of requests (and size of writes, or equivalently
number of pages it can write at one time) so that writeback is not done
too aggressively.  File servers have to be able to
discover the i/o limits dynamically of the underlying volume (not the
block device, but potentially a pool of devices) so it can tell
the client how much i/o it can send.  For SMB2 server (Samba) and
eventually for NFS, how many simultaneous requests it
can support will allow them to sanely set the number of "credits"
on each response - ie tell the client how many requests
are allowed in flight to a particular export.

In the case of block device throttling - other than the file system
internally using such APIs who would use block device specific
throttling - only the file system knows where it wants to put hot data,
and in the case of btrfs, doesn't the file system manage the
storage pool.   The block device should be transparent to the
user in the long run, and only the volume visible.


-- =

Thanks,

Steve
