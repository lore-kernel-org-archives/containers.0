From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 0/11][v3]: Enable multiple mounts of devpts
Date: Wed, 3 Sep 2008 22:27:18 -0700
Message-ID: <20080904052718.GA3680@us.ibm.com>
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


This patchset includes the patches to cleanup get_node() I had
sent earlier,  with the Sign-off added. No other changes were
made to those patches since I last sent.

---
Enable multiple mounts of devpts filesystem so each container can allocate
ptys independently.

User interface:

	Since supporting multiple mounts of devpts can break user-space, this
	feature is enabled only under a new mount option (-o newinstance).

	If this option is never specified, this patchset should not change
	any behavior.  i.e existing single-namespace semantics are preserved
	across any remounts of /dev/pts (as long as none of them use the new
	option).  So old startup scripts should continue to work.

	If the '-o newinstance' option is specified, then a new 'private' mount
	of devpts is created. Ptys in this private instance are independent
	of ptys created in other devpts instances. For this to be fully
	functional, /dev/ptmx must be a bind-mount of '/dev/pts/ptmx'

	i.e
		mount -t devpts -o newinstance lxcpts /dev/pts
		mount -o bind /dev/pts/ptmx /dev/ptmx

	See [PATCH 11/11] for more details on usage.

Implementation notes:

	1. To enable multiple mounts of /dev/pts, (most) devpts interfaces
	   need to know which instance of devpts is being accessed. This
	   patchset uses the 'struct inode' or 'struct tty_struct' of the
	   device being accessed to identify the appropriate devpts instance.
	   Hence the need for the /dev/pts/ptmx bind-mount.

	2. See comments in get_sb_ref() in fs/super.c (could not find
	   existing interfaces that accomplish it) Or is there a better
	   way ?

	3. Mount options must be parsed twice during mount (once to determine
	   the mode of mount (single/multi-instance) and once to actually
	   save the options. There does not seem to be an easy way to 
	   parse once and reuse (See 'safe_process_mount_opts()' in
	   PATCH 11/11)

	[PATCH 1/11]: Move tty lookup/reopen to tty_open
	[PATCH 2/11]: Add an instance parameter to devpts interfaces
	[PATCH 3/11]: Simplify devpts_get_tty()
	[PATCH 4/11]: Simplify devpts_pty_new()
	[PATCH 5/11]: Simplify devpts_pty_kill
	[PATCH 6/11]: Remove devpts_root global
	[PATCH 7/11]: Per-mount allocated_ptys
	[PATCH 8/11]: Per-mount 'config' object
	[PATCH 9/11]: Extract option parsing to new function
	[PATCH 10/11]: Ability to internally create ptmx 
	[PATCH 11/11]: Enable multiple instances of devpts

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
	- Add a config option to enable multiple-mounts of devpts.
	- (Sometime in future) Remove even initial kernel mount of devpts 
	- Any other good test suites to test this (besides LTP, sshd).
