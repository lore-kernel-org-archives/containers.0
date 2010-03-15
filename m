From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/10] cr_tests: eventfd: rw: Fixup cgroup path sent to
	move_to_cgroup
Date: Mon, 15 Mar 2010 16:01:04 -0700
Message-ID: <9c200071918fda28567d801a2af825d36caa208a.1268694050.git.matthltc@us.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc@us.ibm.com>
	<5b1bb7d32f49f39912aceddc22139fdb342d699f.1268694050.git.matthltc@us.ibm.com>
	<8bf27318f6f59bc4c03f21121f03995cbb4ce593.1268694050.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8bf27318f6f59bc4c03f21121f03995cbb4ce593.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

move_to_cgroup is too smart for full paths.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 eventfd/run.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/eventfd/run.sh b/eventfd/run.sh
index 910305f..1f29bed 100755
--- a/eventfd/run.sh
+++ b/eventfd/run.sh
@@ -49,7 +49,6 @@ for (( CURTEST = 0; CURTEST < NUMTESTS; CURTEST = CURTEST + 1 )); do
 	T=${TESTS[$CURTEST]}
 	((IMAX = $(../${T} -N)))
 	echo "INFO: Test ${T} does:"
-	../${T} -D | sed -e 's/^/INFO:/'
 	../${T} -L | sed -e 's/^/INFO:/'
 
 	TEST_LABELS=( $(../${T} -L | tail -n '+2' | cut -f 3) )
@@ -57,7 +56,7 @@ for (( CURTEST = 0; CURTEST < NUMTESTS; CURTEST = CURTEST + 1 )); do
 	# First we run the test taking checkpoints at all the labelled points
 	rm -f "./checkpoint-"{ready,done,skip}
 	echo "Running test: \"${T}\""
-	../${T} &
+	../${T} -f `basename $freezerdir` &
 	TEST_PID=$!
 
 	trap 'do_err; break 2' ERR EXIT
-- 
1.6.3.3
