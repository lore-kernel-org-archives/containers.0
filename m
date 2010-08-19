From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Thu, 19 Aug 2010 10:37:15 +0200
Message-ID: <4C6CED3B.3050709__20462.006054777$1282207081$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<20100810215741.GC2927@count0.beaverton.ibm.com>
	<4C61D044.2060703@inria.fr>
	<20100811042738.GH2927@count0.beaverton.ibm.com>
	<4C6252CF.1090100@inria.fr>
	<20100812002154.GJ2927@count0.beaverton.ibm.com>
	<4C634605.50301@inria.fr>
	<20100812201334.GA29096@count0.beaverton.ibm.com>
	<4C6B339E.6010907@inria.fr>
	<20100818022210.GH3648@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100818022210.GH3648-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Le 18/08/2010 04:22, Matt Helsley a =E9crit :
> On Wed, Aug 18, 2010 at 03:13:02AM +0200, Tomasz Buchert wrote:
>> Le 12/08/2010 22:13, Matt Helsley a =E9crit :
>
> <snip>
>
>>
>> Matt,
>> Am I supposed to do something right now? The discussion
>> became a bit quiet recently.
>>
>> Cheers,
>> Tomasz
>
> Hi Tomasz,
>
> 	I'm sorry. I haven't had much time to review your latest
> patches and comment. I thought Andrew put them in his -mm tree
> so I don't think you have anything to do at the moment.
>
> Cheers,
> 	-Matt

Take your time, Matt. I only wish that eventually the problem will be =

fixed, that or another way.

Tomek
