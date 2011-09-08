From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
	directory v6
Date: Thu, 8 Sep 2011 16:52:01 -0700
Message-ID: <20110908165201.59e82c71.akpm@linux-foundation.org>
References: <20110906165144.GJ18425@mtj.dyndns.org>
	<20110906172952.GA28055@albatros>
	<20110906173341.GM18425@mtj.dyndns.org>
	<20110907112301.GA12157@albatros> <20110907215329.GB28162@sun>
	<20110907151323.613e62e7.akpm@linux-foundation.org>
	<20110907224234.GD28162@sun>
	<20110907155332.beda7d3d.akpm@linux-foundation.org>
	<20110908054826.GF28162@sun> <20110908055025.GG28162@sun>
	<20110908060405.GH28162@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110908060405.GH28162@sun>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 8 Sep 2011 10:04:05 +0400
Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> fs, proc: Introduce the /proc/<pid>/map_files/ directory v11

Ho hum, I've pretty much run out of excuses to avoid merging this.

except...

We don't really want to bloat fs/proc/base.o by 4k until all the other
things which support c/r are mergeable and we know that the whole
project is actually useful.  When will we be at this stage?

<looks at the warning>

fs/proc/base.c: In function 'proc_map_files_instantiate':
fs/proc/base.c:2348: warning: assignment from incompatible pointer type

err, that code will crash at runtime and it isn't trivial to fix. 
How could this happen?

>
> ...
>
> +				if (fa)
> +					flex_array_free(fa);
>
> ...
>
> +		if (fa)
> +			flex_array_free(fa);

I think I'll do this:

From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

Lots of callers are avoiding passing NULL into flex_array_free().  Move
the check into flex_array_free() in the usual fashion.

Cc: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

 fs/proc/base.c                 |    6 ++----
 lib/flex_array.c               |    2 ++
 security/selinux/ss/policydb.c |    9 +++------
 3 files changed, 7 insertions(+), 10 deletions(-)

diff -puN lib/flex_array.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free lib/flex_array.c
--- a/lib/flex_array.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free
+++ a/lib/flex_array.c
@@ -142,6 +142,8 @@ EXPORT_SYMBOL(flex_array_free_parts);
 
 void flex_array_free(struct flex_array *fa)
 {
+	if (!fa)
+		return;
 	flex_array_free_parts(fa);
 	kfree(fa);
 }
diff -puN fs/proc/base.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free fs/proc/base.c
--- a/fs/proc/base.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free
+++ a/fs/proc/base.c
@@ -2514,8 +2514,7 @@ static int proc_map_files_readdir(struct
 			fa = flex_array_alloc(sizeof(info), nr_files, GFP_KERNEL);
 			if (!fa || flex_array_prealloc(fa, 0, nr_files, GFP_KERNEL)) {
 				ret = -ENOMEM;
-				if (fa)
-					flex_array_free(fa);
+				flex_array_free(fa);
 				up_read(&mm->mmap_sem);
 				mmput(mm);
 				goto out;
@@ -2556,8 +2555,7 @@ static int proc_map_files_readdir(struct
 			p = flex_array_get(fa, i);
 			fput(p->file);
 		}
-		if (fa)
-			flex_array_free(fa);
+		flex_array_free(fa);
 		mmput(mm);
 	}
 	}
diff -puN security/selinux/ss/policydb.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free security/selinux/ss/policydb.c
--- a/security/selinux/ss/policydb.c~lib-flex_arrayc-accept-null-arg-to-flex_array_free
+++ a/security/selinux/ss/policydb.c
@@ -769,16 +769,13 @@ void policydb_destroy(struct policydb *p
 		hashtab_destroy(p->symtab[i].table);
 	}
 
-	for (i = 0; i < SYM_NUM; i++) {
-		if (p->sym_val_to_name[i])
-			flex_array_free(p->sym_val_to_name[i]);
-	}
+	for (i = 0; i < SYM_NUM; i++)
+		flex_array_free(p->sym_val_to_name[i]);
 
 	kfree(p->class_val_to_struct);
 	kfree(p->role_val_to_struct);
 	kfree(p->user_val_to_struct);
-	if (p->type_val_to_struct_array)
-		flex_array_free(p->type_val_to_struct_array);
+	flex_array_free(p->type_val_to_struct_array);
 
 	avtab_destroy(&p->te_avtab);
 
_
