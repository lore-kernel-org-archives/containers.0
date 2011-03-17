From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 17/18] user-cr: Fix double free
Date: Thu, 17 Mar 2011 10:27:49 -0700
Message-ID: <b2088002d6b93118cfd333c8920a4126b1c9759a.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
	<143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
	<c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc@us.ibm.com>
	<5a316654b4cc0a18ae05f012ab69b86dbc4b21dd.1300382276.git.matthltc@us.ibm.com>
	<4fa9581395e8ce3b7317a221321e15321b01f534.1300382276.git.matthltc@us.ibm.com>
	<da8b6651fb9271826e35ba47d9e41883b63bfee0.1300382276.git.matthltc@us.ibm.com>
	<4b6b9f5cc66c1675d6249622455709d6c5d586c9.1300382276.git.matthltc@us.ibm.com>
	<65466a734e085f916c776de153dfddf1c60aea7b.1300382276.git.matthltc@us.ibm.com>
	<c0d1aeb2aa40cecab3182ce686833b964cd8c07f.1300382276.git.matthltc@us.ibm.com>
	<79950217f2c66153c2b4b5bfb55bd5f1759b7933.1300382276.git.matthltc@us.ibm.com>
	<4e4459e8d18102996eedb18a216b45b93dc473c2.1300382276.git.matthltc@us.ibm.com>
	<27ba6a5c70b7e4e3aba2f42641b322f7a7bef7ba.1300382276.git.matthltc@us.ibm.com>
	<a62f11e2f3c8fb4d1271414b5ae854c29ee73ae8.1300382276.git.matthltc@us.ibm.com>
	<8db3ca5ee994168916fbb8d36a604c06e18e2c7b.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8db3ca5ee994168916fbb8d36a604c06e18e2c7b.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

There should only be one free() in the image_parse_tree() function because
image_parse() always frees the pointer passed in as a parameter. Since the
pointer is passed by value we can reuse variable "h" inside image_parse_tree()
and image_parse() will still free the correct memory.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ckptinfo.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ckptinfo.c b/ckptinfo.c
index be1f89f..e7609c0 100644
--- a/ckptinfo.c
+++ b/ckptinfo.c
@@ -263,13 +263,14 @@ static int image_parse_tree(struct ckpt_hdr *h, int fd, struct args *args)
 
 	hh = (struct ckpt_hdr_tree *) h;
 	nr_tasks = hh->nr_tasks;
-	free(h);
 
+	h = NULL;
 	ret = image_read_obj(fd, &h);
 	if (ret == 0)
 		fprintf(stderr, "process tree: unexpected end of file");
-	if (ret <= 0)
+	if (!h || ret <= 0) {
 		return -1;
+	}
 
 	pp =  (struct ckpt_pids *) h;
 
-- 
1.6.3.3
