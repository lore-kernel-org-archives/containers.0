From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 0/10][v4]: Enable multiple devpts instances
Date: Fri, 12 Sep 2008 10:48:45 -0700
Message-ID: <20080912174845.GA17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


Enable multiple instances of devpts filesystem so each container can allocate
ptys independently.

User interface:

	Since supporting multiple mounts of devpts can break user-space, this
	feature is enabled only if:

		- CONFIG_DEVPTS_MULTIPLE_INSTANCES=y (new config token), and
		- new mount option, -o newinstance is specified

	If CONFIG_DEVPTS_MULTIPLE_INSTANCES=n, there should be no change in
	behavior.

	See [PATCH 10/10] - Documentation/filesystems/devpts.txt for detailed
	usage/compatibility information.

		[PATCH 01/10] Remove devpts_root global
		[PATCH 02/10] Per-mount allocated_ptys
		[PATCH 03/10] Per-mount 'config' object
		[PATCH 04/10] Extract option parsing to new function
		[PATCH 05/10] Add DEVPTS_MULTIPLE_INSTANCES config token
		[PATCH 06/10] Define mknod_ptmx()
		[PATCH 07/10] Update ptmx permissions during remount
		[PATCH 08/10] Define get_sb_ref()
		[PATCH 09/10] Enable multiple instances of devpts
		[PATCH 10/10] Document usage of multiple-instances of devpts
	
Implementation notes:

	1. To enable multiple mounts of /dev/pts, (most) devpts interfaces
	   need to know which instance of devpts is being accessed. This
	   patchset uses the 'struct inode' or 'struct tty_struct' of the
	   device being accessed to identify the appropriate devpts instance.
	   Hence the need for the /dev/pts/ptmx bind-mount.

	2. See comments in get_sb_ref() in fs/super.c (could not find
	   existing interfaces that accomplish it).

	3. Mount options must be parsed twice during mount (once to determine
	   the mode of mount (single/multi-instance) and once to actually
	   save the options. There does not seem to be an easy way to parse
	   once and reuse (See 'safe_process_mount_opts()' in [PATCH 9/10])


Changelog [v4]:

	- Port to 2008-09-04 ttydev tree (and drop patches that were merged in)
	- Add DEVPTS_MULTIPLE_INSTANCES config token (patch 5) and move new
	  behavior under #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES. 
	- Create ptmx node even in initial mount 
	- Change default permissions of pts/ptmx node to 0000 (patch 6)
	- Cache ptmx dentry and use to update permissions of ptmx node on
	  remount so legacy mode can use the node with a simpler change to
	  /etc/fstab (patch 7)
	- Move get_sb_ref() helper code to separate patch (patch 8)
	- Add Documentation/filesystems/devpts.txt and describe usage info
	  in that file.
	  
Changelog [v3]:

	- Port to 2008-08-28 ttydev tree
	- Rename new mount options to 'ptmxmode' and 'newinstance'.
	- [Alan Cox] Use tty driver data to identify devpts (this is used to
	  cleanup get_node() in devpts_pty_kill()).
	- [H. Peter Anvin] get_node() cleanup in devpts (which was enabled by
	  the inode/tty parameter to devpts interfaces)
	- Bugfix in multi-mount mode (see Patch 11/11).
	- Executed pty tests in LTP (in both single-instance and multi-instance
	  mode)
	- Should be bisect-safe :-)

Changelog [v2]:

	- New mount option '-o newmnt' added (patch 8/8)
	- Support both single-mount and multi-mount semantics (patch 8/8)
	- Automatically create ptmx node when devpts is mounted (patch 7/8)
	- Extract option parsing code to new function (patch 6/8)
	- Make 'config' params per-mount variables (patch 5/8)
	- Slightly re-ordered existing patches in set (patches 1/8, 2/8)

TODO:
	- Do we need a '-o ptmxuid' and '-o ptmxgid' options as well ?
	- Update mount(8) man page
	- (Sometime in future) Remove even initial kernel mount of devpts 
	- Any other good test suites to test this (besides LTP, sshd).
