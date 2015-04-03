From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 12/19] fs_pin: Allow for the possibility that m_list or
	s_list go unused.
Date: Thu,  2 Apr 2015 20:56:16 -0500
Message-ID: <1428026183-14879-12-git-send-email-ebiederm__47907.1833579384$1428026548$gmane$org@xmission.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

This is needed to support lazily umounting locked mounts.  Because the
entire unmounted subtree needs to stay together until there are no
users with references to any part of the subtree.

To support this guarantee that the fs_pin m_list and s_list nodes
are initialized by initializing them in init_fs_pin allowing
for the possibility that pin_insert_group does not touch them.

Further use hlist_del_init in pin_remove so that there is
a hlist_unhashed test before the list we attempt to update
the previous list item.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fs_pin.c            | 4 ++--
 include/linux/fs_pin.h | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/fs_pin.c b/fs/fs_pin.c
index b06c98796afb..611b5408f6ec 100644
--- a/fs/fs_pin.c
+++ b/fs/fs_pin.c
@@ -9,8 +9,8 @@ static DEFINE_SPINLOCK(pin_lock);
 void pin_remove(struct fs_pin *pin)
 {
 	spin_lock(&pin_lock);
-	hlist_del(&pin->m_list);
-	hlist_del(&pin->s_list);
+	hlist_del_init(&pin->m_list);
+	hlist_del_init(&pin->s_list);
 	spin_unlock(&pin_lock);
 	spin_lock_irq(&pin->wait.lock);
 	pin->done = 1;
diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
index 9dc4e0384bfb..3886b3bffd7f 100644
--- a/include/linux/fs_pin.h
+++ b/include/linux/fs_pin.h
@@ -13,6 +13,8 @@ struct vfsmount;
 static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
 {
 	init_waitqueue_head(&p->wait);
+	INIT_HLIST_NODE(&p->s_list);
+	INIT_HLIST_NODE(&p->m_list);
 	p->kill = kill;
 }
 
-- 
2.2.1
