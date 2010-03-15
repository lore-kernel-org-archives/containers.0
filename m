From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] cr_tests: eventfd: Run eventfd from runall.sh
Date: Mon, 15 Mar 2010 16:01:06 -0700
Message-ID: <21440dddd450d1c9d85e408d5c7ce9e17e80d54e.1268694050.git.matthltc@us.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc@us.ibm.com>
	<5b1bb7d32f49f39912aceddc22139fdb342d699f.1268694050.git.matthltc@us.ibm.com>
	<8bf27318f6f59bc4c03f21121f03995cbb4ce593.1268694050.git.matthltc@us.ibm.com>
	<9c200071918fda28567d801a2af825d36caa208a.1268694050.git.matthltc@us.ibm.com>
	<54f3b58880621b4bcf2ae094e755dcfa5c87390f.1268694050.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <54f3b58880621b4bcf2ae094e755dcfa5c87390f.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 runall.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/runall.sh b/runall.sh
index 6b07d17..3ed9720 100644
--- a/runall.sh
+++ b/runall.sh
@@ -112,6 +112,12 @@ bash runtest.sh
 update_totals $? taskfs
 popd
 
+echo "Running eventfd tests"
+pushd eventfd
+bash run.sh
+update_totals $? eventfd
+popd
+
 echo $passed out of $total test groups passed.
 echo "Failed tests:"
 for t in ${failed[@]}; do echo " $t"; done
-- 
1.6.3.3
