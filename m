From: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Fri, 9 Jan 2009 14:37:56 -0800
Message-ID: <20090109223756.GA22738@redback.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<20090107180752.GA19153@us.ibm.com>
	<20090107191536.GA15159@megiteam.pl>
	<20090107193234.GA22625@us.ibm.com>
	<87priwifnu.fsf@caffeine.danplanet.com>
	<20090109174334.GA4526@redback.com>
	<87ljtkic1j.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ljtkic1j.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 09, 2009 at 10:12:24AM -0800, Dan Smith wrote:
> GR> I have tried something similar, only with
> GR> CLONE_FILES|CLONE_FS|CLONE_VM|CLONE_NEWNET, and actually creating
> GR> a virtual interface and controlling socket or thread in each new
> GR> network namespace.
> 
> My initial test was to create a veth pair and move one end into the
> namespace during create.  That failed in the same way, so I took the
> veth's out of the equation with the posted test.
> 
> GR> This scales to a couple of thousand interfaces, though interface
> GR> creation takes a long time if more than 1,000 interfaces or so are
> GR> created.
> 
This is at least to some degree due to the problems I mentioned earlier.
Enhancing the kernel name hash and the sysfs implementation improves
performance a lot.

> Yeah, just creating a bunch of pairs starts to slow down after a
> hundred veth's or so.  I think that for thousands of network
> namespaces, things would be pretty painful.
> 
> GR> I can send you the code if you like.
> 
> I'd like to see it.
> 
See attached. I used the "ctx" module in the attached code to create interfaces, 
so you'll have to compile and insmod it if you want to create interfaces.

Guenter

--dDRMvlgZJXvWKvBx
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="netclone.tar.gz"
Content-Transfer-Encoding: base64

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
UAAA

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--dDRMvlgZJXvWKvBx--
