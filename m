From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/8] cr_tests: epoll: Cleanup libeptest.[oa]
Date: Tue,  9 Mar 2010 14:48:16 -0800
Message-ID: <f3da329964189100a830b4b0aebd7a50743c22ea.1268174893.git.matthltc@us.ibm.com>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
	<c30d7daea96f1706234a26c0df2a97069cfa14c8.1268174893.git.matthltc@us.ibm.com>
	<d090f2ac4919cf161e4b0e05e589d18a4a5333f4.1268174893.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d090f2ac4919cf161e4b0e05e589d18a4a5333f4.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

These weren't being cleaned up.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/module.mk |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/epoll/module.mk b/epoll/module.mk
index 2e5d8c6..260e549 100644
--- a/epoll/module.mk
+++ b/epoll/module.mk
@@ -9,3 +9,5 @@ test_clean += $(local_dir)/cr_epoll*
 $(local_progs): CPPFLAGS += -I .
 $(local_progs): LDFLAGS += -Xlinker -dT -Xlinker libcrtest/labels.lds
 $(local_progs): $(local_dir)/libeptest.o libcrtest/libcrtest.a
+
+extra_clean += $(local_dir)/libeptest.o $(local_dir)/libeptest.a
-- 
1.6.3.3
