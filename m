From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC] Per-user namespace process accounting
Date: Sat, 07 Jun 2014 20:25:46 -0700
Message-ID: <87vbsc6q11.fsf@x220.int.ebiederm.org>
References: <5386D58D.2080809@1h.com> <87tx88nbko.fsf@x220.int.ebiederm.org>
	<53870EAA.4060101@1h.com> <20140529153232.GB9714@ubuntumail>
	<538DFF72.7000209@parallels.com> <20140603172631.GL9714@ubuntumail>
	<8738flkhf0.fsf@x220.int.ebiederm.org>
	<1402177144.2236.26.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1402177144.2236.26.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
	(James Bottomley's message of "Sat, 07 Jun 2014 14:39:04 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> writes:

> On Tue, 2014-06-03 at 10:54 -0700, Eric W. Biederman wrote:
>> 
>> 90% of that work is already done.
>> 
>> As long as we don't plan to support XFS (as it XFS likes to expose it's
>> implementation details to userspace) it should be quite straight
>> forward.
>
> Any implementation which doesn't support XFS is unviable from a distro
> point of view.  The whole reason we're fighting to get USER_NS enabled
> in distros goes back to lack of XFS support (they basically refused to
> turn it on until it wasn't a choice between XFS and USER_NS).  If we put
> them in a position where they choose a namespace feature or XFS, they'll
> choose XFS.

This isn't the same dicotomy.  This is a simple case of not being able
to use XFS mounted inside of a user namespace.  Which does not cause any
regression from the current use cases.  The previous case was that XFS
would not build at all.

There were valid technical reasons but part of the reason the XFS
conversion took so long was my social engineering the distro's to not
enable the latest bling until there was a chance for the initial crop of
bugs to be fixed.

> XFS developers aren't unreasonable ... they'll help if we ask.  I mean
> it was them who eventually helped us get USER_NS turned on in the first
> place.

Fair enough.  But XFS is not the place to start.

For most filesystems the only really hard part is finding the handful of
places where we actually need some form of error handling when on disk
uids don't map to in core kuids.  Which ultimately should wind up with
maybe a 20 line patch for most filesystems.

For XFS there are two large obstacles to overcome. 

- XFS journal replay does not work when the XFS filesystem is moved from
  a host with one combination of wordsize and endianness to a host with
  a different combination of wordsize and edianness.  This makes XFS a
  bad choice of a filesystem to move between hosts in a sparse file.
  Every other filesystem in the kernel handles this better.

- The XFS code base has a large the largest number of any ioctls of any
  filesystem in the linux kernel.  This increases the amount of code
  that has to be converted.  Combine that with the fact that the XFS
  developers chose to convert from kuids and kgids at the VFS<->FS layer
  instead of at the FS<->disk layer it becomes quite easy to miss
  changing code in an ioctl or a quota check by accident.  Which all
  adds up to the fact that converting XFS to be mountable with a non 1-1
  mapping of filesystem uids and system kuids is going to be a lot more
  than a simple 20 line patch.

All of that said what becomes attractive about this approach is that it
gets us to the point where people can ask questions about mounting
normal filesystems unprivileged and the entire reason it won't be
allowed are (no block devices to mount from) and concern that the
filesystem error handling code is not sufficient to ward off evil users
that create bad filesystem images.

Eric
