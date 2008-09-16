From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 8/8] Dump open file descriptors
Date: Tue, 16 Sep 2008 08:54:46 -0700
Message-ID: <1221580486.20360.1.camel__14487.9713574939$1221580777$gmane$org@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-9-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-9-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
> 
> +static int
> +cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int
> fd)
> +{
> +       struct cr_hdr h;
> +       struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +       struct file *file = NULL;
> +       struct fdtable *fdt;
> +       int coe, objref, new, ret;
> +
> +       rcu_read_lock();
> +       fdt = files_fdtable(files);
> +       file = fcheck_files(files, fd);
> +       if (file) {
> +               coe = FD_ISSET(fd, fdt->close_on_exec);
> +               get_file(file);
> +       }
> +       rcu_read_unlock();
> +
> +       /* sanity check (although this shouldn't happen) */
> +       if (!file)
> +               return -EBADF;
> +
> +       new = cr_obj_add_ptr(ctx, (void *) file, &objref, CR_OBJ_FILE, 0);

Dude, you don't need to cast to void*.  

-- Dave
