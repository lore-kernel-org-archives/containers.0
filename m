From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/10] cr_tests: eventfd: Entirely new eventfd testcase
Date: Mon, 15 Mar 2010 16:01:05 -0700
Message-ID: <54f3b58880621b4bcf2ae094e755dcfa5c87390f.1268694050.git.matthltc@us.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
	<e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc@us.ibm.com>
	<5b1bb7d32f49f39912aceddc22139fdb342d699f.1268694050.git.matthltc@us.ibm.com>
	<8bf27318f6f59bc4c03f21121f03995cbb4ce593.1268694050.git.matthltc@us.ibm.com>
	<9c200071918fda28567d801a2af825d36caa208a.1268694050.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9c200071918fda28567d801a2af825d36caa208a.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Replace the existing eventfd01.c testcase with a simpler case which
does simple blocking and non-blocking reads and writes of the event
file.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Passes ckpt-v19-dev on x86-32. A subsequent patch will cause runall.sh
to execute this testcase.
---
 eventfd/Makefile    |   24 +--
 eventfd/eventfd01.c |  899 ---------------------------------------------------
 eventfd/libeptest.c |   16 -
 eventfd/libeptest.h |    4 -
 eventfd/module.mk   |   13 +
 eventfd/run.sh      |    2 +-
 eventfd/rw.c        |  215 ++++++++++++
 7 files changed, 232 insertions(+), 941 deletions(-)
 delete mode 100644 eventfd/eventfd01.c
 create mode 100644 eventfd/module.mk
 create mode 100644 eventfd/rw.c

diff --git a/eventfd/Makefile b/eventfd/Makefile
index 1bcd587..22c194e 100644
--- a/eventfd/Makefile
+++ b/eventfd/Makefile
@@ -1,23 +1,5 @@
-LTPROOT ?= ../ltp
 
-LIBS := ../libcrtest/libcrtest.a ./libeptest.a $(LTPROOT)/lib/libltp.a
-CFLAGS := -Wall $(ARCHOPTS) -I../ -I../libcrtest -I$(LTPROOT)/include
+.DEFAULT_GOAL := all
 
