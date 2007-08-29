From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [-mm PATCH] Memory controller improve user interface
Date: Thu, 30 Aug 2007 04:07:11 +0530
Message-ID: <46D5F517.1080809@linux.vnet.ibm.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	<1188413148.28903.113.camel@localhost>
	<46D5ED5C.9030405@linux.vnet.ibm.com>
	<1188425894.28903.140.camel@localhost>
	<6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
	<1188426352.28903.143.camel@localhost>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1188426352.28903.143.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Wed, 2007-08-29 at 15:20 -0700, Paul Menage wrote:
>> I'd argue that having the user's specified limit be truncated to the
>> page size is less confusing than giving an EINVAL if it's not page
>> aligned.
> 
> Do we truncate mmap() values to the nearest page so to not confuse the
> user? ;)
> 

I think rounding to the closest page size is a better option, but
again it can be a bit confusing. I am all for using memparse() to
parse the user input as a specification of the memory limit.

The second question of how to store it internally without truncation/
rounding is something we need to agree upon. We also need to see
how to display the data back to the user.

I chose kilobytes for two reasons

1. Several people recommended it
2. Herbert mentioned that they've moved to that interface and it
   was working fine for them.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

PS: I am going off to the web to search for some CUI/CLI guidelines.
