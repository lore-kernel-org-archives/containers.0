From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: namespace acceptance process. bad news
Date: Wed, 05 Dec 2007 14:20:10 +0100
Message-ID: <4756A58A.8050103@fr.ibm.com>
References: <475680A2.2000907@sw.ru> <47568471.1060503@fr.ibm.com>
	<47568A09.7050305@sw.ru> <20071205123355.GA26646@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071205123355.GA26646-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Kuznetsov <alexey-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
>> Alexey seems to disagree with this approach, is it possible to elaborate
>> a little bit ?
> 
> My first reaction was exactly the same as David's one. Exactly. :-)
> 
> flowi structure was invented to be both easily initialized/disposed
> as a local variable and copied/stored in various caches as a key.
> 
> If it has some reference inside, it becomes really ugly.
> 
> But it is the first reaction. I guess you do not have much of choice.
> The only alternative is to add an additional argument to functions
> taking flowi, which is even uglier.
> 
> So, it looks like netns still have to go to flowi, but functions copying
> flowi (in route.c/flow.c/whatever) should not use raw memcpy to store this
> and must remember that saving flowi is possible only when refcnt to netns
> is held somewhere.
> 
> Alexey

Thanks Alexey for your analysis.

There is no refcount for netns held because it is used as an identifier. 
  We can perhaps make it clear by changing the field fl_net by:

	struct net *fl_net => unsigned long fl_net_key;

In this case, we must track all places where we reused fl_net as a 
pointer to retrieve the netns like in route.c, fib_hash.c or fib_rules.c 
because in this case we must held a reference. So the functions will 
probably take a new netns parameter or pick the netns pointer from 
somewhere else.
