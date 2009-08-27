From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] smack: introduce some simple tests for smack task
	label c/r
Date: Thu, 27 Aug 2009 16:45:04 -0500
Message-ID: <20090827214503.GA28551@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

(these tests aren't run by default, so I went ahead and applied
them even though the smack c/r patchset isn't applied on the kernel
yet.)

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 smack/.runtest.sh.swp |  Bin 0 -> 12288 bytes
 smack/Makefile        |    8 +++++
 smack/README          |    7 +++++
 smack/ckpt.c          |   67 ++++++++++++++++++++++++++++++++++++++++++++++
 smack/runtest.sh      |   71 +++++++++++++++++++++++++++++++++++++++++++++++++
 smack/smackpolicy     |    6 ++++
 6 files changed, 159 insertions(+), 0 deletions(-)
 create mode 100644 smack/.runtest.sh.swp
 create mode 100644 smack/Makefile
 create mode 100644 smack/README
 create mode 100644 smack/ckpt.c
 create mode 100644 smack/runtest.sh
 create mode 100644 smack/smackpolicy

diff --git a/smack/.runtest.sh.swp b/smack/.runtest.sh.swp
new file mode 100644
index 0000000000000000000000000000000000000000..6f0cdce4c6c976e8fe5041a820ebb4e025038727
GIT binary patch
literal 12288
zcmeI2OK2oT7{@D$U}lpjdep<0Nz`4n=OyAAH);}BjoG-8ta?}_sr1yOoAh+`R@G!S
z*<BUAco96Q2T^<-e6X-6;z`h(2ake}i&s5(5(Po<U)|H4nXJ1TVLdEV!;kLjuKFJT
z`l?`tTB|)Zzex8~Y7E!)jJ@~wYmc3MX^5>%Fs7t5_VuN%D2zMX^?Ietjh1mGTx(Z+
z**<^NbJk$hS1U$nqpP~j{f(;X#I{+{!TAH+8>fI%;PNQYF)i=lXlkogZ`?)W<%t_^
zeDd<xc2=AMP64NYQ@|<U6mSYS1)Ks-fh$6R#IPaud=ctZy{AWd_aWRZ?s5t^1)Ks-
z0jGddz$xGqa0)mDoB~b(r+`!73Ra-WZSdFr##rgr^Z-DX3x5A!_dECjd=0(=pMtl+
z%b*F4gQvkPxC30x*w|m-5AZYi27CbC1aE*B!3zNYHjHh6XTVYLICu!m0oWP4ow3oM
zz!%_S@DUIIenuPMX2wQ-1)qUWz=z;{03Rc-1N0qP0*63}v3=ixFTv*kIqW+N-UaV~
zS3nm$2o8d~p~Ei#wo7jT<X1wBr6XVgcmO(;ZUNT-s5Sg2_z`>y&Vg3}`VQX&UB3s=
z!Cg)Pr+`zyDc}@v3j99`h?AkA8WVmXsXQ~-iXuu+8&Z1mkP@!7XqFjkg={$OS;svc
z`0&j9ktym5dkq-OOcXEkkNF*g`yLU%e|HJ5s<5ABks5(rYkKF_m*$|Cfd~c~yTd6y
zrVm9cm2S|c73<%k!r9HetC^-oJc?vjG|5O(IPxi#AYbD2=Sf4|&;+t$$mhulj)ku9
zW;=|_ENsznntXsfae`{}?0sYc5wl73(gAs1Q^{m{U<h84=hNh=#f4)_hYz12Z-WjI
zEcfc-82pCuI&}j9Q;HH5ZibOq7Zhp)b)plhEI=&`8Ll^q2xXiG&6O$dlua!!n=GPO
z8VX}=kf><hNw$gOt+90oZxnG2qllm{u~_samRgx!?FOMASSfU{%6fr6F|)i}W+vd>
z9q&ca?(cF<lRYgDl=GmnT5g8TERtQ4Z|XYrCzWdLZBscnR3;BAX{R+lO=S!!7xU0_
zIKAp~%v?5;tL&oMQ)3E=#i)nfC7=g_*-O@g>9u(n8;}P=o4PSza*z2n_MTr~VOeMQ
zQ#Dc2uWAvss@xb=^*c(5xWD$OK1En<SrPUm)5Nh7^7v7HYg^P5E#8StmVil%j#aAu
zMq=QmC}%r`m-0HN1W!wzlOG6JkkE<3Hb>2ObXuDIWo}Kjq{1gGiP$dLY?WiPRBiHF
zgea7kp4hhQ)rP{-tu>MyKMFU63R_z%2{(bx8!hZ=+d?rdJIWVSfd$!a<Dj@b@_i;R
z)<j03zeU!J-I|B()?Dn(z0G-c>F5ILM|PrSe49!8QZ^0)ioIfBNe$cDOatsWI8BrK
zV%C#LV8hFoaW>Qjbzu)WU$KP_t9x+JmN@vHnQ!R}8_&9(rgbHftT!v%>_0%K7@MG(
x4mM9UMax2AQXj>fZN+#!CzCA|t_Ox1wc5QjKf8!mDyguE@#<O_SJyZu;2-#vq-p>F

literal 0
HcmV?d00001

diff --git a/smack/Makefile b/smack/Makefile
new file mode 100644
index 0000000..5377520
--- /dev/null
+++ b/smack/Makefile
@@ -0,0 +1,8 @@
+targets = ckpt
+
+all: $(targets)
+
+ckpt: ckpt.c ../cr.h
+
+clean:
+	rm -f $(targets) out context cr-test.out
diff --git a/smack/README b/smack/README
new file mode 100644
index 0000000..05d3a93
--- /dev/null
+++ b/smack/README
@@ -0,0 +1,7 @@
+This test is only for smack-enabled kernels.  It does a few
+sanity checks to test whether task contexts are properly
+restored, are restored only if requested, and ar restored only
+if permitted.
+
+Restoration of smack labels on other objects (esp. ipc objects)
+remains a TODO.
diff --git a/smack/ckpt.c b/smack/ckpt.c
new file mode 100644
index 0000000..ff47982
--- /dev/null
+++ b/smack/ckpt.c
@@ -0,0 +1,67 @@
+/*
+ * Copyright (C) 2008 Oren Laadan
+ */
+
+#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <asm/unistd.h>
+#include <sys/syscall.h>
+#include "../cr.h"
+
+#define OUTFILE "./cr-test.out"
+
+int main(int argc, char *argv[])
+{
+	pid_t pid = getpid();
+	FILE *file;
+	int ret;
+	int n;
+	char ctx[200];
+
+	close(0);
+	close(2);
+
+	unlink(OUTFILE);
+	file = fopen(OUTFILE, "w+");
+	if (!file) {
+		perror("open");
+		exit(1);
+	}
+
+	if (dup2(0,2) < 0) {
+		perror("dups");
+		exit(1);
+	}
+
+	fprintf(file, "hello, world!\n");
+	fflush(file);
+
+	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, CHECKPOINT_SUBTREE);
+	if (ret < 0) {
+		perror("checkpoint");
+		exit(2);
+	}
+
+	fprintf(file, "world, hello!\n");
+	fprintf(file, "ret = %d\n", ret);
+	fflush(file);
+	file = fopen("/proc/self/attr/current", "r");
+	if (!file)
+		return 1;
+	n = fread(ctx, 1, 200, file);
+	fclose(file);
+	file = fopen("./context", "w");
+	if (!file)
+		return 1;
+	fwrite(ctx, 1, n, file);
+	fclose(file);
+
+	return 0;
+}
+
diff --git a/smack/runtest.sh b/smack/runtest.sh
new file mode 100644
index 0000000..c36ca9b
--- /dev/null
+++ b/smack/runtest.sh
@@ -0,0 +1,71 @@
+#!/bin/bash
+# Copyright 2009 IBM Corp.
+# Author: Serge Hallyn
+
+smackload() {
+	mount | grep smack
+	if [ $? -ne 0 ]; then
+		echo "BROK: please mount smackfs"
+		exit 1
+	fi
+	s=`which smackload`
+	if [ $? -ne 0 ]; then
+		echo "BROK: please install smackload"
+		exit 1
+	fi
+	cat smackpolicy | $s
+	if [ $? -ne 0 ]; then
+		echo "BROK: couldn't load policy"
+		exit 1
+	fi
+	echo "policy loaded"
+}
+
+source ../common.sh
+verify_freezer
+verify_paths
+
+smackload
+
+rm -f ./cr-test.out out
+
+echo "Creating a checkpoint image using task context vs1 for use in all tests"
+echo vs1 > /proc/self/attr/current
+./ckpt > out
+
+echo "Test 1: existing contexts are maintained by default on retart"
+echo vs2 > /proc/self/attr/current
+${MKTREE} < out
+context=`cat context`
+if [ -z "$context" -o "$context" != "vs2" ]; then
+	echo "FAIL: did not maintain context vs2 on restart"
+	exit 1
+fi
+thaw
+echo "PASS"
+
+echo "Test 2: can we restore contexts on restart"
+${MKTREE} -k < out
+context=`cat context`
+if [ -z "$context" -o "$context" != "vs1" ]; then
+	echo "FAIL: did not restore context vs1 on restart"
+	echo "(was $context)"
+	exit 1
+fi
+thaw
+echo "PASS"
+
+capsh=`which capsh`
+if [ $? -ne 0 ]; then
+	echo "capsh not installed, not running the last test"
+	exit 0
+fi
+echo "Testing whether privilege is required to set task context on restart"
+$capsh --drop=cap_mac_admin -- -c ${MKTREE} -k < out
+if [ $? -eq 0 ]; then
+	echo "FAIL: we were allowed to restore context without cap_mac_admin"
+	exit 1
+fi
+
+echo "All smack tests passed"
+exit 0
diff --git a/smack/smackpolicy b/smack/smackpolicy
new file mode 100644
index 0000000..ed0d471
--- /dev/null
+++ b/smack/smackpolicy
@@ -0,0 +1,6 @@
+vs1 _ rwax
+_ vs1 rwax
+vs2 vs1 rwax
+vs1 vs2 rwax
+vs2 _ rwax
+_ vs2 rwax
-- 
1.6.1.1
