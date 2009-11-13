From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/7] cr_tests: epoll: Always thaw on error/exit trap
Date: Thu, 12 Nov 2009 22:45:29 -0800
Message-ID: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Always thaw when run.sh triggers a trap. This reduces the number of
places we change the trap handlers and makes the code a little easier
to read.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/run.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/epoll/run.sh b/epoll/run.sh
index 75c26a0..32b3068 100755
--- a/epoll/run.sh
+++ b/epoll/run.sh
@@ -38,6 +38,7 @@ function do_err()
        fi
        echo "${err_msg}"
        ((failed++))
+       thaw || /bin/true
        wait
 }
 
@@ -68,14 +69,12 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 		sleep 1
 	done
 	freeze
-	trap 'thaw; do_err; break' ERR EXIT
 	sync
 	cp log.${T} log.${T}${LABEL}.pre-ckpt
 	err_msg="FAIL"
 	${CHECKPOINT} ${TEST_PID} > checkpoint-${T}${LABEL}
 	err_msg="BROK"
 	thaw
-	trap 'do_err; break' ERR EXIT
 	touch "./checkpoint-done"
 	wait ${TEST_PID}
 	retval=$?
-- 
1.6.3.3


From 52c046d5dab12581295971ad8a0a985ee8e7d0b8 Mon Sep 17 00:00:00 2001
Message-Id: <52c046d5dab12581295971ad8a0a985ee8e7d0b8.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Mon, 12 Oct 2009 13:31:00 -0700
Subject: [PATCH 2/7] cr_tests: epoll: Fix sk10k "uninitialized use of ret" warning

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/sk10k.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/epoll/sk10k.c b/epoll/sk10k.c
index 1e2acfd..26647a3 100644
--- a/epoll/sk10k.c
+++ b/epoll/sk10k.c
@@ -166,7 +166,7 @@ int main(int argc, char **argv)
 	int op_num = 0;
 	int efd;
 	int ec = EXIT_FAILURE;
-	int ret;
+	int ret = 0;
 	int i;
 
 	parse_args(argc, argv);
-- 
1.6.3.3


From a59f7a98d947f49b39c4faaf68ed2d8a898d31d0 Mon Sep 17 00:00:00 2001
Message-Id: <a59f7a98d947f49b39c4faaf68ed2d8a898d31d0.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 14 Oct 2009 21:32:15 -0700
Subject: [PATCH 3/7] cr_tests: epoll: Fixup cycle.c

Remove link_cycle label (merged with create).

Change the direction of the cycle.

Change the wait labels to be a "do nothing" label just before we loop
    over and wait on each epoll set. This simplifies the loops and
    makes the code more obvious.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/cycle.c |  105 +++++++++++++++++++++++++++++---------------------------
 1 files changed, 54 insertions(+), 51 deletions(-)

diff --git a/epoll/cycle.c b/epoll/cycle.c
index bfa9aeb..32ffb4c 100644
--- a/epoll/cycle.c
+++ b/epoll/cycle.c
@@ -136,7 +136,7 @@ int main(int argc, char **argv)
 	int pfd[2];
 	int efd[3];
 	int ec = EXIT_FAILURE;
-	int ret, i;
+	int ret, i, j;
 
 	parse_args(argc, argv);
 
@@ -168,29 +168,27 @@ int main(int argc, char **argv)
 	    pfd[0], pfd[1]);
 
 label(create_efd, ret, ret + 0);
