From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/12] cpuset: convert away from cftype->read()
Date: Wed, 27 Nov 2013 18:42:29 -0500
Message-ID: <1385595759-17656-3-git-send-email-tj__20388.0341061906$1385595787$gmane$org@kernel.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

In preparation of conversion to kernfs, cgroup file handling is being
consolidated so that it can be easily mapped to the seq_file based
interface of kernfs.

All users of cftype->read() can be easily served, usually better, by
seq_file and other methods.  Rename cpuset_common_file_read() to
cpuset_common_read_seq_string() and convert it to use
read_seq_string() interface instead.  This not only simplifies the
code but also makes it more versatile.  Before, the file couldn't
output if the result is longer than PAGE_SIZE.  After the conversion,
seq_file automatically grows the buffer until the output can fit.

This patch doesn't make any visible behavior changes except for being
able to handle output larger than PAGE_SIZE.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 71 +++++++++++++++++++--------------------------------------
 1 file changed, 24 insertions(+), 47 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4772034..032929f 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1731,66 +1731,43 @@ out_unlock:
  * used, list of ranges of sequential numbers, is variable length,
  * and since these maps can change value dynamically, one could read
  * gibberish by doing partial reads while a list was changing.
- * A single large read to a buffer that crosses a page boundary is
- * ok, because the result being copied to user land is not recomputed
- * across a page fault.
  */
-
-static size_t cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
-{
-	size_t count;
-
-	mutex_lock(&callback_mutex);
-	count = cpulist_scnprintf(page, PAGE_SIZE, cs->cpus_allowed);
-	mutex_unlock(&callback_mutex);
-
-	return count;
-}
-
-static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
-{
-	size_t count;
-
-	mutex_lock(&callback_mutex);
-	count = nodelist_scnprintf(page, PAGE_SIZE, cs->mems_allowed);
-	mutex_unlock(&callback_mutex);
-
-	return count;
-}
-
-static ssize_t cpuset_common_file_read(struct cgroup_subsys_state *css,
-				       struct cftype *cft, struct file *file,
-				       char __user *buf, size_t nbytes,
-				       loff_t *ppos)
+static int cpuset_common_read_seq_string(struct cgroup_subsys_state *css,
+					 struct cftype *cft,
+					 struct seq_file *sf)
 {
 	struct cpuset *cs = css_cs(css);
 	cpuset_filetype_t type = cft->private;
-	char *page;
-	ssize_t retval = 0;
-	char *s;
+	ssize_t count;
+	char *buf, *s;
+	int ret = 0;
 
-	if (!(page = (char *)__get_free_page(GFP_TEMPORARY)))
-		return -ENOMEM;
+	count = seq_get_buf(sf, &buf);
+	s = buf;
 
-	s = page;
+	mutex_lock(&callback_mutex);
 
 	switch (type) {
 	case FILE_CPULIST:
-		s += cpuset_sprintf_cpulist(s, cs);
+		s += cpulist_scnprintf(s, count, cs->cpus_allowed);
 		break;
 	case FILE_MEMLIST:
-		s += cpuset_sprintf_memlist(s, cs);
+		s += nodelist_scnprintf(s, count, cs->mems_allowed);
 		break;
 	default:
-		retval = -EINVAL;
-		goto out;
+		ret = -EINVAL;
+		goto out_unlock;
 	}
-	*s++ = '\n';
 
-	retval = simple_read_from_buffer(buf, nbytes, ppos, page, s - page);
-out:
-	free_page((unsigned long)page);
-	return retval;
+	if (s < buf + count - 1) {
+		*s++ = '\n';
+		seq_commit(sf, s - buf);
+	} else {
+		seq_commit(sf, -1);
+	}
+out_unlock:
+	mutex_unlock(&callback_mutex);
+	return ret;
 }
 
 static u64 cpuset_read_u64(struct cgroup_subsys_state *css, struct cftype *cft)
@@ -1847,7 +1824,7 @@ static s64 cpuset_read_s64(struct cgroup_subsys_state *css, struct cftype *cft)
 static struct cftype files[] = {
 	{
 		.name = "cpus",
-		.read = cpuset_common_file_read,
+		.read_seq_string = cpuset_common_read_seq_string,
 		.write_string = cpuset_write_resmask,
 		.max_write_len = (100U + 6 * NR_CPUS),
 		.private = FILE_CPULIST,
@@ -1855,7 +1832,7 @@ static struct cftype files[] = {
 
 	{
 		.name = "mems",
-		.read = cpuset_common_file_read,
+		.read_seq_string = cpuset_common_read_seq_string,
 		.write_string = cpuset_write_resmask,
 		.max_write_len = (100U + 6 * MAX_NUMNODES),
 		.private = FILE_MEMLIST,
-- 
1.8.4.2
