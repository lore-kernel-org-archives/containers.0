From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: [PATCHSET 3/4] sysfs: divorce sysfs from kobject and	driver model
Date: Fri, 05 Oct 2007 07:24:55 -0600
Message-ID: <m1lkahk82g.fsf@ebiederm.dsl.xmission.com>
References: <11902755392688-git-send-email-htejun@gmail.com>
	<20070925221736.GA3566@kroah.com> <46FB956B.8000205@gmail.com>
	<m1zlz7hpvn.fsf_-_@ebiederm.dsl.xmission.com>
	<20071005062302.GB16914@kroah.com>
	<m1d4vtn4jq.fsf@ebiederm.dsl.xmission.com> <4706363A.9030807@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762995AbXJEN1S@vger.kernel.org>
In-Reply-To: <4706363A.9030807@sw.ru> (Kirill Korotaev's message of "Fri, 05
	Oct 2007 17:03:54 +0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Kirill Korotaev <dev@sw.ru>
Cc: Greg KH <greg@kroah.com>, Tejun Heo <htejun@gmail.com>, kay.sievers@vrfy.org, linux-kernel@vger.kernel.org, cornelia.huck@de.ibm.com, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Kirill Korotaev <dev@sw.ru> writes:

> Imho environments to be migratable should have no direct access to the devices.
> You can use any of stacked virtual filesystems to hide real
> device from container.
> You will have problems much bigger than this one otherwise
> (imagine access to video, sound etc.)

What I am primarily concern about is when you can make the case that
the hardware we are talking is present before and after the migration.

When you are directly accessing a device.  For times when it makes
sense to directly access hardware in a container (think infiniband
OS-bypass NICs).  We need to tell user space that the device was
unplugged and another one was plugged in.  If user space can cope with
that things should continue to work.

There are some very specific cases that we can support:
- Stateless devices like /dev/zero and dev/random.
- Virtual devices like ttys, ramdisks, loop devices
- Remote block devices like SCSI disks on a san, iSCSI, nbd, ATAoE.
- Local pseudo block devices like the backing devices for virtual
  filesystems.

There are very specific limits in which this can work and be useable,
and I don't claim to have looked at all of the details, but for the
block device case in particular we export the block device number
to user space in stat.  There are some common applications which do
memorize stat data for files things like: git, incremental backup
software, and intrusion detection software.

Frankly the times when this matters is rare enough I don't put a
big priority on getting this done quickly.  However a strong case
has been made for all of this filtering so we can run things like
udev in a container.  Initially I only expect stateless character
devices and ttys to be allowed in a namespace, and I don't have
a clue what device number we will use in st_dev for stat in the
case our block device isn't in the user space interface.  I just know
that it sounds like where we want to be eventually and thinking
about it now isn't a problem.

Eric
