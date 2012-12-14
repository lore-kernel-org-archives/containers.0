From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/4] user namespace fixes
Date: Fri, 14 Dec 2012 14:01:57 -0800
Message-ID: <87txroxpgq.fsf@xmission.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


These are fixes from Andys review of my user namespace tree.

The first two patches are critical must fix fixes.

The third patch fixing commit_creds is a nice to have but fixing it
would be good.

Andy, Serge  if you could give these patches a once over to make certain
I am not doing something stupid.

Thank you,
Eric

---

Eric W. Biederman (4):
      Fix cap_capable to only allow owners in the parent user namespace to have caps.
      userns:  Require CAP_SYS_ADMIN for most uses of setns.
      userns: Add a more complete capability subset test to commit_creds
      userns: Fix typo in description of the limitation of userns_install

 fs/namespace.c           |    3 ++-
 ipc/namespace.c          |    3 ++-
 kernel/cred.c            |   26 +++++++++++++++++++++++++-
 kernel/pid_namespace.c   |    3 ++-
 kernel/user_namespace.c  |    2 +-
 kernel/utsname.c         |    3 ++-
 net/core/net_namespace.c |    3 ++-
 security/commoncap.c     |   25 +++++++++++++++++--------
 8 files changed, 53 insertions(+), 15 deletions(-)