+	ev.events = EPOLLOUT|EPOLLIN|EPOLLET;
 	for (i = 0; i < num_efd; i++) {
-		efd[i] = epoll_create(3);
-		if (ret < 0) {
+		efd[i] = epoll_create(4);
+		if (efd[i] < 0) {
 			log("FAIL", "efd[i] = epoll_create(3);");
+			ret = efd[i];
 			goto out;
 		}
-	}
-
-label(link_cycle, ret, ret + 0);
-	/* Link the epoll fds together into a simple cycle */
-	ev.events = EPOLLOUT|EPOLLIN|EPOLLET;
-	for (--i; i >= 0; i--) {
-		ev.data.fd = efd[i + 1];
+		if (i == 0)
+			continue;
+		ev.data.fd = efd[i - 1];
 		ret = epoll_ctl(efd[i], EPOLL_CTL_ADD, ev.data.fd, &ev);
 		if (ret < 0) {
-			log("FAIL", "epoll_ctl(efd[i], EPOLL_CTL_ADD, ev.data.fd, &ev);");
+			log("FAIL", "epoll_ctl(efd[i] (%d), EPOLL_CTL_ADD, ev.data.fd (%d), &ev);", efd[i], ev.data.fd);
 			goto out;
 		}
 	}
 
 	/* Close the cycle */
-	ev.data.fd = 0;
-	ret = epoll_ctl(efd[num_efd - 1], EPOLL_CTL_ADD, ev.data.fd, &ev);
+	ev.data.fd = efd[num_efd - 1];
+	ret = epoll_ctl(efd[0], EPOLL_CTL_ADD, ev.data.fd, &ev);
 	if (ret < 0) {
 		log("FAIL",
 		"epoll_ctl(efd[num_efd - 1], EPOLL_CTL_ADD, ev.data.fd, &ev);");
@@ -203,7 +201,7 @@ label(link_pipe, ret, ret + 0);
 	 *
 	 * /---------------------------------\
 	 * |                                 |
-	 * \-> efd[0] --> efd[1] --> efd[2] -/
+	 * \- efd[0] <-- efd[1] <-- efd[2] <-/
 	 *                            | |
 	 *                            | \--> pfd[0]
 	 *                            \----> pfd[1]
@@ -227,47 +225,43 @@ label(link_pipe, ret, ret + 0);
 		goto out;
 	}
 
-	ev.events = 0;
-label(wait_write,
-	ret, epoll_wait(efd[0], &ev, 1, 1000));
-	if (ret != 1) {
-		log_error("Expected epoll_wait() to return an event.\n");
-		goto out;
-	}
-
+label(wait_write, ret, ret + 0);
 	/*
 	 * Since it's a cycle of epoll sets, we have to wait on the
 	 * other epoll sets to get the event that triggered EPOLLIN
-	 * on this set.
+	 * on this set. Start with the epoll fd which will take us the
+	 * long way around the cycle: efd[num_efd - 2].
 	 */
-	for (i = 1; i < num_efd; i++) {
-		if (!(ev.events & EPOLLIN)) {
-			log("FAIL", "Expected EPOLLIN (0x%X) flag, got %s (0x%X)\n",
-				  EPOLLOUT, eflags(ev.events), ev.events);
+
+	/* The index of the previous epoll fd in the cycle */
+	j = num_efd - 1;
+	for (i = num_efd - 2; i > -1; i--) {
+		/* The index of the previous epoll fd in the cycle */
+		j = (unsigned int)(i - 1) % ~(num_efd - 1);
+		log("INFO", "Waiting on %d for EPOLLIN on %d\n", efd[i], efd[j]);
+		ret = epoll_wait(efd[i], &ev, 1, 1000);
+		if (ret != 1) {
+			log_error("Expected epoll_wait() to return an event.\n");
 			goto out;
 		}
-		if (ev.data.fd != efd[i]) {
-			log("FAIL", "Expected event fd == %d, got %d\n",
-				  efd[i], ev.data.fd);
+		log("INFO", "Got event: fd: %d eflags: %s\n", ev.data.fd, eflags(ev.events));
+		if ((ev.data.fd != efd[j]) || !(ev.events & EPOLLIN))
 			goto out;
-		}
-		ret = epoll_wait(efd[i], &ev, 1, 1000);
 	}
+
 	/*
 	 * Now we expect the actual event indicating it's ok to write
 	 * output.
 	 */
-	if (!(ev.events & EPOLLOUT)) {
-		log("FAIL", "Expected EPOLLOUT (0x%X) flag, got %s (0x%X)\n",
-			  EPOLLOUT, eflags(ev.events), ev.events);
+	log("INFO", "Waiting on %d for EPOLLOUT on %d\n", efd[j], pfd[1]);
+	ret = epoll_wait(efd[j], &ev, 1, 1000);
+	if (ret != 1) {
+		log_error("Expected epoll_wait() to return an event.\n");
 		goto out;
 	}
-	if (ev.data.fd != pfd[1]) {
-		log("FAIL", "Expected event fd == %d, got %d\n",
-			  pfd[1], ev.data.fd);
+	log("INFO", "Got event: fd: %d eflags: %s\n", ev.data.fd, eflags(ev.events));
+	if ((ev.data.fd != pfd[1]) || !(ev.events & EPOLLOUT))
 		goto out;
-	}
-
 label(do_write,
 	ret, write(pfd[1], HELLO, strlen(HELLO) + 1));
 	if (ret < (strlen(HELLO) + 1)) {
@@ -276,22 +270,31 @@ label(do_write,
 		goto out;
 	}
 
-label(wait_read,
-	ret, epoll_wait(efd[i], &ev, 1, 1000));
+label(wait_read, ret, ret + 0);
+	/* The index of the previous epoll fd in the cycle */
+	j = num_efd - 1;
+	for (i = num_efd - 2; i > -1; i--) {
+		/* The index of the previous epoll fd in the cycle */
+		j = (unsigned int)(i - 1) % ~(num_efd - 1);
+		log("INFO", "Waiting on %d for EPOLLIN on %d\n", efd[i], efd[j]);
+		ret = epoll_wait(efd[i], &ev, 1, 1000);
+		if (ret != 1) {
+			log_error("Expected epoll_wait() to return an event.\n");
+			goto out;
+		}
+		log("INFO", "Got event: fd: %d eflags: %s\n", ev.data.fd, eflags(ev.events));
+		if ((ev.data.fd != efd[j]) || !(ev.events & EPOLLIN))
+			goto out;
+	}
+	log("INFO", "Waiting on %d for EPOLLIN on %d\n", efd[j], pfd[0]);
+	ret = epoll_wait(efd[j], &ev, 1, 1000);
 	if (ret != 1) {
 		log_error("Expected epoll_wait() to return an event.\n");
 		goto out;
 	}
-	if (!(ev.events & EPOLLIN)) {
-		log("FAIL", "Expected EPOLLIN (0x%X) flag, got %s (0x%X)\n",
-			  EPOLLIN, eflags(ev.events), ev.events);
+	log("INFO", "Got event: fd: %d eflags: %s\n", ev.data.fd, eflags(ev.events));
+	if ((ev.data.fd != pfd[0]) || !(ev.events & EPOLLIN))
 		goto out;
-	}
-	if (ev.data.fd != pfd[0]) {
-		log("FAIL", "Expected event fd == %d, got %d\n",
-			  pfd[0], ev.data.fd);
-		goto out;
-	}
 
 label(do_read, ret, ret + 0);
 	ret = read(pfd[0], rbuf, strlen(HELLO) + 1);
-- 
1.6.3.3


From 1780e336fa332bc750ed63d613c189dd4e674f36 Mon Sep 17 00:00:00 2001
Message-Id: <1780e336fa332bc750ed63d613c189dd4e674f36.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 14 Oct 2009 21:32:15 -0700
Subject: [PATCH 4/7] cr_tests: epoll: Avoid hitting rlimit on num file descriptors

Subtract the number of open file descriptors from the maximum number of
files the process can have open. Otherwise sk10k always fails with the
default number of sockets since we've got the log fd open.

Also:
	Cleanup option parsing
	Handle socketpair errors

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/sk10k.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/epoll/sk10k.c b/epoll/sk10k.c
index 26647a3..a79d91e 100644
--- a/epoll/sk10k.c
+++ b/epoll/sk10k.c
@@ -23,6 +23,7 @@
 #include <string.h>
 #include <limits.h>
 #include <getopt.h>
+#include <dirent.h> /* scandir() */
 
 /* open() */
 #include <sys/types.h>
@@ -50,6 +51,7 @@ void usage(FILE *pout)
 "\t-l\tWait for checkpoint at LABEL.\n"
 "\t-N\tPrint the maximum label number and exit.\n"
 "\t-n\tWait for checkpoint at NUM.\n"
+"\t-s\tNUM socket pairs to create. [Default: up to half of ulimit -n]\n"
 "\n"
 "You may only specify one LABEL or NUM and you may not specify both.\n"
 "Label numbers are integers in the range 0-%d\n"
@@ -68,11 +70,13 @@ const struct option long_options[] = {
 	{0, 0, 0, 0},
 };
 
-int num_sk = 1000;
+int num_sk = 400;
 
 void set_default_num_sk(void)
 {
 	struct rlimit lim;
+	int num_fds_open = 0;
+	struct dirent **dents;
 
 	/*
 	 * Get num_sk from hard rlimit. The goal of this default is to open
@@ -80,7 +84,17 @@ void set_default_num_sk(void)
 	 * checkpointed epoll items at one time.
 	 */
 	getrlimit(RLIMIT_NOFILE, &lim);
-	num_sk = lim.rlim_cur & ~1; /* round down to nearest multiple of 2 */
+	num_sk = lim.rlim_cur/2;
+
+	num_fds_open = scandir("/proc/self/fd", &dents, 0, alphasort);
+	if (num_fds_open < 0)
+		perror("scandir");
+	else {
+		free(dents);
+		num_fds_open -= 2;
+		num_sk -= (num_fds_open + 1)/2;
+	}
+	num_sk &= ~1; /* round down to nearest multiple of 2 */
 
 	/*
 	 * Of course if we're running as root then we may have an
@@ -90,6 +104,7 @@ void set_default_num_sk(void)
 	if (num_sk > 1000000)
 		num_sk = 1000000;
 }
+
 char *freezer = "1";
 
 void parse_args(int argc, char **argv)
@@ -209,6 +224,10 @@ label(create,
 label(open, ret, ret + 0);
 	for (i = 0; i < num_sk; i+=2) {
 		ret = socketpair(AF_UNIX, SOCK_SEQPACKET, 0, &sk[i]);
+		if (ret) {
+			log_error("socketpair");
+			goto out;
+		}
 		evs[i].data.fd = sk[i];
 		evs[i].events = EPOLLOUT;
 		evs[i + 1].data.fd = sk[i + 1];
@@ -299,7 +318,7 @@ out:
 	}
 	if (sk) {
 		for (i = 0; i < num_sk; i++) {
-			if (sk[i] >= 0) {
+			if (sk[i] > 0) {
 				close(sk[i]);
 				sk[i] = -1;
 			}
-- 
1.6.3.3


From fdadb0635616bb992d78145d2c9330eff9477a66 Mon Sep 17 00:00:00 2001
Message-Id: <fdadb0635616bb992d78145d2c9330eff9477a66.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 16 Oct 2009 20:15:24 -0700
Subject: [PATCH 5/7] cr_tests: epoll: Fix test labels

LABEL doesn't exist (empty string) -- use TLABEL

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/run.sh |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/epoll/run.sh b/epoll/run.sh
index 32b3068..bcdf394 100755
--- a/epoll/run.sh
+++ b/epoll/run.sh
@@ -70,15 +70,15 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	done
 	freeze
 	sync
-	cp log.${T} log.${T}${LABEL}.pre-ckpt
+	cp log.${T} log.${T}${TLABEL}.pre-ckpt
 	err_msg="FAIL"
-	${CHECKPOINT} ${TEST_PID} > checkpoint-${T}${LABEL}
+	${CHECKPOINT} ${TEST_PID} > checkpoint-${T}${TLABEL}
 	err_msg="BROK"
 	thaw
 	touch "./checkpoint-done"
 	wait ${TEST_PID}
 	retval=$?
-	echo "Test ${T}${LABEL} done, returned ${retval}"
+	echo "Test ${T}${TLABEL} done, returned ${retval}"
 	if [ -f "TBROK" ]; then
 		echo "BROK: epoll snafu, re-running this test"
 		continue
@@ -89,18 +89,18 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	echo "PASS ${T} ${TLABEL} original"
 
 	# now try restarting
-	mv log.${T} log.${T}${LABEL}.post-ckpt
-	cp log.${T}${LABEL}.pre-ckpt log.${T}
+	mv log.${T} log.${T}${TLABEL}.post-ckpt
+	cp log.${T}${TLABEL}.pre-ckpt log.${T}
 	err_msg="FAIL"
 	# --copy-status ensures that we trap on error.
-	${RESTART} --copy-status < checkpoint-${T}${LABEL}
+	${RESTART} --copy-status < checkpoint-${T}${TLABEL}
 	retval=$?
 	err_msg="FAIL"
 	[ ${retval} -eq 0 ];
 	echo "PASS ${T} ${TLABEL} restart"
 	err_msg="BROK"
-	if [ ! -f log.${T}${LABEL} ]; then
-		mv log.${T} log.${T}${LABEL}
+	if [ ! -f log.${T}${TLABEL} ]; then
+		mv log.${T} log.${T}${TLABEL}
 	fi
 	trap '' ERR EXIT
 
-- 
1.6.3.3


From 2337812b2325e60ec817b35476a7ec63eecceeb8 Mon Sep 17 00:00:00 2001
Message-Id: <2337812b2325e60ec817b35476a7ec63eecceeb8.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 12 Nov 2009 21:10:43 -0800
Subject: [PATCH 6/7] cr_tests: epoll: Use a proper linker script

The label-generation code relied the linker to place the first
and last labels according to the order in which they were encountered
during compilation. The linker accompanying gcc 4.4.1 breaks this
assumption, forcing us to use the nicer solution -- a proper
linker script snippet using INSERT.

Add the linker script snippet
Remove the hack-ish first/last label variables
Replace the labels() function with the labels[] array
Simplifie the num_labels macro
Move print_labels() to the header in case gcc link order
	would otherwise affect it.
Add the appropriate linker flags to LDFLAGS and use it in Make rules

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/Makefile      |    5 ++++-
 epoll/cycle.c       |   15 +++------------
 epoll/empty.c       |   19 +++++--------------
 epoll/libeptest.c   |   10 ----------
 epoll/libeptest.h   |   30 ++++++++++++++++++------------
 epoll/libeptest.lds |    9 +++++++++
 epoll/pipe.c        |   14 +++-----------
 epoll/scm.c         |    9 +++------
 epoll/sk10k.c       |    9 +++------
 9 files changed, 48 insertions(+), 72 deletions(-)
 create mode 100644 epoll/libeptest.lds

diff --git a/epoll/Makefile b/epoll/Makefile
index 08d97e5..f80e2e5 100644
--- a/epoll/Makefile
+++ b/epoll/Makefile
@@ -3,6 +3,9 @@
 LIBS := ../libcrtest/libcrtest.a ./libeptest.a
 CFLAGS := -Wall $(ARCHOPTS) -I../ -I../libcrtest
 
+# Properly generate special symbols for the labels ELF section
+LDFLAGS :=  -Xlinker -dT -Xlinker ./libeptest.lds
+
 PROGS=empty pipe sk10k cycle scm
 
 .PHONY: all clean
@@ -16,7 +19,7 @@ libeptest.a: libeptest.o libeptest.h
 	ar cr libeptest.a libeptest.o
 
 $(PROGS): %: %.c $(LIBS)
-	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS)
+	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS) $(LDFLAGS)
 
 clean:
 	rm -f $(PROGS) libeptest.[ao]
diff --git a/epoll/cycle.c b/epoll/cycle.c
index 32ffb4c..13e11b5 100644
--- a/epoll/cycle.c
+++ b/epoll/cycle.c
@@ -62,8 +62,8 @@ char *freezer = "1";
 
 void parse_args(int argc, char **argv)
 {
-	ckpt_label = last_label;
-	ckpt_op_num = num_labels;
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
 	while (1) {
 		int c;
 		c = getopt_long(argc, argv, "f:LNhl:n:s:c:", long_options, NULL);
@@ -121,13 +121,6 @@ void parse_args(int argc, char **argv)
 	}
 }
 
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
-
 int main(int argc, char **argv)
 {
 	char rbuf[128];
@@ -316,7 +309,7 @@ label(do_read, ret, ret + 0);
 out:
 	if (op_num != INT_MAX) {
 		log("FAIL", "error at label %s (op num: %d)\n",
-			  labels(op_num), op_num);
+			  labels[op_num], op_num);
 	}
 	for (i = 0; i < num_efd; i++) {
 		ret = close(efd[i]);
@@ -332,5 +325,3 @@ out:
 	fclose(logfp);
 	exit(ec);
 }
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/empty.c b/epoll/empty.c
index f02c63a..a1a97d3 100644
--- a/epoll/empty.c
+++ b/epoll/empty.c
@@ -37,7 +37,7 @@ void usage(FILE *pout)
 "\t-n\tWait for checkpoint at NUM.\n"
 "\n"
 "You may only specify one LABEL or NUM and you may not specify both.\n"
-"Label numbers are integers in the range 0-%ld\n"
+"Label numbers are integers in the range 0-%d\n"
 "Valid label numbers and their corresponding LABELs are:\n", num_labels - 1);
 	print_labels(pout);
 }
@@ -56,8 +56,8 @@ char *freezer = "1";
 
 void parse_args(int argc, char **argv)
 {
-	ckpt_label = last_label;
-	ckpt_op_num = num_labels;
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
 	while (1) {
 		int c;
 		c = getopt_long(argc, argv, "f:LNhl:n:", long_options, NULL);
@@ -73,7 +73,7 @@ void parse_args(int argc, char **argv)
 				exit(EXIT_SUCCESS);
 				break;
 			case 'N':
-				printf("%ld\n", num_labels - 1);
+				printf("%d\n", num_labels - 1);
 				exit(EXIT_SUCCESS);
 				break;
 			case 'h':
@@ -87,7 +87,7 @@ void parse_args(int argc, char **argv)
 				if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
 				    (ckpt_op_num < 0) ||
 				    (ckpt_op_num >= num_labels)) {
-					fprintf(stderr, "Option -n requires an argument in the range 0-%ld. Got %d\n", num_labels - 1, ckpt_op_num);
+					fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
 					usage(stderr);
 					exit(EXIT_FAILURE);
 				}
@@ -98,13 +98,6 @@ void parse_args(int argc, char **argv)
 	}
 }
 
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
-
 int main (int argc, char **argv)
 {
 	int efd, ret = 0;
@@ -151,5 +144,3 @@ out:
 	fclose(logfp);
 	exit(EXIT_SUCCESS);
 }
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/libeptest.c b/epoll/libeptest.c
index 20cf7e2..b21548e 100644
--- a/epoll/libeptest.c
+++ b/epoll/libeptest.c
@@ -44,16 +44,6 @@ const char * eflags(unsigned int events)
 }
 #undef peflag
 
-void print_labels(FILE *pout)
-{
-	int i;
-
-	if (num_labels > 0)
-		fprintf(pout, "\tNUM\tLABEL\n");
-	for (i = 0; i < num_labels; i++)
-		fprintf(pout, "\t%d\t%s\n", i, labels(i));
-}
-
 /* Signal ready for and await the checkpoint */
 void do_ckpt(void)
 {
diff --git a/epoll/libeptest.h b/epoll/libeptest.h
index 4854062..999cedd 100644
--- a/epoll/libeptest.h
+++ b/epoll/libeptest.h
@@ -35,37 +35,43 @@ const char * eflags(unsigned int events);
  * checkpoint. These enable us to have a set of labels that can be specified
  * on the commandline.
  */
-extern const char __attribute__((__section__(".LABELs"))) *first_label;
-extern const char __attribute__((__section__(".LABELs"))) *last_label;
+extern const char *labels[];
+extern const char *___labels_end[];
 
-#define num_labels ((&last_label - &first_label) - 1)
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+extern char const *ckpt_label;
+extern int ckpt_op_num;
 
-static inline const char * labels(int i)
+/*#define num_labels ((&last_label - &first_label) - 1)*/
+#define num_labels ((int)(___labels_end - labels))
+
+/* Print the labels that this program has to pout */
+static inline void print_labels(FILE *pout)
 {
-	return (&first_label)[num_labels - i];
+	int i;
+
+	if (num_labels > 0)
+		fprintf(pout, "\tNUM\tLABEL\n");
+	for (i = 0; i < num_labels; i++)
+		fprintf(pout, "\t%d\t%s\n", i, labels[i]);
 }
 
-/* Print the labels that this program has to pout */
-void print_labels(FILE *pout);
 
 /* Signal ready for and await the checkpoint */
 void do_ckpt(void);
 
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-extern char const *ckpt_label;
-extern int ckpt_op_num;
 
 #define stringify(expr) #expr
 
 /* Label a spot in the code... */
 #define label(lbl, ret, action) \
 do { \
-	static char __attribute__((__section__(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
+	static char __attribute__((section(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
 	goto lbl ; \
 lbl: \
 \
         log("INFO", "label: %s: \"%s\"\n", \
-		    labels(op_num), stringify(action)); \
+		    labels[op_num], stringify(action)); \
 \
 	ret = action ; \
 \
diff --git a/epoll/libeptest.lds b/epoll/libeptest.lds
new file mode 100644
index 0000000..a083bde
--- /dev/null
+++ b/epoll/libeptest.lds
@@ -0,0 +1,9 @@
+SECTIONS {
+	. = ALIGN(8);
+	LABELs : {
+		labels = . ;
+		*(.LABELs);
+		___labels_end = . ;
+	}
+}
+INSERT BEFORE .data ;
diff --git a/epoll/pipe.c b/epoll/pipe.c
index 12bd10c..b84a43c 100644
--- a/epoll/pipe.c
+++ b/epoll/pipe.c
@@ -63,8 +63,8 @@ char *freezer = "1";
 
 void parse_args(int argc, char **argv)
 {
-	ckpt_label = last_label;
-	ckpt_op_num = num_labels;
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
 	while (1) {
 		int c;
 		c = getopt_long(argc, argv, "f:LNhl:n:", long_options, NULL);
@@ -104,12 +104,6 @@ void parse_args(int argc, char **argv)
 	}
 }
 
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
 int main(int argc, char **argv)
 {
 	struct epoll_event ev[2] = {
@@ -229,7 +223,7 @@ out:
 	}
 	if (op_num != INT_MAX) {
 		log("FAIL", "error at label %s (op num: %d)\n",
-			  labels(op_num), op_num);
+			  labels[op_num], op_num);
 	}
 	close(tube[0]);
 	close(tube[1]);
@@ -237,5 +231,3 @@ out:
 	fclose(logfp);
 	exit(ec);
 }
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/scm.c b/epoll/scm.c
index e7359d0..ca2c631 100644
--- a/epoll/scm.c
+++ b/epoll/scm.c
@@ -70,8 +70,8 @@ char *freezer = "1";
 
 void parse_args(int argc, char **argv)
 {
-	ckpt_label = last_label;
-	ckpt_op_num = num_labels;
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
 	while (1) {
 		int c;
 		c = getopt_long(argc, argv, "f:LNhl:n:c::", long_options, NULL);
@@ -124,7 +124,6 @@ void parse_args(int argc, char **argv)
  * checkpoint. These enable us to have a set of labels that can be specified
  * on the commandline.
  */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
 int main(int argc, char **argv)
 {
 	struct epoll_event ev[2] = {
@@ -342,7 +341,7 @@ out:
 	}
 	if (op_num != INT_MAX) {
 		log("FAIL", "error at label %s (op num: %d)\n",
-			  labels(op_num), op_num);
+			  labels[op_num], op_num);
 	}
 	close(tube[0]);
 	close(tube[1]);
@@ -350,5 +349,3 @@ out:
 	fclose(logfp);
 	exit(ec);
 }
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/sk10k.c b/epoll/sk10k.c
index a79d91e..f1a534b 100644
--- a/epoll/sk10k.c
+++ b/epoll/sk10k.c
@@ -109,8 +109,8 @@ char *freezer = "1";
 
 void parse_args(int argc, char **argv)
 {
-	ckpt_label = last_label;
-	ckpt_op_num = num_labels;
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
 
 	set_default_num_sk();
 
@@ -172,7 +172,6 @@ void parse_args(int argc, char **argv)
 	}
 }
 
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
 int main(int argc, char **argv)
 {
 	char rbuf[128];
@@ -314,7 +313,7 @@ out:
 	}
 	if (op_num != INT_MAX) {
 		log("FAIL", "error at label %s (op num: %d)\n",
-			  labels(op_num), op_num);
+			  labels[op_num], op_num);
 	}
 	if (sk) {
 		for (i = 0; i < num_sk; i++) {
@@ -331,5 +330,3 @@ out:
 	fclose(logfp);
 	exit(ec);
 }
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
-- 
1.6.3.3


From 8c275fcd55dae4ed82f6ced29e2720386a581387 Mon Sep 17 00:00:00 2001
Message-Id: <8c275fcd55dae4ed82f6ced29e2720386a581387.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <0495bb8c54f2201e57473268c80f92cce0847d38.1258094725.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 12 Nov 2009 21:59:01 -0800
Subject: [PATCH 7/7] cr_tests: epoll: Factor out label code

Label generation code is common between my epoll, eventfd, and soon
unlinked file/dir/etc. code. Factor it out for re-use amongst these
tests by putting it in libcrtest/.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/Makefile        |    8 ++++--
 epoll/libeptest.c     |    4 ---
 epoll/libeptest.h     |   57 +---------------------------------------------
 epoll/libeptest.lds   |    9 -------
 libcrtest/Makefile    |   14 +++++-----
 libcrtest/labels.c    |    6 +++++
 libcrtest/labels.h    |   61 +++++++++++++++++++++++++++++++++++++++++++++++++
 libcrtest/labels.lds  |    9 +++++++
 libcrtest/libcrtest.h |    4 +++
 9 files changed, 93 insertions(+), 79 deletions(-)
 delete mode 100644 epoll/libeptest.lds
 create mode 100644 libcrtest/labels.c
 create mode 100644 libcrtest/labels.h
 create mode 100644 libcrtest/labels.lds

diff --git a/epoll/Makefile b/epoll/Makefile
index f80e2e5..7267ac5 100644
--- a/epoll/Makefile
+++ b/epoll/Makefile
@@ -4,7 +4,7 @@ LIBS := ../libcrtest/libcrtest.a ./libeptest.a
 CFLAGS := -Wall $(ARCHOPTS) -I../ -I../libcrtest
 
 # Properly generate special symbols for the labels ELF section
-LDFLAGS :=  -Xlinker -dT -Xlinker ./libeptest.lds
+LDFLAGS :=  -Xlinker -dT -Xlinker ../libcrtest/labels.lds
 
 PROGS=empty pipe sk10k cycle scm
 
@@ -15,8 +15,10 @@ all: $(PROGS)
 ../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
 	$(MAKE) -C ../libcrtest libcrtest.a
 
-libeptest.a: libeptest.o libeptest.h
-	ar cr libeptest.a libeptest.o
+libeptest.o: libeptest.h
+
+libeptest.a: libeptest.o
+	ar cr $@ $<
 
 $(PROGS): %: %.c $(LIBS)
 	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS) $(LDFLAGS)
diff --git a/epoll/libeptest.c b/epoll/libeptest.c
index b21548e..95b42f8 100644
--- a/epoll/libeptest.c
+++ b/epoll/libeptest.c
@@ -52,7 +52,3 @@ void do_ckpt(void)
 		usleep(10000);
 
 }
-
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-char const *ckpt_label;
-int ckpt_op_num = 0;
diff --git a/epoll/libeptest.h b/epoll/libeptest.h
index 999cedd..990412d 100644
--- a/epoll/libeptest.h
+++ b/epoll/libeptest.h
@@ -6,6 +6,7 @@
 #include <sys/epoll.h>
 
 #include "libcrtest/libcrtest.h"
+#include "libcrtest/labels.h"
 
 extern FILE *logfp;
 
@@ -30,60 +31,4 @@ do { \
 /* Non-reentrant!! */
 const char * eflags(unsigned int events);
 
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-extern const char *labels[];
-extern const char *___labels_end[];
-
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-extern char const *ckpt_label;
-extern int ckpt_op_num;
-
-/*#define num_labels ((&last_label - &first_label) - 1)*/
-#define num_labels ((int)(___labels_end - labels))
-
-/* Print the labels that this program has to pout */
-static inline void print_labels(FILE *pout)
-{
-	int i;
-
-	if (num_labels > 0)
-		fprintf(pout, "\tNUM\tLABEL\n");
-	for (i = 0; i < num_labels; i++)
-		fprintf(pout, "\t%d\t%s\n", i, labels[i]);
-}
-
-
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void);
-
-
-#define stringify(expr) #expr
-
-/* Label a spot in the code... */
-#define label(lbl, ret, action) \
-do { \
-	static char __attribute__((section(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
-	goto lbl ; \
-lbl: \
-\
-        log("INFO", "label: %s: \"%s\"\n", \
-		    labels[op_num], stringify(action)); \
-\
-	ret = action ; \
-\
-	if ((ckpt_op_num == op_num) || \
-	    (strcmp(ckpt_label, ___ ##lbl## _l) == 0)) \
-		do_ckpt(); \
-	if (ret < 0) { \
-		log("FAIL", "%d\t%s: %s\n", \
-		    op_num, ___ ##lbl## _l, stringify(action) ); \
-		goto out; \
-	} \
-	op_num++; \
-} while(0)
-
 #define HELLO "Hello world!\n"
diff --git a/epoll/libeptest.lds b/epoll/libeptest.lds
deleted file mode 100644
index a083bde..0000000
--- a/epoll/libeptest.lds
+++ /dev/null
@@ -1,9 +0,0 @@
-SECTIONS {
-	. = ALIGN(8);
-	LABELs : {
-		labels = . ;
-		*(.LABELs);
-		___labels_end = . ;
-	}
-}
-INSERT BEFORE .data ;
diff --git a/libcrtest/Makefile b/libcrtest/Makefile
index de9e36f..1181fe3 100644
--- a/libcrtest/Makefile
+++ b/libcrtest/Makefile
@@ -1,11 +1,11 @@
+TARGETS := libcrtest.a
+all: $(TARGETS)
 
-all: libcrtest.a
+common.o: libcrtest.h
+labels.o: labels.h
 
-common.o: libcrtest.h common.c
-	cc $(CFLAGS) -c common.c
-
-libcrtest.a: common.o
-	ar cr libcrtest.a common.o
+libcrtest.a: common.o labels.o
+	ar cr $@ $^
 
 clean:
-	rm -f common.o libcrtest.a
+	rm -f *.o $(TARGETS)
diff --git a/libcrtest/labels.c b/libcrtest/labels.c
new file mode 100644
index 0000000..a64e1c8
--- /dev/null
+++ b/libcrtest/labels.c
@@ -0,0 +1,6 @@
+#include "labels.h"
+
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+char const *ckpt_label = NULL;
+int ckpt_op_num = 0;
+
diff --git a/libcrtest/labels.h b/libcrtest/labels.h
new file mode 100644
index 0000000..f0137dc
--- /dev/null
+++ b/libcrtest/labels.h
@@ -0,0 +1,61 @@
+#ifndef LIBCRTEST_LABELS_H
+#define LIBCRTEST_LABELS_H 1
+#include <stdio.h>
+
+/*
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
+ */
+extern const char *labels[];
+extern const char *___labels_end[];
+
+extern int op_num; /* current operation count */
+
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+extern char const *ckpt_label; /* label to checkpoint at */
+extern int ckpt_op_num; /* op_num to checkpoint at. -1 -> all */
+
+/*#define num_labels ((&last_label - &first_label) - 1)*/
+#define num_labels ((int)(___labels_end - labels))
+
+/* Print the labels that this program has to pout */
+static inline void print_labels(FILE *pout)
+{
+	int i;
+
+	if (num_labels > 0)
+		fprintf(pout, "\tNUM\tLABEL\n");
+	for (i = 0; i < num_labels; i++)
+		fprintf(pout, "\t%d\t%s\n", i, labels[i]);
+}
+
+/* Signal ready for and await the checkpoint. */
+extern void do_ckpt(void);
+
+#define stringify(expr) #expr
+
+/* Label a spot in the code. TODO: Find a nicer way to do "out" */
+#define label(lbl, ret, action) \
+do { \
+	static char __attribute__((section(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
+	goto lbl ; \
+lbl: \
+\
+        fprintf(logfp, "INFO: label: %s: \"%s\"\n", \
+		    labels[op_num], stringify(action)); \
+\
+	ret = action ; \
+\
+	if ((ckpt_op_num == op_num) || (ckpt_op_num == -1) || \
+	    (strcmp(ckpt_label, ___ ##lbl## _l) == 0)) \
+		do_ckpt(); \
+	if (ret < 0) { \
+		fprintf(logfp, "FAIL: %d\t%s: %s\n", \
+		    op_num, ___ ##lbl## _l, stringify(action) ); \
+		goto out ; \
+	} \
+	op_num++; \
+} while(0)
+
+#endif /* LIBCRTEST_LABELS_H */
diff --git a/libcrtest/labels.lds b/libcrtest/labels.lds
new file mode 100644
index 0000000..a083bde
--- /dev/null
+++ b/libcrtest/labels.lds
@@ -0,0 +1,9 @@
+SECTIONS {
+	. = ALIGN(8);
+	LABELs : {
+		labels = . ;
+		*(.LABELs);
+		___labels_end = . ;
+	}
+}
+INSERT BEFORE .data ;
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index abc192f..a42c178 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -1,3 +1,5 @@
+#ifndef LIBCRTEST_H
+#define LIBCRTEST_H 1
 
 #define CKPT_READY		"checkpoint-ready"
 #define CKPT_DONE		"checkpoint-done"
@@ -20,3 +22,5 @@ extern void copy_data(char *srcfile, char *destfile);
 extern char *freezer_mountpoint(void);
 /* right now, subsys must always be "freezer" */
 extern int move_to_cgroup(char *subsys, char *grp, int pid);
+
+#endif /* LIBCRTEST_H */
-- 
1.6.3.3
