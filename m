From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 0/6] Enable multiple mounts of devpts
Date: Mon, 4 Aug 2008 18:18:44 -0700
Message-ID: <20080805011844.GA14940@us.ibm.com>
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
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


I thought I will send out the patches I mentioned to H. Peter Anvin
recently to get some feedback on the general direction. This version
of the patchset ducks the user-space issue, for now.

---

Enable multiple mounts of devpts filesystem so each container can
allocate ptys independently.

To enable multiple mounts (most) devpts interfaces need to know which
instance of devpts is being accessed. This patchset uses the 'struct
inode' of the device being accessed to identify the appropriate devpts
instance. It then uses get_sb_nodev() instead of get_sb_single() to
allow multiple mounts

	PATCH 1/6	Pass-in 'struct inode' to devpts interfaces
	PATCH 2/6	Remove 'devpts_root' global
	PATCH 3/6	Move 'allocated_ptys' to sb->s_s_fs_info
	PATCH 4/6	Allow mknod of ptmx and tty devices
	PATCH 5/6	Allow multiple mounts of devpts
	PATCH 6/6	Tweak in init_dev() /dev/tty

If devpts is mounted just once, this patchset should not change any behavior.

If devpts is mounted more than once, then '/dev/ptmx' must be a symlink
to '/dev/pts/ptmx' and in each new devpts mount we must create the
device node '/dev/pts/ptmx' [c, 5;2] by hand.

Have only done some basic testing with multiple mounts and sshd. May not
be bisect-safe.

Appreciate comments on overall approach of my mapping from the inode
to sb->s_fs_info to allocated_ptys and the hacky use of get_sb_nodev(),
and also on the tweak to init_dev() (patch 6).

Todo:
	User-space impact of /dev/ptmx symlink - Options are being
	discussed on mailing list (new mount option and config token,
	new fs name, etc)

	Remove even initial kernel mount of devpts ?
