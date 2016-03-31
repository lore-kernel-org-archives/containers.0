From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: [Patch v3 0/3] allow the creation of architecture emulation
	containers where the emulator binary is outside the container
Date: Thu, 31 Mar 2016 07:54:06 -0700
Message-ID: <1459436046.2958.21.camel@HansenPartnership.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Changes in v3:
 * Collected acks from Jan Kara and Serge Hallyn
 * Fixed doc spelling errors
 * fput -> put_filp in error path

Changes in v2:

 * Use oldfile f_creds for the vfs_open credentials in
   filp_clone_open()
 * remove spurious fput() after filp_close()
 * Add documentation for the F option

There's also now a git tree at

https://git.kernel.org/cgit/linux/kernel/git/jejb/binfmt_misc.git

Original cover letter:

I've recently been playing a lot with architecture emulation containers
using qemu, mainly so I can build and test the arm secure boot
toolchain on my x86 laptop (not having any arm server hardware).

The process for bringing up architecture emulation containers using
qemu-user is very cumbersome because the emulation has to be installed
within the container.  This is bad for several reasons, firstly because
it contaminates the container image to have an emulator sitting inside
it.  Secondly it means that all orchestration systems have to be
explicitly modified to work with non-native architectures and thirdly
it means that the consumer of the container can accidentally destroy
the emulation and thus permanently crash the container.

The fix for this is to add a mode to binfmt_misc where the emulation
can be permanently installed from the current mount namespace and where
it survives both chroot and changes of mount namespace, effectively
allowing the container to run using the emulator, but where the
emulator itself isn't present within the container.

There are a couple of downsides to this, firstly the mapping of the
interpreter is accessible inside the container even if the actual file
isn't (I don't think this is really a security problem) and secondly,
to update the emulator package, you now have to remove the emulation
update and reinstall it, but this should be easy to do with packaging
scripts.  Finally, the emulator must be static otherwise the container
would crash when the elf binary format attempted to run the elf
interpreter.

I'm not really a regular FS developer, so I'd appreciate FS people
taking a look at the new filp_clone_open() API and whether I got
everything correct.

Thanks,

James

---
James Bottomley (3):
  fs: add filp_clone_open API
  binfmt_misc: add persistent opened binary handler for containers
  binfmt_misc: add F option description to documentation

 Documentation/binfmt_misc.txt |  7 +++++++
 fs/binfmt_misc.c              | 41 +++++++++++++++++++++++++++++++++++++++--
 fs/internal.h                 |  1 +
 fs/open.c                     | 20 ++++++++++++++++++++
 4 files changed, 67 insertions(+), 2 deletions(-)
