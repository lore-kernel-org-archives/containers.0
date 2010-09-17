From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/8] checkpoint/restart of anonymous hugetlb mappings
Date: Fri, 17 Sep 2010 15:23:13 -0500
Message-ID: <1284754993.4109.397.camel@localhost.localdomain>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
	<1284494530-25946-6-git-send-email-ntl@pobox.com>
	<4C92BA08.70106@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C92BA08.70106-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2010-09-16 at 20:44 -0400, Oren Laadan wrote:
> 
> On 09/14/2010 04:02 PM, Nathan Lynch wrote:
> > Support checkpoint and restore of both private and shared
> > hugepage-backed mappings established via mmap(MAP_HUGETLB).  Introduce
> > APIs for checkpoint and restart of individual huge pages which are to
> > be used by the sysv SHM_HUGETLB c/r code.
> > 
> > Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> The code looks clean, but I need to learn more about HUGETLB
> before I can say much...
> 
> Do you also have test-suite for this ?

Included below is a throwaway patch to user-cr's shmem and ipcshm tests
which will cause them to use huge pages.  You'll need to configure huge
pages on your system; see Documentation/vm/hugetlbpage.txt in the kernel
source.


> 
> [...]
> 
> > +static int hugetlb_dump_contents(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
> > +{
> > +	struct ckpt_hdr_hpage hdr;
> > +	unsigned long pageshift;
> > +	unsigned long pagesize;
> > +	unsigned long addr;
> > +	int ret;
> > +
> > +	pageshift = huge_page_shift(hstate_vma(vma));
> > +	pagesize = vma_kernel_pagesize(vma);
> > +
> > +	ckpt_hdr_hpage_init(&hdr, pageshift);
> > +
> > +	for (addr = vma->vm_start; addr < vma->vm_end; addr += pagesize) {
> > +		struct page *page = NULL;
> > +
> > +		down_read(&vma->vm_mm->mmap_sem);
> > +		ret = __get_user_pages(ctx->tsk, vma->vm_mm,
> > +				       addr, 1, FOLL_DUMP | FOLL_GET,
> > +				       &page, NULL);
> > +		/* FOLL_DUMP gives -EFAULT for holes */
> > +		if (ret == -EFAULT)
> > +			ret = 0;
> 
> With regular pages, this didn't always work, especially after they
> slightly changed the semantics of FOLL_DUMP. So I introduced the
> FOLL_DIRTY flag to detect dirty (non-zero) pages.  I wonder if
> something like that may be needed here too ?

I don't think so - huge pages are never used to map regular files (they
are always on hugetlbfs), so they can't get out of sync with a backing
store.


 test/ipcshm.c |    7 ++++---
 test/shmem.c  |    8 ++++++--
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/test/ipcshm.c b/test/ipcshm.c
index cf932b4..f4b5e8a 100644
--- a/test/ipcshm.c
+++ b/test/ipcshm.c
@@ -7,6 +7,7 @@
 
 #define OUTFILE  "/tmp/cr-test.out"
 #define SEG_SIZE (20 * 4096)
+#define HTLB_SEG_SIZE (1024 * 1024 * 16)
 #define SEG_KEY1 11
 
 int main(int argc, char *argv[])
@@ -37,7 +38,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	id2 = shmget(IPC_PRIVATE, SEG_SIZE, 0700|IPC_CREAT|IPC_EXCL);
+	id2 = shmget(IPC_PRIVATE, HTLB_SEG_SIZE, 0700|IPC_CREAT|IPC_EXCL|SHM_HUGETLB);
 	if (id2 < 0) {		
 		perror("shmget2");
 		exit(1);
@@ -63,9 +64,9 @@ int main(int argc, char *argv[])
 	if (shmdt(seg1) < 0)
 		perror("shmdt1");
 
-	fprintf(file, "detaches 2nd, sleeping 30\n");
+	fprintf(file, "detaches 2nd, sleeping 120\n");
 	fflush(file);
-	sleep(20);
+	sleep(120);
 	fprintf(file, "waking up\n");
 	fflush(file);
 
diff --git a/test/shmem.c b/test/shmem.c
index 6d7dd8a..cb9fd10 100644
--- a/test/shmem.c
+++ b/test/shmem.c
@@ -5,6 +5,10 @@
 #include <math.h>
 #include <sys/mman.h>
 
+#ifndef MAP_HUGETLB
+#define MAP_HUGETLB 0x40000
+#endif
+
 #define OUTFILE  "/tmp/cr-test.out"
 
 int main(int argc, char *argv[])
@@ -41,7 +45,7 @@ int main(int argc, char *argv[])
 	}
 
 	addr = mmap(NULL, 16384, PROT_READ | PROT_WRITE,
-		    MAP_ANONYMOUS | MAP_SHARED, 0, 0);
+		    MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB, 0, 0);
 	if (addr == MAP_FAILED) {
 		perror("mmap");
 		exit(1);
@@ -66,7 +70,7 @@ int main(int argc, char *argv[])
 		close(pipefd[1]);
 	}
 
-	for (i = 0; i < 10; i++) {
+	for (i = 0; i < 120; i++) {
 		sleep(1);
 		/* make the fpu work ->  a = a + i/10  */
 		a = sqrt(a*a + 2*a*(i/10.0) + i*i/100.0);
