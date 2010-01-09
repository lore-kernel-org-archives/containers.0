From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] pthread2: Test additional pthread attributes
Date: Fri, 8 Jan 2010 17:29:24 -0800
Message-ID: <20100109012924.GA21607@us.ibm.com>
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
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This test case currently fails with following errors in dmesg:
Looks like the VM_NORESERVE flag on some maps triggers the error
(CKPT_VMA_NOT_SUPPORTED includes the VM_NORESERVE flag)

	[4999:4999:c/r:checkpoint_vmas:625] vma 0xb7200000-0xb7221000 flags
	0x200073
	[err -38][pos 102940][E @ checkpoint_vmas:629][pid 4976 tsk pthread2]
	vma: bad flags (0x200073)
	[4999:4999:c/r:checkpoint_task_objs:264] mm: objref -38
	[4999:4999:c/r:ckpt_write_obj_type:66] type 9999 len 8
	[4999:4999:c/r:ckpt_write_obj_type:66] type 5 len 93
	[err -38][pos 102940][E @ checkpoint_task_objs:266][pid 4976 tsk
	pthread2]mm_struct
	[4999:4999:c/r:checkpoint_task:450] objs -38
	[4999:4999:c/r:pgarr_release_pages:101] total pages 0
---

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sat, 26 Dec 2009 13:08:32 +0530
Subject: [PATCH 1/3] pthread2: Test additional pthread attributes

Extend the test case to test all (most) pthread attributes in a single
test.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/pthread2.c      |  400 +++++++++++++++++++++++++++++++++++++-----
 process-tree/run-pthread2.sh |    5 +-
 2 files changed, 355 insertions(+), 50 deletions(-)

diff --git a/process-tree/pthread2.c b/process-tree/pthread2.c
index 6ac1e52..a773245 100644
--- a/process-tree/pthread2.c
+++ b/process-tree/pthread2.c
@@ -12,11 +12,10 @@
 #define LOG_PREFIX	"logs.d/pthread2"
 
 FILE *logfp;
-
 int num_threads = 8;
-void **exp_addrs;
-size_t  *exp_sizes;
 int *tstatus;
+pthread_barrier_t barrier;
+pthread_mutex_t dump_lock;
 
 static void usage(char *argv[])
 {
@@ -25,19 +24,10 @@ static void usage(char *argv[])
 	do_exit(1);
 }
 
