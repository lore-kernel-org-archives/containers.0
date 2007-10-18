From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH 2/3] [NETNS49] Add struct net to all calls for
	rt_cache_flush
Date: Thu, 18 Oct 2007 18:40:48 +0400
Message-ID: <47177070.4000700@sw.ru>
References: <20071018100330.GA23415@iris.sw.ru> <471764A9.2080703@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471764A9.2080703-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
>> commit 628d4768843fc6d572596b91e29f8ce6506c276a
>> Author: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>> Date:   Thu Oct 18 12:48:38 2007 +0400
>>
>>     Add struct net to all calls for rt_cache_flush. Additionally, the 
>> function
>>     manipulating with timer should not actually call the garbage 
>> collector as
>>     the namespace is not known in the global rt_secret_rebuild.
>>         Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>>
> 
> I see you are using current->nsproxy->net_ns for sysctl stuff. Normally 
> you should use ctl->extra2 where the struct net is stored. But in the 
> case of route sysctl, it is not per namespace, so ctl->extra2 is NULL.
> I will look at that and make it per namespace, so you will be able to 
> build this patch on top of it and remove current->nsproxy->net_ns.

I think that this is quite boring. It is impossible to get the namespace 
almost anywhere even when it is safe to use this :(

extra2 is a bad place, as it has a conventional meaning for other 
kernel. For example it is used for quite a lot of sysctl-s anywhere.

Regards,
	Den
