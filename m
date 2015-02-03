From: Saied Kazemi <saied-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [CRIU] CRIU @Plumbers
Date: Tue, 3 Feb 2015 08:21:36 -0800
Message-ID: <CA+Um-gh=gzBOgdv6e4jmJAE=o3fPKYVhmunUcifYBsfyD3SccA@mail.gmail.com>
References: <54CF4BFF.8070505@parallels.com>
	<20150202170609.GA2517@hopstrocity>
	<CA+Um-gj1ynTwOsQNV7482Lz2GsCX+Leuz=QdSfPL1MVaF1CRGQ@mail.gmail.com>
	<54D0E216.3040007@parallels.com> <54D0F2EC.4040702@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <54D0F2EC.4040702-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Since everyone is in agreement, let's call it checkpoint/restore then.
Restart often implies stop + start and, in fact, Docker already has a
restart command which does exactly that.

--Saied


On Tue, Feb 3, 2015 at 8:10 AM, Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
wrote:

> On 02/03/2015 09:58 AM, Pavel Emelyanov wrote:
> > On 02/02/2015 10:19 PM, Saied Kazemi wrote:
> >> Given the wide spectrum of CRIU use cases, I am also in favor of
> organizing a
> >> separate track for it.
> >>
> >> To that end, I can present and do a live demo of how CRIU was used to
> provide
> >> native Docker container checkpoint and restore.  This can be a full
> presentation
> >> by itself or combined with another presentation.
> >
> > That's great :) I'll start filling the page with data soon then. Feel
> free to
> > join and add the stuff you want.
> >
> >> A minor nit: for consistency, can we call it checkpoint/restore instead
> of checkpoint/restart?
> >
> > Google gives ~600k results for "checkpoint/restart" vs ~900k for
> "checkpoint/restore"
> > so I don't mind :)
>
> I prefer "restore" (perhaps a more migration focused term) myself, but I
> think
> there is some history behind "restart" (perhaps a more fault tolerance
> focused
> term) from at least the Berkeley Lab's Checkpoint/Restart project, which
> has
> software releases from 2005 and papers from 2002.
>
> http://crd.lbl.gov/departments/computer-science/CLaSS/research/BLCR/
>
> http://crd.lbl.gov/departments/computer-science/CLaSS/research/BLCR/checkpoint-restart-publications/
>
> Chris
>
> --
> Qualcomm Innovation Center, Inc.
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
>