-PROGS=eventfd01
-
-.PHONY: all clean
-
-all: $(PROGS)
-
-../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
-	$(MAKE) -C ../libcrtest libcrtest.a
-
-libeptest.a: libeptest.o libeptest.h
-	$(AR) cr libeptest.a libeptest.o
-
-$(PROGS): %: %.c $(LIBS)
-	$(CC) -Wall $(CFLAGS) -o $@ $< $(LIBS)
-
-clean:
-	rm -f *.o libeptest.a $(PROGS)
-	rm -rf cr_eventfd*
+%:
+	$(MAKE) -C ../ $@
diff --git a/eventfd/eventfd01.c b/eventfd/eventfd01.c
deleted file mode 100644
index 3d9aa6f..0000000
--- a/eventfd/eventfd01.c
+++ /dev/null
@@ -1,899 +0,0 @@
-/*
- *   Adapted for use as a checkpoint/restart testcase by
- *   				Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
- *
- *   Based on testcases/kernel/syscalls/eventfd01/eventfd01.c by:
- *   Copyright (c) 2008 Vijay Kumar B. <vijaykumar-NDm7FNP0skFg9hUCZPvPmw@public.gmane.org>
- *
- *   Based on testcases/kernel/syscalls/waitpid/waitpid01.c
- *   Original copyright message:
- *
- *   Copyright (c) International Business Machines  Corp., 2001
- *
- *   This program is free software;  you can redistribute it and/or modify
- *   it under the terms of the GNU General Public License as published by
- *   the Free Software Foundation; either version 2 of the License, or
- *   (at your option) any later version.
- *
- *   This program is distributed in the hope that it will be useful,
- *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
- *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
- *   the GNU General Public License for more details.
- *
- *   You should have received a copy of the GNU General Public License
- *   along with this program;  if not, write to the Free Software
- *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- */
-
-/*
- * NAME
- *	eventfd01.c
- *
- * DESCRIPTION
- *      Test cases for eventfd syscall.
- *
- * USAGE:  <for command-line>
- *      eventfd01 [-c n] [-i n] [-I x] [-P x] [-t]
- *      where,  -c n : Run n copies concurrently.
- *              -i n : Execute test n times.
- *              -I x : Execute test for x seconds.
- *              -P x : Pause for x seconds between iterations.
- *              -t   : Turn on syscall timing.
- *
- * History
- *	07/2008 Vijay Kumar
- *		Initial Version.
- *
- * Restrictions
- *	None
- */
-
-#include "config.h"
-
-#include <sys/select.h>
-#include <sys/signal.h>
-#include <sys/types.h>
-#include <sys/wait.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <errno.h>
-#include <string.h>
-#include <stdint.h>
-#include <inttypes.h>
-#include <poll.h>
-
-#include <test.h>
-#include <usctest.h>
-#include <linux_syscall_numbers.h>
-
-#ifdef HAVE_LIBAIO_H
-#include <libaio.h>
-#endif
-
-#define LOG_FILE "log.eventfd01"
-#include "libeptest.h"
-
-static void setup(void);
-static void cleanup(void);
-
-TCID_DEFINE(eventfd01);
-int TST_TOTAL = 15;
-extern int Tst_count;
-
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
-int op_num = 0;
-
-static int myeventfd(unsigned int initval, int flags)
-{
-	/* eventfd2 uses FLAGS but eventfd doesn't take FLAGS. */
-#if defined (__NR_eventfd)
-	return syscall(__NR_eventfd, initval);
-#else
-	errno = ENOSYS;
-	return -1;
-#endif
-}
-
-/*
- * clear_counter() - clears the counter by performing a dummy read
- * @fd: the eventfd
- *
- * RETURNS:
- * 0 on success, and -1 on failure
- */
-static int clear_counter(int fd)
-{
-	uint64_t dummy;
-	int ret;
-
-	ret = read(fd, &dummy, sizeof(dummy));
-	if (ret == -1) {
-		if (errno != EAGAIN) {
-			tst_resm(TINFO|TERRNO, "error clearing counter");
-			return -1;
-		}
-	}
-
-	return 0;
-}
-
-/*
- * set_counter() - sets the count to specified value
- * @fd: the eventfd
- * @val: the value to be set
- *
- * Clears the counter and sets the counter to @val.
- *
- * RETURNS:
- * 0 on success, -1 on failure
- */
-static int set_counter(int fd, uint64_t val)
-{
-	int ret;
-
-	ret = clear_counter(fd);
-	if (ret == -1) {
-		return -1;
-	}
-
-	ret = write(fd, &val, sizeof(val));
-	if (ret == -1) {
-		tst_resm(TINFO|TERRNO, "error setting counter value");
-		return -1;
-	}
-
-	return 0;
-}
-
-/*
- * Test whether the current value of the counter matches @required.
- */
-static void read_test(int fd, uint64_t required)
-{
-	int ret;
-	uint64_t val;
-
-
-label(read_test, ret, read(fd, &val, sizeof(val)));
-	if (ret == -1) {
-		tst_resm(TBROK|TERRNO, "error reading eventfd");
-		return;
-	}
-
-	if (val == required)
-		tst_resm(TPASS, "counter value matches required");
-	else
-		tst_resm(TFAIL, "counter value mismatch: "
-			 "required: %"PRIu64", got: %"PRIu64, required, val);
-}
-
-/*
- * Test whether read returns with error EAGAIN when counter is at 0.
- */
-static void read_eagain_test(int fd)
-{
-	int ret;
-	uint64_t val;
-
-label(read_eagain_test_clear, ret, clear_counter(fd));
-	if (ret == -1) {
-		tst_resm(TBROK, "error clearing counter");
-		return;
-	}
-
-label(read_eagain_test_read, ret, read(fd, &val, sizeof(val)));
-	if (ret == -1) {
-		if (errno == EAGAIN)
-			tst_resm(TPASS, "read failed with EAGAIN as expected");
-		else
-			tst_resm(TFAIL|TERRNO, "read failed (wanted EAGAIN)");
-	} else {
-		tst_resm(TFAIL, "read returned with %d", ret);
-	}
-}
-
-/*
- * Test whether writing to counter works.
- */
-static void write_test(int fd)
-{
-	int ret;
-	uint64_t val;
-
-	val = 12;
-
-label(write_test, ret, set_counter(fd, val));
-	if (ret == -1) {
-		tst_resm(TBROK, "error setting counter value to %"PRIu64, val);
-		return;
-	}
-
-	read_test(fd, val);
-}
-
-/*
- * Test whether write returns with error EAGAIN when counter is at
- * (UINT64_MAX - 1).
- */
-static void write_eagain_test(int fd)
-{
-	int ret;
-	uint64_t val;
-
-label(write_eagain_test_set, ret, set_counter(fd, UINT64_MAX - 1));
-	if (ret == -1) {
-		tst_resm(TBROK, "error setting counter value to UINT64_MAX-1");
-		return;
-	}
-
-	val = 1;
-label(write_eagain_write, ret, write(fd, &val, sizeof(val)));
-	if (ret == -1) {
-		if (errno == EAGAIN)
-			tst_resm(TPASS, "write failed with EAGAIN as expected");
-		else
-			tst_resm(TFAIL, "write failed (wanted EAGAIN)");
-	} else {
-		tst_resm(TFAIL, "write returned with %d", ret);
-	}
-}
-
-/*
- * Test whether read returns with error EINVAL, if buffer size is less
- * than 8 bytes.
- */
-static void read_einval_test(int fd)
-{
-	uint32_t invalid;
-	int ret;
-
-label(read_einval_test_read,
-	ret, read(fd, &invalid, sizeof(invalid)));
-	if (ret == -1) {
-		if (errno == EINVAL) {
-			tst_resm(TPASS, "read failed with EINVAL as expected");
-		} else {
-			tst_resm(TFAIL|TERRNO, "read failed (wanted EINVAL)");
-		}
-	} else {
-		tst_resm(TFAIL, "read returned with %d", ret);
-	}
-}
-
-/*
- * Test whether write returns with error EINVAL, if buffer size is
- * less than 8 bytes.
- */
-static void write_einval_test(int fd)
-{
-	uint32_t invalid;
-	int ret;
-
-label(write_einval_test_write,
-	ret, write(fd, &invalid, sizeof(invalid)));
-	if (ret == -1) {
-		if (errno == EINVAL) {
-			tst_resm(TPASS, "write failed with EINVAL as expected");
-		} else {
-			tst_resm(TFAIL|TERRNO, "write failed (wanted EINVAL)");
-		}
-	} else {
-		tst_resm(TFAIL, "write returned with %d", ret);
-	}
-}
-
-/*
- * Test wheter write returns with error EINVAL, when the written value
- * is 0xFFFFFFFFFFFFFFFF.
- */
-static void write_einval2_test(int fd)
-{
-	int ret;
-	uint64_t val;
-
-label(write_einval2_test_clear,
-	ret, clear_counter(fd));
-	if (ret == -1) {
-		tst_resm(TBROK, "error clearing counter");
-		return;
-	}
-
-	val = 0xffffffffffffffffLL;
-label(write_einval2_test_write,
-	ret, write(fd, &val, sizeof(val)));
-	if (ret == -1) {
-		if (errno == EINVAL)
-			tst_resm(TPASS, "write failed with EINVAL as expected");
-		else
-			tst_resm(TFAIL|TERRNO, "write failed (wanted EINVAL)");
-	} else {
-		tst_resm(TFAIL, "write returned with %d", ret);
-	}
-}
-
-/*
- * Test whether readfd is set by select when counter value is
- * non-zero.
- */
-static void readfd_set_test(int fd)
-{
-	int ret;
-	fd_set readfds;
-	struct timeval timeout = { 0, 0 };
-	uint64_t non_zero = 10;
-
-	FD_ZERO(&readfds);
-	FD_SET(fd, &readfds);
-
-label(readfd_set_test_set,
-      ret, set_counter(fd, non_zero));
-	if (ret == -1) {
-		tst_resm(TBROK, "error setting counter value to %"PRIu64,
-			 non_zero);
-		return;
-	}
-
-label(read_fd_set_test_select,
-      ret, select(fd + 1, &readfds, NULL, NULL, &timeout));
-	if (ret == -1) {
-		/* EINTR cannot occur, since we don't block. */
-		tst_resm(TBROK|TERRNO, "select() failed");
-		return;
-	}
-
-	if (FD_ISSET(fd, &readfds))
-		tst_resm(TPASS, "fd is set in readfds");
-	else
-		tst_resm(TFAIL, "fd is not set in readfds");
-}
-
-/*
- * Test whether readfd is not set by select when counter value is
- * zero.
- */
-static void readfd_not_set_test(int fd)
-{
-	int ret;
-	fd_set readfds;
-	struct timeval timeout = { 0, 0 };
-
-	FD_ZERO(&readfds);
-	FD_SET(fd, &readfds);
-
-label(readfd_not_set_test_clear,
-	ret, clear_counter(fd));
-	if (ret == -1) {
-		tst_resm(TBROK, "error clearing counter");
-		return;
-	}
-
-label(readfd_not_set_test_select,
-      ret, select(fd + 1, &readfds, NULL, NULL, &timeout));
-	if (ret == -1) {
-		/* EINTR cannot occur, since we don't block. */
-		tst_resm(TBROK|TERRNO, "select() failed");
-		return;
-	}
-
-	if (!FD_ISSET(fd, &readfds))
-		tst_resm(TPASS, "fd is not set in readfds");
-	else
-		tst_resm(TFAIL, "fd is set in readfds");
-}
-
-/*
- * Test whether writefd is set by select when counter value is not the
- * maximum counter value.
- */
-static void writefd_set_test(int fd)
-{
-	int ret;
-	fd_set writefds;
-	struct timeval timeout = { 0, 0 };
-	uint64_t non_max = 10;
-
-	FD_ZERO(&writefds);
-	FD_SET(fd, &writefds);
-
-label(writefd_set_test_set,
-	ret, set_counter(fd, non_max));
-	if (ret == -1) {
-		tst_resm(TBROK, "error setting counter value to %"PRIu64, non_max);
-		return;
-	}
-
-label(writefd_set_test_select,
-	ret, select(fd + 1, NULL, &writefds, NULL, &timeout));
-	if (ret == -1) {
-		/* EINTR cannot occur, since we don't block. */
-		tst_resm(TBROK|TERRNO, "select: error getting fd status");
-		return;
-	}
-
-	if (FD_ISSET(fd, &writefds))
-		tst_resm(TPASS, "fd is set in writefds");
-	else
-		tst_resm(TFAIL, "fd is not set in writefds");
-}
-
-/*
- * Test whether writefd is not set by select when counter value is at
- * (UINT64_MAX - 1).
- */
-static void writefd_not_set_test(int fd)
-{
-	int ret;
-	fd_set writefds;
-	struct timeval timeout = { 0, 0 };
-
-	FD_ZERO(&writefds);
-	FD_SET(fd, &writefds);
-
-label(writefd_not_set_test_set,
-	ret, set_counter(fd, UINT64_MAX - 1));
-	if (ret == -1) {
-		tst_resm(TBROK, "error setting counter value to UINT64_MAX-1");
-		return;
-	}
-
-label(writefd_not_set_test_select,
-	ret, select(fd + 1, NULL, &writefds, NULL, &timeout));
-	if (ret == -1) {
-		/* EINTR cannot occur, since we don't block. */
-		tst_resm(TBROK|TERRNO, "select: error getting fd status");
-		return;
-	}
-
-	if (!FD_ISSET(fd, &writefds))
-		tst_resm(TPASS, "fd is not set in writefds");
-	else
-		tst_resm(TFAIL, "fd is set in writefds");
-}
-
-/*
- * Test whether counter update in child is reflected in the parent.
- */
-static void child_inherit_test(int fd)
-{
-	uint64_t val;
-	pid_t cpid;
-	int ret;
-	int status;
-	uint64_t to_parent = 0xdeadbeef;
-	uint64_t dummy;
-
-	cpid = fork();
-	if (cpid == -1)
-		tst_resm(TBROK|TERRNO, "fork() failed");
-	if (cpid != 0) {
-		/* Parent */
-		ret = wait(&status);
-		if (ret == -1) {
-			tst_resm(TBROK, "error getting child exit status");
-			return;
-		}
-
-		if (WEXITSTATUS(status) == 1) {
-			tst_resm(TBROK, "counter value write not "
-				 "succesful in child");
-			return;
-		}
-
-		ret = read(fd, &val, sizeof(val));
-		if (ret == -1) {
-			tst_resm(TBROK|TERRNO, "error reading eventfd");
-			return;
-		}
-
-		if (val == to_parent)
-			tst_resm(TPASS, "counter value write from "
-				 "child successful");
-		else
-			tst_resm(TFAIL, "counter value write in child "
-				 "failed");
-	} else {
-		/* Child */
-		ret = read(fd, &dummy, sizeof(dummy));
-		if (ret == -1 && errno != EAGAIN) {
-			tst_resm(TWARN|TERRNO, "error clearing counter");
-			exit(1);
-		}
-
-		ret = write(fd, &to_parent, sizeof(to_parent));
-		if (ret == -1) {
-			tst_resm(TWARN|TERRNO, "error writing eventfd");
-			exit(1);
-		}
-
-		exit(0);
-	}
-}
-
-#ifdef HAVE_IO_SET_EVENTFD
-/*
- * Test whether counter overflow is detected and handled correctly.
- *
- * It is not possible to directly overflow the counter using the
- * write() syscall. Overflows occur when the counter is incremented
- * from kernel space, in an irq context, when it is not possible to
- * block the calling thread of execution.
- *
- * The AIO subsystem internally uses eventfd mechanism for
- * notification of completion of read or write requests. In this test
- * we trigger a counter overflow, by setting the counter value to the
- * max possible value initially. When the AIO subsystem notifies
- * through the eventfd counter, the counter overflows.
- *
- * NOTE: If the the counter starts from an initial value of 0, it will
- * take decades for an overflow to occur. But since we set the initial
- * value to the max possible counter value, we are able to cause it to
- * overflow with a single increment.
- *
- * When the counter overflows, the following are tested
- *   1. Check whether POLLERR event occurs in poll() for the eventfd.
- *   2. Check whether readfd_set/writefd_set is set in select() for the
-        eventfd.
- *   3. The counter value is UINT64_MAX.
- */
-static int trigger_eventfd_overflow(int evfd, int *fd, io_context_t * ctx)
-{
-	int ret;
-	struct iocb iocb;
-	struct iocb *iocbap[1];
-	static char buf[4 * 1024];
-
-	*ctx = 0;
-	ret = io_setup(16, ctx);
-	if (ret < 0) {
-		errno = -ret;
-		tst_resm(TINFO|TERRNO, "io_setup error");
-		return -1;
-	}
-
-	*fd = open("testfile", O_RDWR | O_CREAT, 0644);
-	if (*fd == -1) {
-		tst_resm(TINFO|TERRNO, "open(testfile) failed");
-		goto err_io_destroy;
-	}
-
-	ret = set_counter(evfd, UINT64_MAX - 1);
-	if (ret == -1) {
-		tst_resm(TINFO, "error setting counter to UINT64_MAX-1");
-		goto err_close_file;
-	}
-
-	io_prep_pwrite(&iocb, *fd, buf, sizeof(buf), 0);
-	io_set_eventfd(&iocb, evfd);
-
-	iocbap[0] = &iocb;
-	ret = io_submit(*ctx, 1, iocbap);
-	if (ret < 0) {
-		errno = -ret;
-		tst_resm(TINFO|TERRNO, "error submitting iocb");
-		goto err_close_file;
-	}
-
-	return 0;
-
-      err_close_file:
-	close(*fd);
-
-      err_io_destroy:
-	io_destroy(*ctx);
-
-	return -1;
-}
-
-static void cleanup_overflow(int fd, io_context_t ctx)
-{
-	close(fd);
-	io_destroy(ctx);
-}
-
-static void overflow_select_test(int evfd)
-{
-	struct timeval timeout = { 10, 0 };
-	fd_set readfds;
-	int fd;
-	io_context_t ctx;
-	int ret;
-
-	ret = trigger_eventfd_overflow(evfd, &fd, &ctx);
-	if (ret == -1) {
-		tst_resm(TBROK, "error triggering eventfd overflow");
-		return;
-	}
-
-	FD_ZERO(&readfds);
-	FD_SET(evfd, &readfds);
-	ret = select(evfd + 1, &readfds, NULL, NULL, &timeout);
-	if (ret == -1) {
-		tst_resm(TBROK|TERRNO, "error getting evfd status with select");
-		goto err_cleanup;
-	}
-
-	if (FD_ISSET(evfd, &readfds))
-		tst_resm(TPASS, "read fd set as expected");
-	else
-		tst_resm(TFAIL, "read fd not set");
-
-      err_cleanup:
-	cleanup_overflow(fd, ctx);
-}
-
-static void overflow_poll_test(int evfd)
-{
-	struct pollfd pollfd;
-	int fd;
-	io_context_t ctx;
-	int ret;
-
-	ret = trigger_eventfd_overflow(evfd, &fd, &ctx);
-	if (fd == -1) {
-		tst_resm(TBROK, "error triggering eventfd overflow");
-		return;
-	}
-
-	pollfd.fd = evfd;
-	pollfd.events = POLLIN;
-	pollfd.revents = 0;
-	ret = poll(&pollfd, 1, 10000);
-	if (ret == -1) {
-		tst_resm(TBROK|TERRNO, "error getting evfd status with poll");
-		goto err_cleanup;
-	}
-	if (pollfd.revents & POLLERR)
-		tst_resm(TPASS, "POLLERR occurred as expected");
-	else
-		tst_resm(TFAIL, "POLLERR did not occur");
-
-      err_cleanup:
-	cleanup_overflow(fd, ctx);
-}
-
-static void overflow_read_test(int evfd)
-{
-	uint64_t count;
-	io_context_t ctx;
-	int fd;
-	int ret;
-
-	ret = trigger_eventfd_overflow(evfd, &fd, &ctx);
-	if (ret == -1) {
-		tst_resm(TBROK, "error triggering eventfd overflow");
-		return;
-	}
-
-	ret = read(evfd, &count, sizeof(count));
-	if (ret == -1) {
-		tst_resm(TBROK|TERRNO, "error reading eventfd");
-		goto err_cleanup;
-	}
-
-	if (count == UINT64_MAX)
-		tst_resm(TPASS, "overflow occurred as expected");
-	else
-		tst_resm(TFAIL, "overflow did not occur");
-
-      err_cleanup:
-	cleanup_overflow(fd, ctx);
-}
-#else
-static void overflow_select_test(int evfd)
-{
-	tst_resm(TCONF, "eventfd support is not available in AIO subsystem");
-}
-
-static void overflow_poll_test(int evfd)
-{
-	tst_resm(TCONF, "eventfd support is not available in AIO subsystem");
-}
-
-static void overflow_read_test(int evfd)
-{
-	tst_resm(TCONF, "eventfd support is not available in AIO subsystem");
-}
-#endif
-
-int opt_do_print_labels = 0;
-int opt_do_print_max_op_num = 0;
-int opt_do_print_descr = 0;
-char *op_num_arg = NULL;
-
-const char *descr = "";
-
-void usage(FILE *pout)
-{
-	fprintf(pout, "\neventfd01 [-L] [-N] [-l LABEL] [-n NUM] [-e] [-t]\n"
-"%s\n"
-"\n"
-"\t-L\tPrint the valid LABELs in order and exit.\n"
-"\t-l\tWait for checkpoint at LABEL.\n"
-"\t-i\tPrint one-line test description.\n"
-"\t-N\tPrint the maximum label number and exit.\n"
-"\t-n\tWait for checkpoint at NUM.\n"
-"\n"
-"You may only specify one LABEL or NUM and you may not specify both.\n"
-"Label numbers are integers in the range 0-%d\n"
-"Valid label numbers and their corresponding LABELs are:\n", descr,
-		num_labels - 1);
-	print_labels(pout);
-}
-
-void help(void)
-{
-	usage(stdout);
-}
-
-char *freezer = "1";
-
-option_t ckpt_opts[] = {
-	{
-		.option = "f:",
-		.flag	= NULL,
-		.arg	= freezer,
-	},
-	{
-		.option = "L",
-		.flag   = &opt_do_print_labels,
-		.arg    = NULL,
-	},
-	{
-		.option = "N",
-		.flag   = &opt_do_print_max_op_num,
-		.arg    = NULL,
-	},
-	{
-		.option = "l:",
-		.flag   = NULL,
-		.arg    = (char**)&ckpt_label,
-	},
-	{
-		.option = "n:",
-		.flag   = NULL,
-		.arg    = &op_num_arg,
-	},
-	{
-		.option = "D",
-		.flag   = &opt_do_print_descr,
-		.arg    = NULL,
-	},
-	{ NULL, NULL, NULL }
-};
-
-int main(int argc, char **argv)
-{
-	char *msg;		/* message returned from parse_opts */
-	int fd, ret;
-	uint64_t einit = 10;
-
-	/* parse standard options */
-	msg = parse_opts(argc, argv, ckpt_opts, help);
-	if (msg != NULL) {
-		tst_brkm(TBROK, NULL, "OPTION PARSING ERROR - %s", msg);
-		tst_exit();
-		/* NOTREACHED */
-	}
-
-	if (opt_do_print_labels) {
-		print_labels(stdout);
-		exit(EXIT_SUCCESS);
-	} else if (opt_do_print_max_op_num) {
-		printf("%d\n", num_labels - 1);
-		exit(EXIT_SUCCESS);
-	} else if (opt_do_print_descr) {
-		printf("%s\n", descr);
-		exit(EXIT_SUCCESS);
-	}
-
-	if (op_num_arg) {
-		if ((sscanf(op_num_arg, "%d", &ckpt_op_num) < 1) ||
-		    (ckpt_op_num < 0) ||
-		    (ckpt_op_num >= num_labels)) {
-			fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
-			usage(stderr);
-			exit(EXIT_FAILURE);
-		}
-	}
-
-	setup();
-	/* FIXME eventually stdio streams should be harmless */
-	close(0);
-	logfp = fopen(LOG_FILE, "w+");
-	if (!logfp) {
-		perror("could not open logfile");
-		exit(1);
-	}
-	/* redirect stdout and stderr to the log file */
-	if (dup2(fileno(logfp), 1) < 0) {
-		log_error("dup2(logfp, 1)");
-		goto out;
-	}
-	if (dup2(fileno(logfp), 2) < 0) {
-		log_error("dup2(logfp, 2)");
-		goto out;
-	}
-	if (!move_to_cgroup("freezer", freezer, getpid())) {
-		log_error("move_to_cgroup");
-		goto out;
-	}
-
-
-	Tst_count = 0;
-
-	fd = myeventfd(einit, 0);
-	if (fd == -1)
-		tst_brkm(TBROK|TERRNO, cleanup, "error creating eventfd");
-label(fcntl_non_blocking,
-	ret, fcntl(fd, F_SETFL, O_NONBLOCK));
-	if (ret == -1)
-		tst_brkm(TBROK|TERRNO, cleanup, "error setting non-block mode");
-
-	read_test(fd, einit);
-	read_eagain_test(fd);
-	write_test(fd);
-	write_eagain_test(fd);
-	read_einval_test(fd);
-	write_einval_test(fd);
-	write_einval2_test(fd);
-	readfd_set_test(fd);
-	readfd_not_set_test(fd);
-	writefd_set_test(fd);
-	writefd_not_set_test(fd);
-	child_inherit_test(fd);
-	overflow_select_test(fd);
-	overflow_poll_test(fd);
-	overflow_read_test(fd);
-
-	close(fd);
-out:
-	cleanup();
-	/* NOT REACHED */
-
-	return 0;
-}
-
-/*
- * setup() - performs all ONE TIME setup for this test
- */
-static void setup(void)
-{
-	/* capture signals */
-	tst_sig(FORK, DEF_HANDLER, cleanup);
-
-	if (tst_kvercmp(2, 6, 22) < 0)
-		tst_brkm(TCONF, cleanup, "2.6.22 or greater kernel required");
-
-	/* Create a temporary directory & chdir there */
-	/*tst_tmpdir();*/
-	/* Pause if that option was specified
-	 * TEST_PAUSE contains the code to fork the test with the -c option.
-	TEST_PAUSE;
-	 */
-	ckpt_label = last_label;
-	ckpt_op_num = -1; /* or num_labels? */
-}
-
-/*
- * cleanup() - performs all ONE TIME cleanup for this test
- */
-static void cleanup(void)
-{
-	/*
-	 * print timing stats if that option was specified.
-	 * print errno log if that option was specified.
-	 */
-	TEST_CLEANUP;
-
-	/* tst_rmdir();*/
-	fclose(logfp);
-	/* exit with return code appropriate for results */
-	tst_exit();
- /*NOTREACHED*/}
-
-const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/eventfd/libeptest.c b/eventfd/libeptest.c
index 073b596..ba55232 100644
--- a/eventfd/libeptest.c
+++ b/eventfd/libeptest.c
@@ -1,19 +1,3 @@
 #include <errno.h>
 
 #include "libeptest.h"
