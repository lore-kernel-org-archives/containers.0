From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/4] vfs: Call d_dname from dentry_path
Date: Thu, 06 Feb 2014 18:24:56 -0800
Message-ID: <87wqh7fymf.fsf_-_@xmission.com>
References: <20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com> <20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
	<20131130224340.GA10323@ZenIV.linux.org.uk>
	<874n53gub7.fsf@xmission.com>
	<20140117083901.GA10323@ZenIV.linux.org.uk>
	<87iosrhdc0.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87iosrhdc0.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 06 Feb 2014 18:21:51 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


If the root dentry implements d_dname instead of ignoring it in
__dentry_path call d_dname and return the result.

The motivating example are files under /proc/<pid>/ns/ are bind
mounted into other locations.  This change allow the name of the
dentry that is bind mounted to show up in /proc/<pid>/mountinfo.
However in general this is correct behavior any time dentry_path is
called on a dentry that implements d_dname.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index c5c7847ff84b..a7a925fb3ce7 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3162,6 +3162,8 @@ restart:
 	done_seqretry(&rename_lock, seq);
 	if (error)
 		goto Elong;
+	if (dentry->d_op && dentry->d_op->d_dname)
+		retval = dentry->d_op->d_dname(dentry, buf, len);
 	return retval;
 Elong:
 	return ERR_PTR(-ENAMETOOLONG);
-- 
1.7.5.4
