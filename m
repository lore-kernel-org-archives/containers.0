From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Mon, 11 Dec 2017 08:52:43 -0800
Message-ID: <50813ebc-5de7-c930-79dc-c1d3cfcfb172__32647.4670706832$1513011192$gmane$org@schaufler-ca.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
	<7ebca85a-425c-2b95-9a5f-59d81707339e@digikod.net>
	<f8ea78be-9bbf-2967-7b12-ac93bb85b0bc@schaufler-ca.com>
	<1513009857.6310.337.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1513009857.6310.337.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/11/2017 8:30 AM, Eric Paris wrote:
> On Sat, 2017-12-09 at 10:28 -0800, Casey Schaufler wrote:
>> Because a container doesn't have to use namespaces to be a container
>> you still need a mechanism for a process to declare that it is in
>> fact
>> in a container, and to identify the container.
> I like the idea but I'm still tossing it around in my head (and
> thinking about Casey's statement too). Lets say we have a 'docker-like' 
> container with pid=100  netns=X,userns=Y,mountns=Z. If I'm on the host
> in all init namespaces and I run
>   nsenter -t 100 -n ip link set eth0 promisc on
> How should this be logged? Did this command run in it's own 'container'
> unrelated to the 'docker-like' container?

Jose Bollo's PTAGS ( https://gitlab.com/jobol/ptags ) would be
prefect. Any time you declare something to be a container or
enter a namespace you slap a tag on it. Identifying nested
containers would be easy, you'd have multiple tags.

PTAGS unfortunately needs module stacking, but how hard could that be?


> -Eric
