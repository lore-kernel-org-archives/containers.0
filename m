From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: namespace acceptance process. bad news
Date: Wed, 05 Dec 2007 15:40:45 +0300
Message-ID: <47569C4D.4050609@sw.ru>
References: <475680A2.2000907@sw.ru> <47568471.1060503@fr.ibm.com>
	<47568A09.7050305@sw.ru> <20071205123355.GA26646@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
Cc: Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Kuznetsov <alexey-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
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

flowi does not take the ref. You will not :)

Regards,
	Den
