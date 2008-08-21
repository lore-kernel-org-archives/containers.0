From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 9/9] File descriprtors (restore)
Date: Thu, 21 Aug 2008 01:26:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808210122510.4445__29658.9304031388$1219296592$gmane$org@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202307270.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202307270.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


>
> Restore open file descriptors: for each FD read 'struct cr_hdr_fd_ent'
> and lookup tag in the hash table; if not found (first occurence), read
> in 'struct cr_hdr_fd_data', create a new FD and register in the hash.
> Otherwise attach the file pointer from the hash as an FD.
>
> This patch only handles basic FDs - regular files, directories and also
> symbolic links.
>
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  checkpoint/Makefile     |    2 +-
>  checkpoint/checkpoint.c |    3 +
>  checkpoint/ckpt.h       |    6 +-
>  checkpoint/restart.c    |    3 +
>  checkpoint/rstr_file.c  |  202 +++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 213 insertions(+), 3 deletions(-)
>  create mode 100644 checkpoint/rstr_file.c
>

To restore the open files, cr_read_files() first closes all the
existing FDs of the current process. This breaks the assumption
underlying the use of fget_light/fput_light in sys_restart(), so
use fget/fput instead.


diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7b2670a..ec1609b 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -210,10 +210,9 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
  {
  	struct cr_ctx *ctx;
  	struct file *file;
-	int fput_needed;
  	int ret;

-	file = fget_light(fd, &fput_needed);
+	file = fget(fd);
  	if (!file)
  		return -EBADF;

@@ -223,14 +222,14 @@ asmlinkage long sys_restart(int crid, int fd, unsigned long flags)

  	ctx = cr_ctx_alloc(crid, file, flags | CR_CTX_RSTR);
  	if (!ctx) {
-		fput_light(file, fput_needed);
+		fput(file);
  		return -ENOMEM;
  	}

  	ret = do_restart(ctx);

  	cr_ctx_free(ctx);
-	fput_light(file, fput_needed);
+	fput(file);

  	return ret;
  }
