From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v2] core_pattern: set core helpers root and namespace to
	crashing process
Date: Fri, 14 Dec 2012 13:49:15 -0800
Message-ID: <20121214134915.06ce91e3.akpm@linux-foundation.org>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
	<1355519048-28473-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355519048-28473-1-git-send-email-nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 14 Dec 2012 16:04:08 -0500
Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:

> As its currently implemented, redirection of core dumps to a pipe reader should
> be executed such that the reader runs in the namespace of the crashing process,
> and it currently does not. This is the only sane way to deal with namespaces
> properly it seems to me, and this patch implements that functionality.
> 
> Theres one problem I currently see with it, and that is that I'm not sure we can
> change the current behavior of how the root fs is set for the pipe reader, lest
> we break some user space expectations.  As such I've made the switching of
> namespaces configurable based on the addition of an extra '|' token in the
> core_pattern sysctl.  1 '|' indicates a pipe using the global namespace, while
> 2 '|' indicates that the namespace and root of the crashing process should be
> used.
> 
> I've tested this using both settings for the new sysctl, and it works well.
> 
> For the sake of history, this was discussed before:
> http://www.spinics.net/lists/linux-containers/msg21531.html
> 
> It seems there was some modicum of consensus as to how this should work, but
> there was no action taken on it.
> 
> --- a/fs/coredump.c
> +++ b/fs/coredump.c
> @@ -164,6 +164,18 @@ static int format_corename(struct core_name *cn, struct coredump_params *cprm)
>  	if (!cn->corename)
>  		return -ENOMEM;
>  
> +	if (ispipe) {
> +		/*
> + 		 * If we have 2 | tokens at the head of core_pattern, it
> + 		 * indicates we are a pipe and the reader should inherit the
> + 		 * namespaces of the crashing process
> + 		 */
> +		cprm->switch_ns = (*(pat_ptr+1) == '|') ? true : false;
> +		if (cprm->switch_ns)
> +			/* Advance pat_ptr so as not to mess up corename */
> +			pat_ptr++;
> +	}
> +

That was, umm, intricate.  How's about this?

	if (ispipe && pat_ptr[1] == '|') {
		/*
 		 * We have 2 | tokens at the head of core_pattern which
 		 * indicates we are a pipe and the reader should inherit the
 		 * namespaces of the crashing process
 		 */
		cprm->switch_ns = true;
		pat_ptr++;
	}


--- a/Documentation/sysctl/kernel.txt~core_pattern-set-core-helpers-root-and-namespace-to-crashing-process-fix
+++ a/Documentation/sysctl/kernel.txt
@@ -194,7 +194,7 @@ core_pattern is used to specify a core d
   written to the standard input of that program instead of to a file.  Note that
   when using |, the core pipe reader that is executed will be run in the global
   namespace and root filesystem.  If two | tokens (i.e. ||) are supplied as the
-  first two characters of the core_pattern sysctl, the kernel will preform the
+  first two characters of the core_pattern sysctl, the kernel will perform the
   same pipe operation, but the core pipe reader will be executed using the
   namespace and root fs of the crashing process.
 
--- a/fs/coredump.c~core_pattern-set-core-helpers-root-and-namespace-to-crashing-process-fix
+++ a/fs/coredump.c
@@ -164,16 +164,14 @@ static int format_corename(struct core_n
 	if (!cn->corename)
 		return -ENOMEM;
 
-	if (ispipe) {
+	if (ispipe && pat_ptr[1] == '|') {
 		/*
- 		 * If we have 2 | tokens at the head of core_pattern, it
+ 		 * We have 2 | tokens at the head of core_pattern which
  		 * indicates we are a pipe and the reader should inherit the
  		 * namespaces of the crashing process
  		 */
-		cprm->switch_ns = (*(pat_ptr+1) == '|') ? true : false;
-		if (cprm->switch_ns)
-			/* Advance pat_ptr so as not to mess up corename */
-			pat_ptr++;
+		cprm->switch_ns = true;
+		pat_ptr++;
 	}
 
 	/* Repeat as long as we have more pattern to process and more output
_