-pthread_attr_t *get_thread_attr(int tnum)
+pthread_attr_t *alloc_thread_attr()
 {
-	int rc, size;
+	int rc;
 	pthread_attr_t *attr;
-	void *stack;
-
-	size = MIN_STACK_SIZE + (tnum * getpagesize());
-
-	stack = malloc(size);
-	if (!stack) {
-		fprintf(logfp, "malloc(stack): error %s\n", strerror(errno));
-		do_exit(1);
-	}
 
 	attr = malloc(sizeof(pthread_attr_t));
 	if (!attr) {
@@ -52,29 +42,211 @@ pthread_attr_t *get_thread_attr(int tnum)
 		do_exit(1);
 	}
 
-	rc = pthread_attr_setstack(attr, stack, size);
+	return attr;
+}
+
+#ifndef debug
+dump_attr(char *msg, pthread_attr_t *attr)
+{
+}
+#endif
+
+get_affinity(int tnum, pthread_attr_t *attr, cpu_set_t *cpu_set)
+{
+	int rc;
+
+	fprintf(logfp, "sizeof(cpu_set_t) %d\n", sizeof(cpu_set_t));
+
+	rc = pthread_attr_getaffinity_np(attr, sizeof(cpu_set_t), cpu_set);
 	if (rc < 0) {
-		fprintf(logfp, "pthread_attr_setstack(): rc %d error %s\n",
-				rc, strerror(errno));
+		fprintf(logfp, "pthread_attr_getaffin() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
 		do_exit(1);
 	}
 
-	return attr;
 }
 
-int get_stack_info(pthread_t tid, void **addrp, size_t *sizep)
+compare_affinity(int tnum, pthread_attr_t *exp_attr, pthread_attr_t *act_attr)
+{
+	cpu_set_t exp_cpus, act_cpus;
+
+	get_affinity(tnum, exp_attr, &exp_cpus);
+	get_affinity(tnum, act_attr, &act_cpus);
+
+	if (memcmp(&exp_cpus, &act_cpus, sizeof(cpu_set_t))) {
+		fprintf(logfp, "cpu set mismatch\n");
+		do_exit(1);
+	}
+}
+
+get_detachstate(int tnum, pthread_attr_t *attr, int *state)
 {
 	int rc;
-	pthread_attr_t attr;
 
-	rc = pthread_getattr_np(tid, &attr);
+	rc = pthread_attr_getdetachstate(attr, state);
 	if (rc < 0) {
-		fprintf(logfp, "pthread_getattr_np failed, rc %d, %s\n", rc,
-				strerror(errno));
-		pthread_exit(ERROR_EXIT);
+		fprintf(logfp, "pthread_attr_getdetachstate() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+compare_detachstate(int tnum, pthread_attr_t *exp_attr,
+		pthread_attr_t *act_attr)
+{
+
+	int exp_state, act_state;
+
+	get_detachstate(tnum, exp_attr, &exp_state);
+	get_detachstate(tnum, act_attr, &act_state);
+
+	if (exp_state != act_state) {
+		fprintf(logfp, "%d: Thread detach state mismatch: expected %d, "
+				"actual %d\n", tnum, exp_state, act_state);
+		do_exit(1);
+	}
+}
+
+get_guardsize(int tnum, pthread_attr_t *attr, int *gsize)
+{
+	int rc;
+
+	rc = pthread_attr_getguardsize(attr, gsize);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_getguardsize() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+void compare_guardsize(int tnum, pthread_attr_t *exp_attr,
+		pthread_attr_t *act_attr)
+{
+	size_t exp_size, act_size;
+
+	get_guardsize(tnum, exp_attr, &exp_size);
+	get_guardsize(tnum, act_attr, &act_size);
+
+	if (exp_size != act_size) {
+		fprintf(logfp, "%d: Thread guard size mismatch, expected %d "
+				"actual %d\n", tnum, exp_size, act_size);
+		do_exit(1);
+	}
+}
+
+get_inheritsched(int tnum, pthread_attr_t *attr, int *isched)
+{
+	int rc;
+
+	rc = pthread_attr_getinheritsched(attr, isched);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_inheritsched() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+void compare_inheritsched(int tnum, pthread_attr_t *exp_attr,
+		pthread_attr_t *act_attr)
+{
+	int exp_isched, act_isched;
+
+	get_inheritsched(tnum, exp_attr, &exp_isched);
+	get_inheritsched(tnum, act_attr, &act_isched);
+
+	if (exp_isched != act_isched) {
+		fprintf(logfp, "%d: Thread inherit-sched mismatch, expected %d "
+				"actual %d\n", tnum, exp_isched, act_isched);
+		do_exit(1);
 	}
+}
 
-	rc = pthread_attr_getstack(&attr, (void **)addrp, sizep);
+get_schedparam(int tnum, pthread_attr_t *attr, int *prio)
+{
+	int rc;
+	struct sched_param param;
+
+	rc = pthread_attr_getschedparam(attr, &param);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_getschedparam() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+	*prio = param.__sched_priority;
+}
+
+compare_schedparam(int tnum, pthread_attr_t *exp_attr, pthread_attr_t *act_attr)
+{
+	int exp_prio, act_prio;
+
+	get_schedparam(tnum, exp_attr, &exp_prio);
+	get_schedparam(tnum, act_attr, &act_prio);
+
+	if (exp_prio != act_prio) {
+		fprintf(logfp, "%d: Thread sched-param mismatch, expected %d "
+				"actual %d\n", tnum, exp_prio, act_prio);
+		do_exit(1);
+	}
+}
+
+get_schedpolicy(int tnum, pthread_attr_t *attr, int *policy)
+{
+	int rc;
+
+	rc = pthread_attr_getschedpolicy(attr, policy);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_getschedpolicy() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+compare_schedpolicy(int tnum, pthread_attr_t *exp_attr,
+			pthread_attr_t *act_attr)
+{
+	int exp_policy, act_policy;
+
+	get_schedpolicy(tnum, exp_attr, &exp_policy);
+	get_schedpolicy(tnum, act_attr, &act_policy);
+
+	if (exp_policy != act_policy) {
+		fprintf(logfp, "%d: Thread sched-policy mismatch, expected %d "
+				"actual %d\n", tnum, exp_policy, act_policy);
+		do_exit(1);
+	}
+}
+
+get_scope(int tnum, pthread_attr_t *attr, int *scope)
+{
+	int rc;
+
+	rc = pthread_attr_getscope(attr, scope);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_getscope() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+compare_scope(int tnum, pthread_attr_t *exp_attr, pthread_attr_t *act_attr)
+{
+	int exp_scope, act_scope;
+
+	get_scope(tnum, exp_attr, &exp_scope);
+	get_scope(tnum, act_attr, &act_scope);
+
+	if (exp_scope != act_scope) {
+		fprintf(logfp, "%d: Thread scope mismatch, expected %d "
+				"actual %d\n", tnum, exp_scope, act_scope);
+		do_exit(1);
+	}
+}
+
+int get_stack(pthread_attr_t *attr, void **addrp, int *sizep)
+{
+	int rc;
+
+	rc = pthread_attr_getstack(attr, (void **)addrp, sizep);
 	if (rc < 0) {
 		fprintf(logfp, "pthread_attr_getstackaddr failed, rc %d, %s\n",
 					rc, strerror(errno));
@@ -84,40 +256,145 @@ int get_stack_info(pthread_t tid, void **addrp, size_t *sizep)
 	return 0;
 }
 
+void compare_stack(int tnum, pthread_attr_t *exp_attr,
+		pthread_attr_t *act_attr)
+{
+	int exp_size, act_size;
+	void *exp_addr, *act_addr;
+
+	get_stack(exp_attr, &exp_addr, &exp_size);
+	get_stack(act_attr, &act_addr, &act_size);
+
+	if (act_addr != exp_addr || act_size != exp_size) {
+		fprintf(logfp, "%d: Expected: (%p, %d), actual (%p, %d)\n",
+				tnum, exp_addr, exp_size, act_addr, act_size);
+		fflush(logfp);
+		do_exit(1);
+	}
+}
+
+compare_attr(int tnum, pthread_attr_t *exp_attr, pthread_attr_t *act_attr)
+{
+
+	dump_attr("Expected attr", exp_attr);
+	dump_attr("Actual attr", act_attr);
+
+	/*
+	 * We cannot simply memcmp() the exp_attr and act_attr since the
+	 * 'struct pthread_attr' contains a pointer to cpuset. This address
+	 * will be different even if the cpusets are the same
+	 */
+	compare_affinity(tnum, exp_attr, act_attr);
+
+	compare_detachstate(tnum, exp_attr, act_attr);
+
+	compare_guardsize(tnum, exp_attr, act_attr);
+
+	compare_inheritsched(tnum, exp_attr, act_attr);
+
+	compare_schedparam(tnum, exp_attr, act_attr);
+
+	compare_schedpolicy(tnum, exp_attr, act_attr);
+
+	compare_scope(tnum, exp_attr, act_attr);
+
+	compare_stack(tnum, exp_attr, act_attr);
+}
+
 void *do_work(void *arg)
 {
 	long tnum = (long)arg;
 	int rc;
-	void *act_addr;
-	size_t act_size;
+	pthread_attr_t exp_attr, act_attr;
 
 	fprintf(logfp, "%ld: Thread %lu: waiting for checkpoint\n", tnum,
 			pthread_self());
 	fflush(logfp);
 
+	memset(&exp_attr, 0, sizeof(pthread_attr_t));
+	memset(&act_attr, 0, sizeof(pthread_attr_t));
+
+	/*
+	 * Collect attributes before checkpoint/restart.
+	 */
+	rc = pthread_getattr_np(pthread_self(), &exp_attr);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_getattr_np failed, rc %d, %s\n", rc,
+				strerror(errno));
+		pthread_exit(ERROR_EXIT);
+	}
+
+	/*
+	 * Inform main-thread we are ready for checkpoint.
+	 */
+	rc = pthread_barrier_wait(&barrier);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "%d: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * Wait for checkpoint/restart.
+	 */
 	while(!test_done())
 		sleep(1);
 
-	rc = get_stack_info(pthread_self(), &act_addr, &act_size);
-	if (rc < 0)
+	/*
+	 * Collect attributes after checkpoint/restart.
+	 */
+	rc = pthread_getattr_np(pthread_self(), &act_attr);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_getattr_np failed, rc %d, %s\n", rc,
+				strerror(errno));
 		pthread_exit(ERROR_EXIT);
-
-	if (act_addr != exp_addrs[tnum] || act_size != exp_sizes[tnum]) {
-		fprintf(logfp, "%d: Expected: (%p, %d), actual (%p, %d)\n",
-				tnum, exp_addrs[tnum], exp_sizes[tnum],
-				act_addr, act_size);
-		fflush(logfp);
-		rc = 1;
 	}
 
-	fprintf(logfp, "%d: Thread %lu: exiting, rc %d\n", tnum,
-			pthread_self(), rc);
+	/*
+	 * Compare attributes before and after C/R.
+	 */
+	compare_attr(tnum, &exp_attr, &act_attr);
+
+	fprintf(logfp, "%d: Thread %lu: exiting, rc 0\n", tnum,
+			pthread_self());
 	fflush(logfp);
 
-	tstatus[tnum] = rc;
+	tstatus[tnum] = 0;
 	pthread_exit((void *)&tstatus[tnum]);
 }
 
+void set_stack(pthread_attr_t *attr, int tnum)
+{
+	int rc, size;
+	void *stack;
+
+	size = MIN_STACK_SIZE + (tnum * getpagesize());
+
+	stack = malloc(size);
+	if (!stack) {
+		fprintf(logfp, "malloc(stack): error %s\n", strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_attr_setstack(attr, stack, size);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_setstack(): rc %d error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+/*
+ * Modify any attributes for this thread for testing.
+ * For now, we only modify the thread-stack.
+ */
+void set_thread_attrs(pthread_attr_t *attr, int tnum)
+{
+	set_stack(attr, tnum);
+
+	return;
+}
+
 pthread_t *create_threads(int n)
 {
 	long i;
@@ -127,21 +404,21 @@ pthread_t *create_threads(int n)
 	pthread_attr_t *attr;
 
 	tid_list = (pthread_t *)malloc(n * sizeof(pthread_t));
-	exp_addrs = malloc(sizeof(void *) * n);
-	exp_sizes = malloc(sizeof(size_t) * n);
 	tstatus = malloc(sizeof(int) * n);
 
-	if (!tid_list || !exp_addrs || !exp_sizes || !tstatus) {
+	if (!tid_list || !tstatus) {
 		fprintf(logfp, "malloc() failed, n %d, error %s\n",
 				n, strerror(errno));
 		do_exit(1);
 	}
 
 	for (i = 0; i < n; i++) {
-		attr = get_thread_attr(i);
+		attr = alloc_thread_attr();
 		if (!attr)
 			do_exit(1);
 
+		set_thread_attrs(attr, i);
+
 		rc = pthread_create(&tid, attr, do_work, (void *)i);
 		if (rc < 0) {
 			fprintf(logfp, "pthread_create(): i %d, rc %d, "
@@ -149,10 +426,6 @@ pthread_t *create_threads(int n)
 			do_exit(1);
 		}
 
-		rc = get_stack_info(tid, &exp_addrs[i], &exp_sizes[i]);
-		if (rc < 0)
-			do_exit(1);
-
 		tid_list[i] = tid;
 	}
 
@@ -224,15 +497,46 @@ main(int argc, char *argv[])
 		do_exit(1);
 	}
 
+	fprintf(stderr, "Redirecting output to %s\n", log_file);
+	fflush(stderr);
+
 	for (i=0; i<100; i++)  {
 		if (fileno(logfp) != i)
 			close(i);
 	}
 
 
+	/*
+	 * Create a barrier which the main-thread can use to determine
+	 * when all threads are ready for checkpoint.
+	 */
+	rc = pthread_barrier_init(&barrier, NULL, num_threads+1);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_barrier_init() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_mutex_init(&dump_lock, NULL);
+	if (rc) {
+		fprintf(logfp, "pthread_mutex_init() failed, rc %d, error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+
 	tid_list = create_threads(num_threads);
 
 	/*
+	 * Wait for everyone to be ready for checkpoint
+	 */
+	pthread_barrier_wait(&barrier);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "main: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
 	 * Now that we closed the special files and created the threads,
 	 * tell any wrapper scripts, we are ready for checkpoint
 	 */
@@ -240,5 +544,7 @@ main(int argc, char *argv[])
 
 	rc = wait_for_threads(tid_list, num_threads);
 
+	fprintf(logfp, "Exiting with status %d\n", rc);
+
 	do_exit(rc);
 }
diff --git a/process-tree/run-pthread2.sh b/process-tree/run-pthread2.sh
index 0686cbd..ff7f0ac 100755
--- a/process-tree/run-pthread2.sh
+++ b/process-tree/run-pthread2.sh
@@ -2,8 +2,7 @@
 
 source ../common.sh
 
-#dir=`mktemp -p . -d -t cr_pthread2_XXXXXXX` || (echo "mktemp failed"; exit 1)
-dir=cr_pthread2
+dir=`mktemp -p . -d -t cr_pthread2_XXXXXXX` || (echo "mktemp failed"; exit 1)
 mkdir $dir
 echo "Using output dir $dir"
 cd $dir
@@ -17,7 +16,7 @@ RESTART=`which restart`
 ECHO="/bin/echo -e"
 
 TEST_CMD="../pthread2"
-TEST_ARGS="-n 128"			# -n: number of threads
+TEST_ARGS="-n 4"			# -n: number of threads
 SCRIPT_LOG="log-run-pthread2"
 TEST_PID_FILE="pid.pthread2";
 
-- 
1.6.0.4
