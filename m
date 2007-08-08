From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 8 Aug 2007 16:16:31 +0200
Message-ID: <20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>
	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>
	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934427AbXHHOQX@vger.kernel.org>
In-Reply-To: <20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Tejun Heo <htejun@gmail.com>, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Wed, 8 Aug 2007 10:37:59 +0200,
Cornelia Huck <cornelia.huck@de.ibm.com> wrote:

> On Wed, 08 Aug 2007 01:57:07 -0600,
> ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
> > > Got it: It's patch 6, the readdir simplification.
> > >
> > > (The udev on that guest is ancient (063)...)
> > 
> > Ok.  That is weird.
> 
> More weirdness. If I activate another dasd from the repair file
> system, /dev/dasdb is created...
> 
> Same if I set the card reader online: /dev/vmrdr-0.0.000c is created as
> expected.

OK, it seems that it is udevstart that has problems. (Normal udev
operation seems fine; when I trigger uevents manually, the device nodes
are created.)

I ran strace on udevstart and found that it skipped
/sys/block/dasd/dasda1 (interestingly, /dev/dasda was created after I
ran udevstart manually; no idea why this didn't happen on boot. Further
manual runs don't create /dev/dasda1, however.) ls doesn't produce
different output on the two kernels.

Here is some excerpt from the strace run with the broken kernel:

open("/sys/block", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
getdents64(3, /* 28 entries */, 4096)   = 800
_llseek(3, 3414, [3414], SEEK_SET)      = 0
stat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
open("/sys/block/dasda", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 4
fstat64(4, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         = 0
getdents64(4, /* 15 entries */, 4096)   = 440
_llseek(4, 3079, [3079], SEEK_SET)      = 0
stat64("/sys/block/dasda/uevent/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/dev/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/range/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/removable/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/size/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/stat/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/capability/dev", 0x7fb8c3f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/device/dev", 0x7fb8c3f8) = -1 ENOENT (No such file or d irectory)
stat64("/sys/block/dasda/subsystem/dev", 0x7fb8c3f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/holders/dev", 0x7fb8c3f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/slaves/dev", 0x7fb8c3f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/queue/dev", 0x7fb8c3f8) = -1 ENOENT (No such file or directory)
getdents64(4, /* 1 entries */, 4096)    = 32
close(4)                                = 0
getdents64(3, /* 1 entries */, 4096)    = 32
close(3)                                = 0
lstat64("/sys/block/dasda", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
stat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
open("/sys/block/dasda/dev", O_RDONLY)  = 3
read(3, "94:0\n", 4096)                 = 5
close(3)                                = 0
lstat64("/sys/block/dasda/device", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/block/dasda/device", "../../devices/css0/0.0.0003/0.0.4e30", 256) = 36
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/bus", {st_mode=S_IFLNK|0777, st_siz e=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/bus", "../../../../bus/ccw", 256) = 19
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/driver", {st_mode=S_IFLNK|0777, st_ size=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/driver", "../../../../bus/ccw/driv ers/dasd-eckd", 256) = 37
open("/proc/filesystems", O_RDONLY|O_LARGEFILE) = 3
read(3, "nodev\tsysfs\nnodev\trootfs\nnodev\tb"..., 4095) = 259
close(3)                                = 0
stat64("/dev/dasda", 0x7fb8b738)        = -1 ENOENT (No such file or directory)
mknod("/dev/dasda", S_IFBLK|0640, makedev(94, 0)) = 0
chmod("/dev/dasda", 060640)             = 0
chown("/dev/dasda", 0, 6)               = 0


And here's with a working kernel:

open("/sys/block", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
getdents64(3, /* 27 entries */, 4096)   = 768
stat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
open("/sys/block/dasda", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 4
fstat64(4, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         = 0
getdents64(4, /* 15 entries */, 4096)   = 440
stat64("/sys/block/dasda/dasda1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
stat64("/sys/block/dasda/queue/dev", 0x7f9004f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/slaves/dev", 0x7f9004f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/holders/dev", 0x7f9004f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/subsystem/dev", 0x7f9004f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/device/dev", 0x7f9004f8) = -1 ENOENT (No such file or directory)
stat64("/sys/block/dasda/capability/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/stat/dev", 0x7f9004f8) = -1 ENOTDIR (Not a  directory)
stat64("/sys/block/dasda/size/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/removable/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/range/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/dev/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
stat64("/sys/block/dasda/uevent/dev", 0x7f9004f8) = -1 ENOTDIR (Not a directory)
getdents64(4, /* 0 entries */, 4096)    = 0
close(4)                                = 0
...
lstat64("/sys/block/dasda", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
stat64("/sys/block/dasda/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
open("/sys/block/dasda/dev", O_RDONLY)  = 3
read(3, "94:0\n", 4096)                 = 5
close(3)                                = 0
lstat64("/sys/block/dasda/device", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/block/dasda/device", "../../devices/css0/0.0.0003/0.0.4e30", 256) = 36
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/bus", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/bus", "../../../../bus/ccw", 256) = 19
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/driver", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/driver", "../../../../bus/ccw/drivers/dasd-eckd", 256) = 37
open("/proc/filesystems", O_RDONLY|O_LARGEFILE) = 3
read(3, "nodev\tsysfs\nnodev\trootfs\nnodev\tb"..., 4095) = 276
close(3)                                = 0
stat64("/dev/dasda", {st_mode=S_IFBLK|0640, st_rdev=makedev(94, 0), ...}) = 0
chmod("/dev/dasda", 060640)             = 0
chown("/dev/dasda", 0, 6)               = 0
...
lstat64("/sys/block/dasda/dasda1", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/block/dasda/dasda1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...} ) = 0
stat64("/sys/block/dasda/dasda1/dev", {st_mode=S_IFREG|0444, st_size=4096, ...}) = 0
open("/sys/block/dasda/dasda1/dev", O_RDONLY) = 3
read(3, "94:1\n", 4096)                 = 5
close(3)                                = 0
lstat64("/sys/block/dasda", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/block/dasda/device", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/block/dasda/device", "../../devices/css0/0.0.0003/0.0.4e30", 256) = 36
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/bus", {st_mode=S_IFLNK|0777, st_size=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/bus", "../../../../bus/ccw", 256) = 19
lstat64("/sys/devices/css0/0.0.0003/0.0.4e30/driver", {st_mode=S_IFLNK|0777, st_ size=0, ...}) = 0
readlink("/sys/devices/css0/0.0.0003/0.0.4e30/driver", "../../../../bus/ccw/drivers/dasd-eckd", 256) = 37
stat64("/dev/dasda1", {st_mode=S_IFBLK|0640, st_rdev=makedev(94, 1), ...}) = 0
chmod("/dev/dasda1", 060640)            = 0
chown("/dev/dasda1", 0, 6)              = 0

Ideas welcome...
