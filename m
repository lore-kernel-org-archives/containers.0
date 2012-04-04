From: Steve French <smfrench-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Wed, 4 Apr 2012 14:23:34 -0500
Message-ID: <CAH2r5mvP56D0y4mk5wKrJcj+=OZ0e0Q5No_L+9a8a=GMcEhRew__22597.0760373913$1333567426$gmane$org@mail.gmail.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120404184909.GB29686-RcKxWJ4Cfj1J2suj2OqeGauc2jM2gXBXkQQo+JxHRPFibQn6LdNjmg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 4, 2012 at 1:49 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hey, Vivek.
>
> On Wed, Apr 04, 2012 at 10:51:34AM -0400, Vivek Goyal wrote:
>> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
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
>
> On principle, I don't think it has be any different. =A0Filesystems's
> interface to the underlying device is through bdi. =A0If a fs is block
> backed, block pressure should be propagated through bdi, which should
> be mostly trivial. =A0If a fs is network backed, we can implement a
> mechanism for network backed bdis, so that they can relay the pressure
> from the server side to the local fs users.
>
> That said, network filesystems often show different behaviors and use
> different mechanisms for various reasons and it wouldn't be too
> surprising if something different would fit them better here or we
> might need something supplemental to the usual mechanism.

For the network file system clients, we may be close already,
but I don't know how to allow servers like Samba or Apache
to query btrfs, xfs etc. for this information.

superblock -> struct backing_dev_info is probably fine as long
as we aren't making that structure more block device specific.
Current use of bdi is a little hard to understand since
there are 25+ fields in the structure.  Is their use/purpose written
up anywhere?  I have a feeling we are under-utilizing what
is already there.  In any case bdi is "backing" info not "block"
specific info.  Since bdi can be assigned to a superblock
and an inode, it seems reasonable for either network or local.

Note that it isn't just traditional network file systems (nfs and cifs and =
smb2)
but also virtualization (virtfs) and some special purpose file systems
for which block device specific interfaces to higher layers (above the fs)
are an awkward way to think about congestion.   What
about a case of a file system like btrfs that could back a
volume to a pool of devices and distribute hot/cold data
across multiple physical or logical devices?

By the way, there may be less of a problem with current
network file system clients due to small limits on simultaneous i/o.
Until recently NFS client had a low default slot count of 16 IIRC and
it was not much better for cifs.   The typical cifs server defaulted
to allowing a client to only send 50 simultaneous requests to that
server at one time ...
The cifs protocol allows more (up to 64K) and in 3.4 the client now
can send more requests (up to 32K) if the server is so configured.

With SMB2 since "credits" are returned on every response, fast
servers (e.g. Samba running on a good clustered file system,
or a good NAS box) may end up allowing thousands of simultaneous
requests if they have the resources to handle this.   Unfortunately,
the Samba server developers do not know how to request information
on superblock->bdi congestion information from user space.
I vaguely remember bdi debugging info available in sysfs, but how
would an application find out how congested the underlying volume
it is exporting is.

-- =

Thanks,

Steve
