From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Wed, 20 Aug 2008 19:21:26 -0700
Message-ID: <20080821022126.GA29449@us.ibm.com>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


I have been trying to address comments from the last patchset and
here is another snapshot of the patches. 

Appreciate any feedback on the single/multi-mount semantics (patch 8/8).

See below for changelog and pending stuff

---
Enable multiple mounts of devpts filesystem so each container can allocate
ptys independently.

User interface:

	Supporting multiple mounts of devpts can break user-space, this
	feature is enabled only under a new mount option (-o newmnt).

	If this option is never specified, this patchset should not change
	any behavior.  i.e existing single-namespace semantics are preserved
	across any remounts of /dev/pts (as long as none of them use the new
	option).  So old startup scripts should continue to work.

	If the '-o newmnt' option is specified, then a new 'private' mount
	of devpts is created. ptys in this private instance are independent
	of ptys created in other devpts instances. For this to be fully
	functionaly, /dev/ptmx must be a symbolic link to '/dev/pts/ptmx'

Implementation notes:

	1. To enable multiple mounts of /dev/pts, (most) devpts interfaces
	   need to know which instance of devpts is being accessed. This
	   patchset uses the 'struct inode' of the device being accessed
	   to identify the appropriate devpts instance. Hence the need for
	   the /dev/pts/ptmx symlink.

	2. See comments in get_sb_ref() in fs/super.c (could not find
	   existing interfaces that accomplish it) Or is there a better
	   way ?

	[PATCH 1/8]: /dev/tty tweak in init_dev()
	[PATCH 2/8]: Add inode parameter to devpts interfaces
	[PATCH 3/8]: Remove devpts_root global
	[PATCH 4/8]: Per-mount allocated_ptys
	[PATCH 5/8]: Per-mount config object
	[PATCH 6/8]: Extract option parsing to new function
	[PATCH 7/8]: Auto-create ptmx node when mounting devpts
	[PATCH 8/8]: Enable multiple mounts of devpts

Changelog [v2]:

	- New mount option '-o newmnt' added (patch 8/8)
	- Support both single-mount and multi-mount semantics (patch 8/8)
	- Automatically create ptmx node when devpts is mounted (patch 7/8)
	- Extract option parsing code to new function (patch 6/8)
	- Make 'config' params per-mount variables (patch 5/8)
	- Slightly re-ordered existing patches in set (patches 1/8, 2/8)

TODO:
	- Add a config option to enable multiple-mounts of devpts.
	- Remove even initial kernel mount of devpts ? (If we do, how
	  do we preserve single-mount semantics) ?
	- Testing :-), check for bisect-safe etc
