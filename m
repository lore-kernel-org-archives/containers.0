From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: net-2.6.25-netns branch on git.openvz.org
Date: Thu, 15 Nov 2007 14:00:49 +0100
Message-ID: <473C4301.6060507@fr.ibm.com>
References: <473C35F1.9030901@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473C35F1.9030901-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Hi, All!
> 
> I have ported what is ready to send to netdev to 2.6.25 and created
> appropriate branches on git.openvz.org, namely
> - net-2.6.25 aka Miller's 2.6.25 tree
> - net-2.6.25-netns with ready patches

resyncing ... thanks :)

I will send in a few moments a first round for ipv6 taking into account 
ip6_fib.

There some other pending patches I will send, I hope before the end of 
the week.

I am a little lost with what we want to send for net-2.6.25. I mean we 
planned to send af_unix, af_packet, af_netlink, af_inet and af_inet6.

What is the level of functionnality we want to provide with ipv4 and 
ipv6. For example we have addresss autoconfiguration for ipv6, shall we 
send it ?

What about the todo list Pavel planned to do ?
