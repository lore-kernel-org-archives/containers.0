From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/4] pid: Make next_pidmap static again
Date: Wed, 12 Dec 2007 06:50:49 -0700
Message-ID: <m1r6hsuime.fsf_-_@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>
	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odcwvz3d.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir34vyaj.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejdsvy54.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abogvy39.fsf_-_@ebiederm.dsl.xmission.com>
	<m163z4vxzs.fsf_-_@ebiederm.dsl.xmission.com>
	<m11w9svxeb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ve74uio4.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ve74uio4.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Wed, 12 Dec 2007 06:49:47 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Now that we are using kill_pid_ns_info in zap_pid_ns_processes
the only user of next_pidmap is pid.c so we can make
next_pidmap static.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/pid.h |    1 -
 kernel/pid.c        |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index e409cc5..b18c15c 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -118,7 +118,6 @@ extern struct pid *find_pid(int nr);
  */
 extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
-int next_pidmap(struct pid_namespace *pid_ns, int last);
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void FASTCALL(free_pid(struct pid *pid));
diff --git a/kernel/pid.c b/kernel/pid.c
index 294fc28..5a1f0d0 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -180,7 +180,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	return -1;
 }
 
-int next_pidmap(struct pid_namespace *pid_ns, int last)
+static int next_pidmap(struct pid_namespace *pid_ns, int last)
 {
 	int offset;
 	struct pidmap *map, *end;
-- 
1.5.3.rc6.17.g1911
