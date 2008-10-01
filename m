From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 19:31:13 +0400
Message-ID: <48E397C1.6050407__5876.86699950627$1222875529$gmane$org@openvz.org>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	<48E35B4C.1040303@fr.ibm.com>
	<1222860776.23573.49.camel@iris.sw.ru>
	<48E3653C.1070701@fr.ibm.com>
	<1222862583.23573.54.camel@iris.sw.ru>
	<48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
	<48E36DA0.9080400@fr.ibm.com>
	<1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com>
	<1222872885.23573.64.camel@iris.sw.ru>
	<48E394D2.5090709@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48E394D2.5090709-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> Yes per namespace, I agree.
> 
> If the option is controlled by the parent and it is done by sysctl, you 
> will have to make proc/sys per namespace like Pavel did with /proc/net, no ?

/proc/sys is already per namespace actually ;) Or what did you mean by that?
