From: "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Tue, 6 May 2008 09:42:25 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843EC014392F9__6617.67241913385$1210092354$gmane$org@orsmsx424.amr.corp.intel.com>
References: <20080211141646.948191000@bull.net>	
	<20080211141813.354484000@bull.net>
	<12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
	<481EC917.6070808@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <481EC917.6070808-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

> Well, this printk had been suggested by somebody (sorry I don't remember 
> who) when I first submitted the patch. Actually I think it might be 
> useful for a sysadmin to be aware of a change in the msgmni value: we 
> have the message not only at boot time, but also each time msgmni is 
> recomputed because of a change in the amount of memory.

If the message is directed at the system administrator, then it would
be nice if there were some more meaningful way to show the namespace
that is affected than just printing the hex address of the kernel structure.

As the sysadmin for my test systems, printing the hex address is mildly
annoying ... I now have to add a new case to my scripts that look at
dmesg output for unusual activity.

Is there some better "name for a namespace" than the address? Perhaps
the process id of the process that instantiated the namespace???

-Tony
