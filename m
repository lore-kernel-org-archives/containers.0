From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL cgroup] Update maintainership
Date: Fri, 18 Nov 2011 14:46:06 -0800
Message-ID: <20111118224606.GB27152__48413.028199184$1321656396$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

Paul doesn't have enough time to maintain cgroup and we agreed that I
take over as one of the maintainers and maintain git tree.  I would be
doing standard for-next/fixes branch management.  At least until
things settle down, I wouldn't be committing any patch w/o Li Zefan's
co-ack.

At the moment, there are a few conflicting patchsets floating around
and sorting them out for the next merge window would be the first
priority.

Please pull from the following git branch to receive MAINTAINERS update.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.2-fixes

Thank you.

Paul Menage (1):
      cgroup: Replace Paul Menage with Tejun Heo as cgroups maintainer

 MAINTAINERS |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7f6bc29..78751bb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1927,10 +1927,11 @@ S:	Maintained
 F:	drivers/connector/
 
 CONTROL GROUPS (CGROUPS)
-M:	Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
+M:	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
 M:	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
 L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
 L:	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git
 S:	Maintained
 F:	include/linux/cgroup*
 F:	kernel/cgroup*

--
tejun
