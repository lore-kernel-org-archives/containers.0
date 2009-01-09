From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Fri, 09 Jan 2009 10:12:24 -0800
Message-ID: <87ljtkic1j.fsf@caffeine.danplanet.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<20090107180752.GA19153@us.ibm.com>
	<20090107191536.GA15159@megiteam.pl>
	<20090107193234.GA22625@us.ibm.com>
	<87priwifnu.fsf@caffeine.danplanet.com>
	<20090109174334.GA4526@redback.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090109174334.GA4526-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org> (Guenter Roeck's message of
	"Fri, 9 Jan 2009 09:43:35 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

GR> I have tried something similar, only with
GR> CLONE_FILES|CLONE_FS|CLONE_VM|CLONE_NEWNET, and actually creating
GR> a virtual interface and controlling socket or thread in each new
GR> network namespace.

My initial test was to create a veth pair and move one end into the
namespace during create.  That failed in the same way, so I took the
veth's out of the equation with the posted test.

GR> This scales to a couple of thousand interfaces, though interface
GR> creation takes a long time if more than 1,000 interfaces or so are
GR> created.

Yeah, just creating a bunch of pairs starts to slow down after a
hundred veth's or so.  I think that for thousands of network
namespaces, things would be pretty painful.

GR> I can send you the code if you like.

I'd like to see it.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
