From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/10] cr_tests: fileio: Add missing voids
Date: Mon, 15 Mar 2010 23:51:01 -0700
Message-ID: <20100316065101.GG3037@count0.beaverton.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<1268695929.4397.134.camel@localhost.localdomain>
	<20100316060410.GD3037@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100316060410.GD3037-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 11:04:10PM -0700, Matt Helsley wrote:
> On Mon, Mar 15, 2010 at 06:32:09PM -0500, Nathan Lynch wrote:
> > 
> > Change the definition of do_child from
> > 
> > void do_child()
> > 
> > to 
> > 
> > void do_child(void)
> > 
> > please?

<done in separate, reposting of the patch>

> > wait_for_child and setup_test_data need the same treatment.

Below.

Cheers,
	-Matt Helsley
---

cr_tests: fileio: Fix style nit -- missing voids

Fill the voids with more void.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/fileio/fsetown1.c b/fileio/fsetown1.c
index 56a97d5..59431a0 100644
--- a/fileio/fsetown1.c
+++ b/fileio/fsetown1.c
@@ -29,7 +29,7 @@ void iohandler(int sig)
 	got_sigio = 1;
 }
 
-static void wait_for_child()
+static void wait_for_child(void)
 {
 	int rc;
 	int status;
@@ -162,7 +162,7 @@ void do_child(void)
  * Create a pipe that the child will try to read from and parent will
  * write to.
  */
-void setup_test_data()
+void setup_test_data(void)
 {
 	int rc;
