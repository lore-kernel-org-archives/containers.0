From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 0/7][v2] Cloning PTS namespace
Date: Mon, 24 Mar 2008 20:59:04 -0700
Message-ID: <20080325035904.GB27451@us.ibm.com>
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
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Devpts namespace patchset

In continuation of the implementation of containers in mainline, we need to
support multiple PTY namespaces so that the PTY index (ie the tty names) in
one container is independent of the PTY indices of other containers.  For
instance this would allow each container to have a '/dev/pts/0' PTY and
refer to different terminals.

	[PATCH 1/7]: Propagate error code from devpts_pty_new
	[PATCH 2/7]: Factor out PTY index allocation
	[PATCH 3/7]: Enable multiple mounts of /dev/pts
	[PATCH 4/7]: Implement get_pts_ns() and put_pts_ns()
	[PATCH 5/7]: Determine pts_ns from a pty's inode.
	[PATCH 6/7]: Check for user-space mount of /dev/pts
	[PATCH 7/7]: Enable cloning PTY namespaces

Todo:
	- This patchset depends on availability of additional clone flags.
	  and relies on on Cedric's clone64 patchset.

	- Needs more testing.

Changelog[v1]:
	- Fixed circular reference by not caching the pts_ns in sb->s_fs_info
	  (without incrementing reference count) and clearing the sb->s_fs_info
	  when destroying the pts_ns (See patch 3/7 for details).

	- To allow access to a child container's ptys from parent container,
	  determine the 'pts_ns' of a 'pty' from its inode (See patch 5/7
	  for details.

	- Added a check (hack) to ensure user-space mount of /dev/pts is
	  done before creating PTYs in a new pts-ns (see patch 6/7 for
	  details).

	- Reorganized the patchset and removed redundant changes.
	
	- Ported to work wih Cedric Le Goater's clone64() system call now
	  that we are out of clone_flags.

Changelog[v0]:

	This patchset is based on earlier versions developed by Serge Hallyn
	and Matt Helsley.
