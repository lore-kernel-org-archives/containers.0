From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [PATCH 1/4] hashtable: Add __HASHTABLE_INITIALIZER
Date: Wed, 29 Jun 2016 16:37:02 +0300
Message-ID: <1467207425-22072-2-git-send-email-kernel@kyup.com>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1467207425-22072-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This is used so that one can initialize a hashtbale declared in a
struct.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 include/linux/hashtable.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
index 661e5c2a8e2a..92d6a791b218 100644
--- a/include/linux/hashtable.h
+++ b/include/linux/hashtable.h
@@ -23,6 +23,9 @@
 #define DECLARE_HASHTABLE(name, bits)                                   	\
 	struct hlist_head name[1 << (bits)]
 
+#define __HASHTABLE_INITIALIZER(bits)						\
+	{ [0 ... (( 1 << bits)) - 1] = HLIST_HEAD_INIT }
+
 #define HASH_SIZE(name) (ARRAY_SIZE(name))
 #define HASH_BITS(name) ilog2(HASH_SIZE(name))
 
-- 
2.5.0
