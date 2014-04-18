From: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Subject: Re: [PATCH v2] xt_quota2: introduce support for network namespaces
Date: Fri, 18 Apr 2014 19:20:52 +0200 (CEST)
Message-ID: <alpine.LSU.2.11.1404181920430.11175__47107.0651816719$1397841665$gmane$org@nerf08.vanv.qr>
References: <20140305110756.GA16910@earthship.local.cellrox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140305110756.GA16910-XJ2GtpFvYOzcMLnvn52sfNwH0Wv7OWhXQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Golle <dgolle-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Cc: Netfilter Developer Mailing List <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jpa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 2014-03-05 12:07, Daniel Golle wrote:

>Initialize a separate xt_quota2 instance for each network
>namespace so data limit can be set and enforced per container.

That's applied now.
