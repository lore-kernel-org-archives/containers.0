From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/12] dquot: For now explicitly don't support
	filesystems outside of init_user_ns
Date: Wed,  6 Jul 2016 13:12:10 -0500
Message-ID: <20160706181212.16267-10-ebiederm__27348.7897393808$1467829574$gmane$org@xmission.com>
References: <874m82bptc.fsf@x220.int.ebiederm.org>
	<20160706181212.16267-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160706181212.16267-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Mostly supporting filesystems outside of init_user_ns is
s/&init_usre_ns/dquot->dq_sb->s_user_ns/.  An actual need for
supporting quotas on filesystems outside of s_user_ns is quite a ways
away and to be done responsibily needs an audit on what can happen
with hostile quota files.  Until that audit is complete don't attempt
to support quota files on filesystems outside of s_user_ns.

Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/quota/dquot.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 74706b6aa747..87197d13cc76 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -2271,6 +2271,11 @@ static int vfs_load_quota_inode(struct inode *inode, int type, int format_id,
 		error = -EINVAL;
 		goto out_fmt;
 	}
+	/* Filesystems outside of init_user_ns not yet supported */
+	if (sb->s_user_ns != &init_user_ns) {
+		error = -EINVAL;
+		goto out_fmt;
+	}
 	/* Usage always has to be set... */
 	if (!(flags & DQUOT_USAGE_ENABLED)) {
 		error = -EINVAL;
-- 
2.8.3
