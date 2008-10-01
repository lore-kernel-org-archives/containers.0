From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 17:07:40 +0200
Message-ID: <48E3923C.5070603__41527.6746768088$1222873808$gmane$org@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org>	<48E35B4C.1040303@fr.ibm.com>	<1222860776.23573.49.camel@iris.sw.ru>	<48E3653C.1070701@fr.ibm.com>	<1222862583.23573.54.camel@iris.sw.ru>	<48E36ABF.8030908@fr.ibm.com>	<48E36BFA.3040904@openvz.org>	<48E36DA0.9080400@fr.ibm.com>	<48E36FDA.5090808@openvz.org>
	<48E37637.8080408@fr.ibm.com> <48E3800F.1020806@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48E3800F.1020806-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, benjamin.thery-6ktuUTfB/bM@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Cedric Le Goater wrote:
>> Pavel Emelyanov wrote:
>>> Daniel Lezcano wrote:
>>>> Pavel Emelyanov wrote:
>>>>>> So there are 2 cases:
>>>>>>   * full isolation : restriction on VPS
>>>>>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>>>>>
>>>>>> Looks like we need an option per namespace to reduce the isolation for 
>>>>>> af_unix sockets :)
>>>>>>   - on (default): current behaviour => full isolation
>>>>>>   - off : partial isolation
>>>>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
>>>> Yes.
>>> OK. Den, please, do :)
>> hmm, would that allow sibling namespaces to connect to each other ? If so, 
>> I'm not in favor of such a solution. 
>>
>> I understand the need. we had a similar issue with the command line tool 
>> pgsl. Could we work something out with the capabilities ? or make an 
>> exception if your ->nsproxy->net_ns == init_net ? 
> 
> Why capabilities is better than a simple sysctl ?

because it depends on the current process privilege and not just some
random process.

> Making an exception for init_net will break the nested containers no ?

may be. I don't know how this is implemented. if we break isolation, my
feeling is that we should only do it for a parent namespace. It just feel 
wrong to allow sibling namespaces to connect to each other. 

C. 
