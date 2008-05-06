From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Tue, 6 May 2008 13:05:27 -0500
Message-ID: <20080506180527.GA8315__17847.8981637911$1210097268$gmane$org@sergelap.austin.ibm.com>
References: <20080211141646.948191000@bull.net>
	<20080211141813.354484000@bull.net>
	<12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
	<481EC917.6070808@bull.net>
	<1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC014392F9-7XlYjKTK0pM64kNsxIetb7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Luck, Tony (tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org):
> > Well, this printk had been suggested by somebody (sorry I don't remember 
> > who) when I first submitted the patch. Actually I think it might be 
> > useful for a sysadmin to be aware of a change in the msgmni value: we 
> > have the message not only at boot time, but also each time msgmni is 
> > recomputed because of a change in the amount of memory.
> 
> If the message is directed at the system administrator, then it would
> be nice if there were some more meaningful way to show the namespace
> that is affected than just printing the hex address of the kernel structure.
> 
> As the sysadmin for my test systems, printing the hex address is mildly
> annoying ... I now have to add a new case to my scripts that look at
> dmesg output for unusual activity.
> 
> Is there some better "name for a namespace" than the address? Perhaps
> the process id of the process that instantiated the namespace???

I agree with Tony here.  Aside from the nuisance it is to see that
message on console every time I unshare a namespace, a printk doesn't
seem like the right way to output the info.  At most I'd say an audit
message.

-serge