-
-FILE *logfp = NULL;
-
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
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-char const *ckpt_label;
-int ckpt_op_num = 0;
diff --git a/eventfd/libeptest.h b/eventfd/libeptest.h
index c2f327d..88b9f33 100644
--- a/eventfd/libeptest.h
+++ b/eventfd/libeptest.h
@@ -3,10 +3,6 @@
 #include <stdio.h>
 #include <unistd.h>
 
-#include <sys/epoll.h>
-
 #include "libcrtest/libcrtest.h"
 #include "libcrtest/labels.h"
 #include "libcrtest/log.h"
-
-extern FILE *logfp;
diff --git a/eventfd/module.mk b/eventfd/module.mk
new file mode 100644
index 0000000..54a8631
--- /dev/null
+++ b/eventfd/module.mk
@@ -0,0 +1,13 @@
+local_dir := eventfd
+local_progs := $(addprefix $(local_dir)/,rw)
+
+sources += $(addprefix $(local_dir)/,libeptest.c)
+progs += $(local_progs)
+test_clean += $(addprefix $(local_dir)/,*.o cr_eventfd*)
+
+$(local_progs): CFLAGS += $(ARCHOPTS)
+$(local_progs): CPPFLAGS += -I .
+$(local_progs): LDFLAGS += -Xlinker -dT -Xlinker libcrtest/labels.lds
+$(local_progs): libcrtest/libcrtest.a $(local_dir)/libeptest.o
+
+extra_clean += $(local_dir)/libeptest.o $(local_dir)/libeptest.a
diff --git a/eventfd/run.sh b/eventfd/run.sh
index 1f29bed..de01cd3 100755
--- a/eventfd/run.sh
+++ b/eventfd/run.sh
@@ -23,7 +23,7 @@ fi ) | grep -E '^[[:space:]]*CONFIG_EVENTFD=y' > /dev/null 2>&1
 	exit 1
 }
 
