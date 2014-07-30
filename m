From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 4/5] mnt: Change the default remount atime from
	relatime to the existing value
Date: Tue, 29 Jul 2014 20:54:10 -0700
Message-ID: <871tt3jycd.fsf_-_@x220.int.ebiederm.org>
References: <87fvih4a99.fsf@x220.int.ebiederm.org>
	<CAObL_7FfacSTdO=JEfYyqQrp8qOSob6qoWrGN=rSM5t9ckkTWg@mail.gmail.com>
	<8761injfj9.fsf_-_@x220.int.ebiederm.org>
	<CAObL_7GhpuO4m6HunKvNMSpiEYBuaJnvjfVDiyG88GZ8HOa-vg@mail.gmail.com>
	<CAOP=4wgKGxJmLwSHYRKXCTva_Fyzn+D1vaWhtT-mo_t9Uu68zA@mail.gmail.com>
	<87lhrihaan.fsf@x220.int.ebiederm.org>
	<CAObL_7HSNkM=Kr9Jwc9JB7Zt7ZdR+skzmPrxYcFSkCutFDA5KA@mail.gmail.com>
	<20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org> <20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
	<87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ppgnjyx4.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Tue, 29 Jul 2014 20:41:43 -0700")
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
Cc: Andrew Lutomirski <andy-RHosVwM/Cj8@public.gmane.org>, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


Since March 2009 the kernel has treated the state that if no
MS_..ATIME flags are passed then the kernel defaults to relatime.

Defaulting to relatime instead of the existing atime state during a
remount is silly, and causes problems in practice for people who don't
specify any MS_...ATIME flags and to get the default filesystem atime
setting.  Those users may encounter a permission error because the
default atime setting does not work.

A default that does not work and causes permission problems is
ridiculous, so preserve the existing value to have a default
atime setting that is always guaranteed to work.

Using the default atime setting in this way is particularly
interesting for applications built to run in restricted userspace
environments without /proc mounted, as the existing atime mount
options of a filesystem can not be read from /proc/mounts.

In practice this fixes user space that uses the default atime
setting on remount that are broken by the permission checks
keeping less privileged users from changing more privileged users
atime settings.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index dd9c93b5a9d5..7886176232c1 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2473,6 +2473,14 @@ long do_mount(const char *dev_name, const char *dir_name,
 	if (flags & MS_RDONLY)
 		mnt_flags |= MNT_READONLY;
 
+	/* The default atime for remount is preservation */
+	if ((flags & MS_REMOUNT) &&
+	    ((flags & (MS_NOATIME | MS_NODIRATIME | MS_RELATIME |
+		       MS_STRICTATIME)) == 0)) {
+		mnt_flags &= ~MNT_ATIME_MASK;
+		mnt_flags |= path.mnt->mnt_flags & MNT_ATIME_MASK;
+	}
+
 	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE | MS_BORN |
 		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME| MS_KERNMOUNT |
 		   MS_STRICTATIME);
-- 
1.9.1
