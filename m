From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user namespaces: require cap_set{ug}id for CLONE_NEWUSER
Date: Mon, 1 Dec 2008 12:52:15 -0600
Message-ID: <20081201185215.GA20976@us.ibm.com>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

thoughts?  (patch is on top of
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6.git#next)

thanks,
-serge

Subject: [PATCH] user namespaces: require cap_set{ug}id for CLONE_NEWUSER

While ideally CLONE_NEWUSER will eventually require no
privilege, the required permission checks are currently
not there.  As a result, CLONE_NEWUSER has the same effect
as a setuid(0)+setgroups(1,"0").  While we already require
CAP_SYS_ADMIN, requiring CAP_SETUID and CAP_SETGID seems
appropriate.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---

 kernel/fork.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

32c36be0621dba3bf05af3d2df843ce803d25831
diff --git a/kernel/fork.c b/kernel/fork.c
index 1dd8945..e3a85b3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1344,7 +1344,8 @@ long do_fork(unsigned long clone_flags,
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
-		if (!capable(CAP_SYS_ADMIN))
+		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
+				!capable(CAP_SETGID))
 			return -EPERM;
 	}
 
-- 
1.1.6