-TESTS=( eventfd01 )
+TESTS=( rw )
 
 #make ${TESTS[@]}
 
diff --git a/eventfd/rw.c b/eventfd/rw.c
new file mode 100644
index 0000000..9076f83
--- /dev/null
+++ b/eventfd/rw.c
@@ -0,0 +1,215 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <limits.h>
+#include <getopt.h>
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+#include <sys/eventfd.h>
+#include <sys/time.h> /* itimers */
+
+#include "libeptest.h"
+
+#define LOG_FILE	"log.rw"
+
+void usage(FILE *pout, const char *prog)
+{
+	fprintf(pout, "\n%s [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"Create an empty epoll set.\n"
+"\n"
+"\t-L\tPrint the valid LABELs in order and exit.\n"
+"\t-l\tWait for checkpoint at LABEL.\n"
+"\t-N\tPrint the maximum label number and exit.\n"
+"\t-n\tWait for checkpoint at NUM.\n"
+"\n"
+"You may only specify one LABEL or NUM and you may not specify both.\n"
+"Label numbers are integers in the range 0-%d\n"
+"Valid label numbers and their corresponding LABELs are:\n", prog,
+		num_labels - 1);
+	print_labels(pout);
+}
+
+const struct option long_options[] = {
+	{ "print-labels",	0, 0, 'L'},
+	{ "print-max-label-no",	0, 0, 'N'},
+	{ "help",		0, 0, 'h'},
+	{ "label",		1, 0, 'l'},
+	{ "num",		1, 0, 'n'},
+	{ "freezer",		1, 0, 'f'},
+	{0, 0, 0, 0},
+};
+
+char *freezer = "1";
+
+void parse_label_args(int argc, char **argv)
+{
+	ckpt_op_num = -1;
+	ckpt_label = NULL;
+	while (1) {
+		int c;
+		c = getopt_long(argc, argv, "f:LNhl:n:", long_options, NULL);
+		if (c == -1)
+			break;
+		switch(c) {
+			case 'f':
+				freezer = optarg;
+				printf("Will enter freezer cgroup %s\n", freezer);
+				break;
+			case 'L':
+				print_labels(stdout);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'N':
+				printf("%d\n", num_labels - 1);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'h':
+				usage(stdout, argv[0]);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'l':
+				ckpt_label = optarg;
+				break;
+			case 'n':
+				if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
+				    (ckpt_op_num < 0) ||
+				    (ckpt_op_num >= num_labels)) {
+					fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
+					usage(stderr, argv[0]);
+					exit(EXIT_FAILURE);
+				}
+				break;
+			default: /* unknown option */
+				break;
+		}
+	}
+}
+
+void setup_test_output(const char *log_filename)
+{
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(log_filename, "w+");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	/* redirect stdout and stderr to the log file */
+	if (dup2(fileno(logfp), 1) < 0) {
+		log_error("dup2(logfp, 1)");
+		exit(2);
+	}
+	if (dup2(fileno(logfp), 2) < 0) {
+		log_error("dup2(logfp, 2)");
+		exit(3);
+	}
+}
+
+static int evfd;
+
+void handler(int signo)
+{
+	u64 v;
+
+	/*
+	 * We don't actually do anything here -- just handle EINTR errnos
+	 * synchronously.
+	 */
+	log("INFO", "Received SIGLARM\n");
+	v = 1;
+	write(evfd, &v, sizeof(v));
+}
+
+int main (int argc, char **argv)
+{
+	struct itimerval one_second_timeout = {
+		.it_value = { .tv_sec = 1, .tv_usec = 0 },
+		.it_interval = { .tv_sec = 0, .tv_usec = 0 }
+	};
+	u64 v;
+	int ret = 0;
+	int op_num = 0;
+
+	parse_label_args(argc, argv);
+	setup_test_output(LOG_FILE);
+
+	if (!move_to_cgroup("freezer", freezer, getpid())) {
+		log_error("move_to_cgroup");
+		exit(4);
+	}
+	log("INFO", "entered cgroup %s\n", freezer);
+
+label(create_eventfd,
+	evfd, eventfd(0, EFD_CLOEXEC));
+	if (evfd < 0) {
+		log_error("eventfd(EFD_CLOEXEC)");
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+
+	/* Set up a timer to bring us out of a blocking read */
+	signal(SIGALRM, handler);
+label(prepare_blocking_read_timeout,
+      ret, setitimer(ITIMER_REAL, &one_second_timeout, NULL));
+
+	/* Do the blocking read. */
+	log("INFO", "Doing blocking read. Quick! Somebody checkpoint me!\n");
+	ret = read(evfd, &v, sizeof(v));
+	if (v != 1) {
+		log("FAIL", "Expected event value %lld, got %lld\n",
+		    1ULL, v);
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+
+	/* Write to the event counter and get the result. */
+	v = 31337;
+label(write_event1, ret, write(evfd, &v, sizeof(v)));
+	v = 0;
+label(read_event1, ret, read(evfd, &v, sizeof(v)));
+	if (v != 31337) {
+		log("FAIL", "Expected event value %lld, got %lld\n",
+		    31337ULL, v);
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+
+	/* Now test non-blocking operation */
+label(set_nonblocking, ret, fcntl(evfd, F_SETFL, O_NONBLOCK));
+	ret = read(evfd, &v, sizeof(v));
+	if ((ret != -1) || (errno != EAGAIN)) {
+		log("FAIL", "Expected EAGAIN from non-blocking read.\n");
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+
+	v = 1;
+label(write_event2, ret, write(evfd, &v, sizeof(v)));
+	v = 0;
+label(read_event2, ret, read(evfd, &v, sizeof(v)));
+	if (v != 1) {
+		log("FAIL", "Expected event value %lld, got %lld\n",
+		    1ULL, v);
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+	ret = EXIT_SUCCESS;
+
+out:
+	if (close(evfd) < 0) {
+		perror("close()");
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+	fclose(logfp);
+	exit(ret);
+}
-- 
1.6.3.3
