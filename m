From: "Tony Luck" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Tue, 29 Apr 2008 13:28:14 -0700
Message-ID: <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00__18935.244906652$1209501068$gmane$org@mail.gmail.com>
References: <20080211141646.948191000@bull.net>
	<20080211141813.354484000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080211141813.354484000-6ktuUTfB/bM@public.gmane.org>
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
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Feb 11, 2008 at 7:16 AM,  <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
>  Index: linux-2.6.24-mm1/ipc/msg.c
>  ===================================================================
>  --- linux-2.6.24-mm1.orig/ipc/msg.c     2008-02-07 15:02:29.000000000 +0100
>  +++ linux-2.6.24-mm1/ipc/msg.c  2008-02-07 15:24:19.000000000 +0100
...
>  +out_callback:
>  +
>  +       printk(KERN_INFO "msgmni has been set to %d for ipc namespace %p\n",
>  +               ns->msg_ctlmni, ns);
>  +}

This patch has now made its way to mainline.  I can see how this printk
was really useful to you while developing this patch. But does it add
much value in a production system? It just looks like another piece of
clutter on the console to my uncontainerized eyes.

-Tony
