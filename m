From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 5/7] dcache: Only read d_flags once in d_is_dir
Date: Sat, 15 Aug 2015 13:38:49 -0500
Message-ID: <87egj45rd2.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
	<87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
	<87a8ts763c.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8ts763c.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Sat, 15 Aug 2015 13:35:19 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


Cache the value of __d_entry_type in d_is_dir and test if it equal to
DCACHE_DIRECTORY_TYPE or DCACHE_AUTODIR_TYPE.

The generated assembly goes from:
	movl	(%rdi), %eax  # MEM[(volatile __u32 *)dentry_3(D)], tmp73
	andl	$7340032, %eax  #, tmp73
	cmpl	$2097152, %eax  #, tmp73
	je	.L1091	#,
	movl	(%rdi), %eax	# MEM[(volatile __u32 *)dentry_3(D)], tmp74
	andl	$7340032, %eax	#, tmp74
	cmpl	$3145728, %eax	#, tmp74
	je	.L1091	#,
to:
	movl	(%rdi), %eax	# MEM[(volatile __u32 *)dentry_3(D)], tmp71
	andl	$6291456, %eax	#, tmp71
	cmpl	$2097152, %eax	#, tmp71
	jne	.L1091	  #,

Which with only one read of d_flags, one comparison and one jump is
dramatically better code.

As __d_entry_type is not written to allow the compiler to optimize
away anything that it does, when it is possible and reasonable to
optimize things away the optimization needs to be performend manually.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/dcache.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 5b69856b45a2..82eb50aaf446 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -443,7 +443,8 @@ static inline bool d_is_autodir(const struct dentry *dentry)
 
 static inline bool d_is_dir(const struct dentry *dentry)
 {
-	return d_can_lookup(dentry) || d_is_autodir(dentry);
+	unsigned type = __d_entry_type(dentry);
+	return (type == DCACHE_DIRECTORY_TYPE) || (type == DCACHE_AUTODIR_TYPE);
 }
 
 static inline bool d_is_symlink(const struct dentry *dentry)
-- 
2.2.1
