From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v6][PATCH 5/9] Restore memory address space
Date: Wed, 08 Oct 2008 08:35:45 -0700
Message-ID: <1223480145.11830.3.camel__9908.11904562197$1223481147$gmane$org@nimitz>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	<1223461197-11513-6-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1223461197-11513-6-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-10-08 at 06:19 -0400, Oren Laadan wrote:
> 
> +static int cr_read_private_vma_contents(struct cr_ctx *ctx)
> +{
> +       struct cr_hdr_pgarr *hh;
> +       unsigned long nr_pages;
> +       int parent, ret = 0;
> +
> +       while (1) {
> +               hh = cr_hbuf_get(ctx, sizeof(*hh));
> +               parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_PGARR);
> +               if (parent != 0) {
> +                       if (parent < 0)
> +                               ret = parent;
> +                       else
> +                               ret = -EINVAL;
> +                       cr_hbuf_put(ctx, sizeof(*hh));
> +                       break;
> +               }
> +
> +               cr_debug("nr_pages %ld\n", (unsigned long) hh->nr_pages);
> +
> +               nr_pages = hh->nr_pages;
> +               cr_hbuf_put(ctx, sizeof(*hh));
> +
> +               if (!nr_pages)
> +                       break;
> +
> +               ret = cr_read_pages_vaddrs(ctx, nr_pages);
> +               if (ret < 0)
> +                       break;
> +               ret = cr_read_pages_contents(ctx);
> +               if (ret < 0)
> +                       break;
> +               cr_pgarr_reset_all(ctx);
> +       }
> +
> +       return ret;
> +}

This basically just uses a while(1) loop with 'break' instead of an
'out_err:' label and some gotos.  That's kinda odd for the kernel.  

-- Dave
