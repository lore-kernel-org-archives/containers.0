From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/2] autofs4: Modify autofs_wait to use current_uid() and
	current_gid()
Date: Wed, 29 Nov 2017 18:05:26 -0600
Message-ID: <87shcwiqbd.fsf@xmission.com>
References: <874lpck52r.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874lpck52r.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Wed, 29 Nov 2017 18:01:16 -0600")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org


The code used to do that and then I mucked with it and never quite put
the code back.  Today the code references current_cred()->uid and
current_cred()->gid which is equivalent but more wordy, and not
idiomatic.

Fixes: 93faccbbfa95 ("fs: Better permission checking for submounts")
Fixes: 069d5ac9ae0d ("autofs:  Fix automounts by using current_real_cred()->uid")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/autofs4/waitq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
index 8fc41705c7cd..9908ecf7fce0 100644
--- a/fs/autofs4/waitq.c
+++ b/fs/autofs4/waitq.c
@@ -443,8 +443,8 @@ int autofs4_wait(struct autofs_sb_info *sbi,
 		memcpy(&wq->name, &qstr, sizeof(struct qstr));
 		wq->dev = autofs4_get_dev(sbi);
 		wq->ino = autofs4_get_ino(sbi);
-		wq->uid = current_cred()->uid;
-		wq->gid = current_cred()->gid;
+		wq->uid = current_uid();
+		wq->gid = current_gid();
 		wq->pid = pid;
 		wq->tgid = tgid;
 		wq->status = -EINTR; /* Status return if interrupted */
-- 
2.14.1
