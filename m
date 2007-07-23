From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: containers development plans (July 20 version)
Date: Mon, 23 Jul 2007 09:27:45 -0500
Message-ID: <20070723142745.GE22936@sergelap.austin.ibm.com>
References: <20070720173615.GA25167@vino.hallyn.com>
	<1184966978.10091.448.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1184966978.10091.448.camel-7OsMPKyG+FJSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rohit Seth <rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ckrm-tech-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, cpw-sJ/iWh9BUns@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Rohit Seth (rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> Thanks Serge for collecting these requirements.  Have we decided on
> container mini summit?

I think we've decided to have one, but someone needs to implement the
details.  Someone (Kirill?) mentioned having a "private" mini-summit for
conference attendees, followed by a call-in conference.  So we would
need a meeting room and time at LCE, followed by a meeting room with a
phone.  I suppose someone's hotel room would work as well...

Personally I'd prefer to have just one mini-summit, with a live call-in
phone number, so noone feels like there's shady back-room goings on.
But on the other hand productivity of the mini-summit could be squashed
by poor phone line quality or phone etiquette...

> Couple of points that I want to add in task
> container functionality section (not sure if these are already covered
> by items below):
> 
> 1- Per container dirty page (write throttling) limit.
> 2- Per container memory reclaim
> 3- network rate limiting (outbound) based on container
> 4- User level APIS to identify the resource limits that is allowed to a
> job, for example, how much physical memory a process can use.  This
> should seamlessly integrated with non-container environment as well (may
> be with ulimit).
> 5- Similary, per container stats, like pages on active list, cpus usage
> etc. could also be very helpful.

Thanks, will add these.

-serge
