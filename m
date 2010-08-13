From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Fri, 13 Aug 2010 03:35:55 +0200
Message-ID: <201008130335.55641.rjw__45644.5211697885$1281663497$gmane$org@sisk.pl>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<4C6252CF.1090100@inria.fr>
	<20100812002154.GJ2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100812002154.GJ2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tomasz Buchert <Tomasz.Buchert-MZpvjPyXg2s@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thursday, August 12, 2010, Matt Helsley wrote:
> On Wed, Aug 11, 2010 at 09:35:43AM +0200, Tomasz Buchert wrote:
> > Matt Helsley a =E9crit :
...
> You're right, cgroup_mutex should protect against that. However presumably
> that same logic applies to the first case. So again I don't think the bug
> is a race.
> =

> <snipped the remaining cases which should be the same>
> =

> At this point I think the bug description in your patch needs to change
> but the patch itself is perfect. Assuming you agree with my assessment
> of the bug I think the process is: you'll rewrite the description, add -s=
table
> maintaners to your current Cc's (since this bug is simple, exists in prev=
ious
> versions, and is somewhat nasty), add:
> =

> Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> =

> and send it to Andrew Morton. Hopefully then (if not before) Paul and Li
> will ack it.

Actaully, I maintain the freezer, so please send it to me.

Thanks,
Rafael
