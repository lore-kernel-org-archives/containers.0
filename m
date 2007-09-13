From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Signal semantics for /sbin/init
Date: Thu, 13 Sep 2007 17:40:27 +0200
Message-ID: <46E959EB.2070207@fr.ibm.com>
References: <20070911041030.GA1264@us.ibm.com>
	<20070911111928.GA123@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070911111928.GA123-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 09/10, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>> (This is Oleg's patch with my pid ns additions. Compiled and unit tested
>> on 2.6.23-rc4-mm1 with other patches in this set. Oleg pls update this
>> patch if necessary and sign-off)
> 
> Sukadev, my apologies. This patch does need some changes,
> 
>> Notes:
>>
>> 	- Blocked signals are never ignored, so init still can receive
>> 	  a pending blocked signal after sigprocmask(SIG_UNBLOCK).
>> 	  Easy to fix, but probably we can ignore this issue.
> 
> I was wrong. This should be fixed right now. I _think_ this is easy,
> and I was going to finish this patch yesterday, but - sorry! - I just
> can't switch to "kernel mode" these days, I am fighting with some urgent
> tasks on my paid job.
> 
> Please feel free to solve this issue yourself if you wish. As for me, I'm
> forgetting about the kernel until at least the next weekend.
> 
> Also, Pavel has some ideas how to do this all on receiver's path, perhaps
> this makes more sense (not that I completely agree, but I didn't see the
> code yet).

To respect the current init semantic, shouldn't we discard any unblockable 
signal (STOP and KILL) sent by a process to its pid namespace init process ? 
Then, all other signals should be handled appropriately by the pid namespace 
init. 

We are assuming that the pid namespace init is not doing anything silly and 
I guess it's OK if the consequences are only on the its pid namespace and 
not the whole system.

Cheers,

C.
