From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 0/4] Devpts namespace
Date: Tue, 5 Feb 2008 21:04:28 -0800
Message-ID: <20080206050428.GA19461@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Serge, Matt, please sign-off on these patches as you see fit.
---

Devpts namespace patchset


In continuation of the implementation of containers in mainline, we need to
support multiple PTY namespaces so that the PTY index (ie the tty names) in
one container is independent of the PTY indices of other containers.  For
instance this would allow each container to have a '/dev/pts/0' PTY and
refer to different terminals.

	[PATCH 1/4]: Factor out PTY index allocation
	[PATCH 2/4]: Use interface to access allocated_ptys
	[PATCH 3/4]: Enable multiple mounts of /dev/pts
	[PATCH 4/4]: Enable cloning PTY namespaces

Todo:

	- This patchset depends on availability of additional clone flags !!!
	- Needs more testing.

Changelog:

	This patchset is based on earlier versions developed by Serge Hallyn
	and Matt Helsley.
