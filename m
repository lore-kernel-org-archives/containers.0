From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Naming the "Task containers" framework
Date: Wed, 05 Sep 2007 11:55:07 +0200
Message-ID: <46DE7CFB.6020200@fr.ibm.com>
References: <6599ad830709042254t2d5c4f54y964c74e3c6d9a6ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830709042254t2d5c4f54y964c74e3c6d9a6ab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:

> At the mini-summit, and at other times, I've heard the repeated
> complaint that having the word "container" in the name of the "task
> container" framework leads to ambiguity. And separately from the
> complaints, I've seen the awkwardness that people end up with when
> they feel they have to distinguish between the "containers" abstract
> concept, and "Paul's containers" ...
> 
> With the hope/prospect of having the framework merged some time after
> the kernel summit, I guess now's a good time to bow to the pressure
> and find some compromise that everyone likes, before we actually hit
> mainline. (Maybe earlier would have been even better, but ...)
> 
> Of the various possible names that have been suggested, there are a
> couple that (to me) stand out as good options:
> 
> - control groups
> - task sets

task controllers ?

C. 

> The former (coined by Eric during a brainstorming session yesterday)
> seems to capture the enforcement aspect of the framework (sysadmin can
> use it to control the behaviour of processes, processes can't escape
> from groups), without suggesting that it can only be used for resource
> controllers (as some alternative names such as "resource groups"
> imply) and would be a choice that I could be happy with.
> 
> Does anyone have strong views on other alternative names (or even the
> idea of keeping "task containers")?
> 
> Paul
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
