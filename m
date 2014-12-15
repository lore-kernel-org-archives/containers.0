From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 00/18] userns: review of bug fixes for 3.19-rcX
Date: Sun, 14 Dec 2014 20:25:26 -0600
Message-ID: <87a92py7hl.fsf__31459.6824384809$1418610485$gmane$org@x220.int.ebiederm.org>
References: <87k31wzehb.fsf@x220.int.ebiederm.org> <548DE7D7.3080607@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <548DE7D7.3080607-/L3Ra7n9ekc@public.gmane.org> (Richard Weinberger's message of "Sun,
	14 Dec 2014 20:41:11 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dottedmag-6nM9faFvqWvMFIMGWPqnnw@public.gmane.org
List-Id: containers.vger.kernel.org

Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:

> Am 12.12.2014 um 23:32 schrieb Eric W. Biederman:
>> 
>> The entire tree for testing is available at:
>> 	git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
>> 
>> This is my queue of important bug fixes for user namespaces.  Most of
>> these changes warrant being backported.  A few are bug fixes for cases
>> where only root can trigger the issue so have not been marked for being
>> back ported to stable.
>> 
>> A few of these patches have not been posted for review preivously, so I
>> a giving the light of mailling list before I send them to Linus.  This
>> patchset has seen some testing already. 
>> 
>> Since there are small deliberate breakage of userspace in here the more
>> reviewers/testers the better.
>> 
>> Baring complictions I intend to ask Linus to pull this patchset sometime
>> early next week.
>> 
>> So far nothing broke on my libvirt-lxc test bed. :-)
>> Tested with openSUSE 13.2 and libvirt 1.2.9.
>> Tested-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
>
> FYI, this change set breaks util-linux's unshare(1) tool
> as an unprivileged is no longer allowed to write to
> /proc/self/gid_map.

Only the --map-root-user option.  The patch below fixes it.
I will push this upstream after I push the main change to Linus.

This probably deseres a little discussion on the util-linux list.  Most
use cases will continue to work but with setgroups disabled some things
won't work and can not be made to work without privilege.

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Thu, 11 Dec 2014 20:05:25 -0600
Subject: [PATCH] unshare: Fix --map-root-user to work on new kernels

In rare cases droping groups with setgroups(0, NULL) is an operation
that can grant a user additional privileges.  User namespaces were
allwoing that operation to unprivileged users and that had to be
fixed.

Update unshare --map-root-user to disable the setgroups operation
before setting the gid_map.

This is needed as after the security fix gid_map is restricted to
privileged users unless setgroups has been disabled.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/pathnames.h |  1 +
 sys-utils/unshare.c | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/pathnames.h b/include/pathnames.h
index 1cc4e15e6e4f..1c53e4554268 100644
--- a/include/pathnames.h
+++ b/include/pathnames.h
@@ -92,6 +92,7 @@
 
 #define _PATH_PROC_UIDMAP	"/proc/self/uid_map"
 #define _PATH_PROC_GIDMAP	"/proc/self/gid_map"
+#define _PATH_PROC_SETGROUPS	"/proc/self/setgroups"
 
 #define _PATH_PROC_ATTR_CURRENT	"/proc/self/attr/current"
 #define _PATH_PROC_ATTR_EXEC	"/proc/self/attr/exec"
diff --git a/sys-utils/unshare.c b/sys-utils/unshare.c
index 95e4afbd055e..d409a7c936b6 100644
--- a/sys-utils/unshare.c
+++ b/sys-utils/unshare.c
@@ -39,6 +39,24 @@
 #include "pathnames.h"
 #include "all-io.h"
 
+static void disable_setgroups(void)
+{
+	const char *file = _PATH_PROC_SETGROUPS;
+	const char *deny = "deny";
+	int fd;
+
+	fd = open(file, O_WRONLY);
+	if (fd < 0) {
+		if (errno == ENOENT)
+			return;
+		 err(EXIT_FAILURE, _("cannot open %s"), file);
+	}
+
+	if (write_all(fd, deny, strlen(deny)))
+		err(EXIT_FAILURE, _("write failed %s"), file);
+	close(fd);
+}
+
 static void map_id(const char *file, uint32_t from, uint32_t to)
 {
 	char *buf;
@@ -178,6 +196,7 @@ int main(int argc, char *argv[])
 	}
 
 	if (maproot) {
+		disable_setgroups();
 		map_id(_PATH_PROC_UIDMAP, 0, real_euid);
 		map_id(_PATH_PROC_GIDMAP, 0, real_egid);
 	}
-- 
2.1.3
