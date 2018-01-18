From: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [PATCH v5 00/11] FUSE mounts from non-init user namespaces
Date: Thu, 18 Jan 2018 15:58:41 +0100
Message-ID: <CADZs7q438szfwd-kaaRDnpDFrmno3zy7Zq+6EsnotW8bS0vrTA__46223.7509470016$1516287438$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<877etbcmnd.fsf@xmission.com>
	<CANxcAMvwwiPXBTKmTM9sEo8Y1T--V7fNaFqzHfyEvwvaYQV60A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANxcAMvwwiPXBTKmTM9sEo8Y1T--V7fNaFqzHfyEvwvaYQV60A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 9, 2018 at 4:05 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
> Hi,
>
> On Mon, Dec 25, 2017 at 8:05 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> writes:
>>
>>> This patchset v5 is based on work by Seth Forshee and Eric Biederman.
>>> The latest patchset was v4:
>>> https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1132206.html
>>>
>>> At the moment, filesystems backed by physical medium can only be mounted
>>> by real root in the initial user namespace. This restriction exists
>>> because if it's allowed for root user in non-init user namespaces to
>>> mount the filesystem, then it effectively allows the user to control the
>>> underlying source of the filesystem. In case of FUSE, the source would
>>> mean any underlying device.
>>>
>>> However, in many use cases such as containers, it's necessary to allow
>>> filesystems to be mounted from non-init user namespaces. Goal of this
>>> patchset is to allow FUSE filesystems to be mounted from non-init user
>>> namespaces. Support for other filesystems like ext4 are not in the
>>> scope of this patchset.
>>>
>>> Let me describe how to test mounting from non-init user namespaces. It's
>>> assumed that tests are done via sshfs, a userspace filesystem based on
>>> FUSE with ssh as backend. Testing system is Fedora 27.
>>
>> In general I am for this work, and more bodies and more eyes on it is
>> generally better.
>>
>> I will review this after the New Year, I am out for the holidays right
>> now.
>
> Thanks. I'll wait for your review.

Hi Eric,

Do you have some cycles for this now that it is the new year?

A review on the associated ima issue would also be appreciated:
https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1587678.html

Cheers,
Alban

>>> ====
>>> $ sudo dnf install -y sshfs
>>> $ sudo mkdir -p /mnt/userns
>>>
>>> ### workaround to get the sshfs permission checks
>>> $ sudo chown -R $UID:$UID /etc/ssh/ssh_config.d /usr/share/crypto-policies
>>>
>>> $ unshare -U -r -m
>>> # sshfs root@localhost: /mnt/userns
>>>
>>> ### You can see sshfs being mounted from a non-init user namespace
>>> # mount | grep sshfs
>>> root@localhost: on /mnt/userns type fuse.sshfs
>>> (rw,nosuid,nodev,relatime,user_id=0,group_id=0)
>>>
>>> # touch /mnt/userns/test
>>> # ls -l /mnt/userns/test
>>> -rw-r--r-- 1 root root 0 Dec 11 19:01 /mnt/userns/test
>>> ====
>>>
>>> Open another terminal, check the mountpoint from outside the namespace.
>>>
>>> ====
>>> $ grep userns /proc/$(pidof sshfs)/mountinfo
>>> 131 102 0:35 / /mnt/userns rw,nosuid,nodev,relatime - fuse.sshfs
>>> root@localhost: rw,user_id=0,group_id=0
>>> ====
>>>
>>> After all tests are done, you can unmount the filesystem
>>> inside the namespace.
>>>
>>> ====
>>> # fusermount -u /mnt/userns
>>> ====
>>>
>>> Changes since v4:
>>>  * Remove other parts like ext4 to keep the patchset minimal for FUSE
>>>  * Add and change commit messages
>>>  * Describe how to test non-init user namespaces
>>>
>>> TODO:
>>>  * Think through potential security implications. There are 2 patches
>>>    being prepared for security issues. One is "ima: define a new policy
>>>    option named force" by Mimi Zohar, which adds an option to specify
>>>    that the results should not be cached:
>>>    https://marc.info/?l=linux-integrity&m=151275680115856&w=2
>>>    The other one is to basically prevent FUSE results from being cached,
>>>    which is still in progress.
>>>
>>>  * Test IMA/LSMs. Details are written in
>>>    https://github.com/kinvolk/fuse-userns-patches/blob/master/tests/TESTING_INTEGRITY.md
>>>
>>> Patches 1-2 deal with an additional flag of lookup_bdev() to check for
>>> additional inode permission.
>>>
>>> Patches 3-7 allow the superblock owner to change ownership of inodes, and
>>> deal with additional capability checks w.r.t user namespaces.
>>>
>>> Patches 8-10 allow FUSE filesystems to be mounted outside of the init
>>> user namespace.
>>>
>>> Patch 11 handles a corner case of non-root users in EVM.
>>>
>>> The patchset is also available in our github repo:
>>>   https://github.com/kinvolk/linux/tree/dongsu/fuse-userns-v5-1
>>>
>>>
>>> Eric W. Biederman (1):
>>>   fs: Allow superblock owner to change ownership of inodes
>>>
>>> Seth Forshee (10):
>>>   block_dev: Support checking inode permissions in lookup_bdev()
>>>   mtd: Check permissions towards mtd block device inode when mounting
>>>   fs: Don't remove suid for CAP_FSETID for userns root
>>>   fs: Allow superblock owner to access do_remount_sb()
>>>   capabilities: Allow privileged user in s_user_ns to set security.*
>>>     xattrs
>>>   fs: Allow CAP_SYS_ADMIN in s_user_ns to freeze and thaw filesystems
>>>   fuse: Support fuse filesystems outside of init_user_ns
>>>   fuse: Restrict allow_other to the superblock's namespace or a
>>>     descendant
>>>   fuse: Allow user namespace mounts
>>>   evm: Don't update hmacs in user ns mounts
>>>
>>>  drivers/md/bcache/super.c           |  2 +-
>>>  drivers/md/dm-table.c               |  2 +-
>>>  drivers/mtd/mtdsuper.c              |  6 +++++-
>>>  fs/attr.c                           | 34 ++++++++++++++++++++++++++--------
>>>  fs/block_dev.c                      | 13 ++++++++++---
>>>  fs/fuse/cuse.c                      |  3 ++-
>>>  fs/fuse/dev.c                       | 11 ++++++++---
>>>  fs/fuse/dir.c                       | 16 ++++++++--------
>>>  fs/fuse/fuse_i.h                    |  6 +++++-
>>>  fs/fuse/inode.c                     | 35 +++++++++++++++++++++--------------
>>>  fs/inode.c                          |  6 ++++--
>>>  fs/ioctl.c                          |  4 ++--
>>>  fs/namespace.c                      |  4 ++--
>>>  fs/proc/base.c                      |  7 +++++++
>>>  fs/proc/generic.c                   |  7 +++++++
>>>  fs/proc/proc_sysctl.c               |  7 +++++++
>>>  fs/quota/quota.c                    |  2 +-
>>>  include/linux/fs.h                  |  2 +-
>>>  kernel/user_namespace.c             |  1 +
>>>  security/commoncap.c                |  8 ++++++--
>>>  security/integrity/evm/evm_crypto.c |  3 ++-
>>>  21 files changed, 127 insertions(+), 52 deletions(-)
