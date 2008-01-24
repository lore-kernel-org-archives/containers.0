From: Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] LTP result output for container-init
Date: Thu, 24 Jan 2008 18:05:14 +0530
Message-ID: <OF82DD4C87.61CF4454-ON652573DA.0044C63D-652573DA.004530C1@in.ibm.com>
References: <1200497268.3999.17.camel@localhost.localdomain>
	<47986165.4050407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47986165.4050407-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Poornima Nayak <Poornima.Nayak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote on 01/24/2008 03:29:01 PM:

> Rishikesh K. Rajak wrote:
> > Hi All,
> >
> > Today i ran full LTP on kernel 2.6.24-rc6 inside container-init and
also
> > on parent namespace and got some observations.
>
> The says it passed, but the status is "some facilities failed to
> work" and the log file says that the test failed %)
>
> I launched ltp on my box but the 01, 02 and 08 syslog tests
> passed... I have a CentOS 4 setup on this node, maybe this
> is a SuSE issue? Rishikesh, can you try this on another OS?

Sure pavel let me try this. One more thing as these failures when i run LTP
on parent namespace  as same you told like *some facilities failed to
work*, but it pass when i run LTP inside container,

Thanks
Rishi
>
> > Please let me know your opinion on this.
> >
> > Thanks
> >
> > Rishi
> > IBM LTC
> > Bangalore
> >
> >
> >
> >
------------------------------------------------------------------------
> >
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> >
> >
> >
------------------------------------------------------------------------
> >
> > _______________________________________________
> > Devel mailing list
> > Devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> > https://openvz.org/mailman/listinfo/devel
>
