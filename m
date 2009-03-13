From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum
	checkpoint/restart	implementation
Date: Fri, 13 Mar 2009 16:42:20 +0100
Message-ID: <49BA7EDC.1000705@free.fr>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>	<1233182478-27113-2-git-send-email-ntl@pobox.com>	<49814FA2.9060108@cs.columbia.edu>	<20090129214035.GB6913@localdomain>	<20090217010355.58afd5cf@thinkcentre.lan>
	<49B9D37A.1070503@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49B9D37A.1070503-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


> More specifically, I envision restart to work like this:
> 
> 1) user invokes user-land utility (e.g. "cr --restart ..."
> 2) 'cr' will create a new container
> 3) 'cr' will start a child in that container

process 1 in its private namespaces.

> 4) child will create rest of tree (in kernel or in user space - tbd)
> 5) each task in that tree will restore itself
> 6) 'cr' monitors this process
> 7) if all goes well - 'cr' report ok.
> 8) if something goes bad, 'cr' notices and notifies caller/user

that's MCR implementation of restart. 
 
> so tasks that are restarting may just as well die badly - we don't care.

just sigkill them, but at end, before releasing the container from 
a frozen state, we have to make sure the right number of tasks have 
restarted ... so you need to track them along the way.

C.
