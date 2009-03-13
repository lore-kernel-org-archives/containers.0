From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Thu, 12 Mar 2009 19:12:21 -0500
Message-ID: <20090313001221.GA13213@hallyn.com>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<20090312224820.GA12723@hallyn.com>
	<87bps6pcyf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bps6pcyf.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> SH> Well it forces restart to go through the established userspace
> SH> API's when creating resources (in this case, tasks and namespaces)
> SH> which means any existing security guarantees are leveraged.
> 
> That's a very valid point.  However, it still seems unbalanced to make
> checkpoint a completely in-kernel process and restart an odd mix of
> the two with potentially more confusing semantics and requirements.

core_dump vs gdb? :)

> SH> If we go with your patch, we suddenly have to worry about whether
> SH> restart is a way to get around the CAP_SYS_ADMIN requirements for
> SH> cloning a new namespace.  Just as an example.
> 
> Why?  The call to copy_namespaces() will do the CAP_SYS_ADMIN check,

Had to check, but yes you're right.

> right?  Maybe your point is that in the restart implementation of
> other namespace types we could potentially slide in a call to
> something else that has already assumed the check has been made?  I
> think that doing the obligatory copy_namespaces() during the restart
> helps catch that case early and explicitly, no?

Actually we can go a step further and say we expect user-space to
set the hostname, which otherwise (admittedly in a container) the
user, with your patch, can now do unprivileged, right?

In particular, once it comes to setting up network devices for a
container at restart, I think we'll find userspace a far easier
place to work.

-serge
