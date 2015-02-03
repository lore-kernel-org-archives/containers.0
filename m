From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [CRIU] CRIU @Plumbers
Date: Tue, 3 Feb 2015 17:58:30 +0300
Message-ID: <54D0E216.3040007@parallels.com>
References: <54CF4BFF.8070505@parallels.com>	<20150202170609.GA2517@hopstrocity>
	<CA+Um-gj1ynTwOsQNV7482Lz2GsCX+Leuz=QdSfPL1MVaF1CRGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+Um-gj1ynTwOsQNV7482Lz2GsCX+Leuz=QdSfPL1MVaF1CRGQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Saied Kazemi <saied-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/02/2015 10:19 PM, Saied Kazemi wrote:
> Given the wide spectrum of CRIU use cases, I am also in favor of organizing a 
> separate track for it.
> 
> To that end, I can present and do a live demo of how CRIU was used to provide
> native Docker container checkpoint and restore.  This can be a full presentation
> by itself or combined with another presentation.

That's great :) I'll start filling the page with data soon then. Feel free to
join and add the stuff you want.

> A minor nit: for consistency, can we call it checkpoint/restore instead of checkpoint/restart?

Google gives ~600k results for "checkpoint/restart" vs ~900k for "checkpoint/restore"
so I don't mind :)

> --Saied
> 
> 
> On Mon, Feb 2, 2015 at 9:06 AM, Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org <mailto:tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>> wrote:
> 
>     On Mon, Feb 02, 2015 at 01:05:51PM +0300, Pavel Emelyanov wrote:
>     > Hi,
>     >
>     > There's a call for micro-conferences now open at the upcoming Plumbers
>     > conference [1]. Before this one, CRIU was typically included into the
>     > containers MC [2], but this year we can try to organize a separate [3]
>     > track if there's enough topics and attendees.
>     >
>     > Suggestions and thoughts are welcome.
> 
>     I'm very interested, hopefully I can (I should) get back some time to
>     work on CRIU to have something to present.
> 
>     Tycho
> 
>     > Thanks,
>     > Pavel
>     >
>     >
>     > [1] http://wiki.linuxplumbersconf.org/2015:topics
>     > [2] http://wiki.linuxplumbersconf.org/2015:containers
>     > [3] http://wiki.linuxplumbersconf.org/2015:ckptrestart
>     > _______________________________________________
>     > CRIU mailing list
>     > CRIU-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org <mailto:CRIU-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>     > https://lists.openvz.org/mailman/listinfo/criu
>     _______________________________________________
>     CRIU mailing list
>     CRIU-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org <mailto:CRIU-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>     https://lists.openvz.org/mailman/listinfo/criu
> 
> 
