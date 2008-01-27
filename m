From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH 1/2] dm-band: The I/O bandwidth controller: Source code
	patch
Date: Sun, 27 Jan 2008 16:44:53 +0100
Message-ID: <E1JJ9gj-0001SH-U2__14637.7514502548$1201448812$gmane$org@faramir.fjphome.nl>
References: <20080123.215350.193721890.ryov@valinux.co.jp>
	<20080123.215632.226773739.ryov@valinux.co.jp>
	<E1JHfjM-0003NV-BR@faramir.fjphome.nl>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-To: <E1JHfjM-0003NV-BR-QuJFzwv6nO7YRozH8XE8NfP6llvjuJOh@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Frans Pop wrote:
> The help should probably be a bit more verbose as this does not tell
> anybody much who has not already read the documentation.
> 
> Maybe something like:
> <snip>
> This device-mapper target allows to define how the
> available bandwith of a storage device should be
> shared between processes or cgroups.
> 
> Information on how to use dm-band is available in:
>    Documentation/device-mapper/band.txt
> </snip>

I just see in other Kconfig files that the last line should be:
   <file:Documentation/device-mapper/band.txt>.

Cheers,
FJP
