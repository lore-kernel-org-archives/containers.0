From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/18] user-cr: Include arch-dependent enums in
	ckptinfo_types.c
Date: Thu, 17 Mar 2011 10:27:41 -0700
Message-ID: <4b6b9f5cc66c1675d6249622455709d6c5d586c9.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
	<143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
	<c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc@us.ibm.com>
	<5a316654b4cc0a18ae05f012ab69b86dbc4b21dd.1300382276.git.matthltc@us.ibm.com>
	<4fa9581395e8ce3b7317a221321e15321b01f534.1300382276.git.matthltc@us.ibm.com>
	<da8b6651fb9271826e35ba47d9e41883b63bfee0.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <da8b6651fb9271826e35ba47d9e41883b63bfee0.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This incorporates arch-dependent enums in ckptinfo_types.c by using
the preprocessor to follow #includes.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index dd07ef9..e1ad370 100644
--- a/Makefile
+++ b/Makefile
@@ -100,7 +100,7 @@ endif
 ckptinfo: ckptinfo_types.o
 
 ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
-	cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
+	cat $(CKPT_HEADERS) | cpp -P -U__KERNEL__  $(CKPT_INCLUDE) - | ./ckptinfo.py > ckptinfo_types.c
 
 install: $(PROGS)
 	/usr/bin/install -d -D $(BIN_INSTALL_DIR) $(LIB_INSTALL_DIR)
-- 
1.6.3.3
