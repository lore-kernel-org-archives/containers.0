From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [-mm PATCH]  Memory controller improve user interface
Date: Thu, 30 Aug 2007 04:14:15 +0530
Message-ID: <46D5F6BF.2080607@linux.vnet.ibm.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	<1188413148.28903.113.camel@localhost>
	<46D5ED5C.9030405@linux.vnet.ibm.com>
	<1188425894.28903.140.camel@localhost>
	<46D5F2BB.8010203@linux.vnet.ibm.com>
	<1188427000.28903.148.camel@localhost>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1188427000.28903.148.camel@localhost>
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
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Thu, 2007-08-30 at 03:57 +0530, Balbir Singh wrote:
>> True, mmap() is a good example of such an interface for developers, I
>> am not sure about system admins though.
>>
>> To quote Andrew
>> <quote>
>> Reporting tools could run getpagesize() and do the arithmetic, but we
>> generally try to avoid exposing PAGE_SIZE, HZ, etc to userspace in this
>> manner.
>> </quote>
> 
> Well, rounding to PAGE_SIZE exposes PAGE_SIZE as well, just in a
> non-intuitive fashion. :)
> 

Agreed, but the user might choose to ignore it altogether.

> If we're going to modify what the user specifies, we should probably at
> least mandate that writes are only a "suggestion" and users must read
> back the value to ensure what actually got committed.
> 

Agreed, excellent suggestion!

> If we're going to round in any direction, shouldn't we round up?  If a
> user specifies 4097 bytes and uses two pages, we don't want to complain
> when they hit that second page.  
> 

Absolutely, I used rounding to mean round up, truncation for rounding down.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
