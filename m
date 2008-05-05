From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Mon, 05 May 2008 10:45:11 +0200
Message-ID: <481EC917.6070808__29508.1993951046$1209977313$gmane$org@bull.net>
References: <20080211141646.948191000@bull.net>	
	<20080211141813.354484000@bull.net>
	<12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tony Luck <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Tony Luck wrote:
> On Mon, Feb 11, 2008 at 7:16 AM,  <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
> 
>> Index: linux-2.6.24-mm1/ipc/msg.c
>> ===================================================================
>> --- linux-2.6.24-mm1.orig/ipc/msg.c     2008-02-07 15:02:29.000000000 +0100
>> +++ linux-2.6.24-mm1/ipc/msg.c  2008-02-07 15:24:19.000000000 +0100
> 
> ...
> 
>> +out_callback:
>> +
>> +       printk(KERN_INFO "msgmni has been set to %d for ipc namespace %p\n",
>> +               ns->msg_ctlmni, ns);
>> +}
> 
> 
> This patch has now made its way to mainline.  I can see how this printk
> was really useful to you while developing this patch. But does it add
> much value in a production system? It just looks like another piece of
> clutter on the console to my uncontainerized eyes.
> 
> -Tony
> 
> 


Well, this printk had been suggested by somebody (sorry I don't remember 
who) when I first submitted the patch. Actually I think it might be 
useful for a sysadmin to be aware of a change in the msgmni value: we 
have the message not only at boot time, but also each time msgmni is 
recomputed because of a change in the amount of memory.
Also, at boot time, I think it's interesting to have the actual msgmni 
value: it used to unconditionally be set to 16. Some applications that 
used to need an initialization script setting msgmni to a higher value 
might not need that script anymore, since the new value might fit their 
needs.

Regards,
Nadia
