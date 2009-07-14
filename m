From: "Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Mon, 13 Jul 2009 18:00:53 -0700
Message-ID: <4A5BD8C5.1060902__23075.2470590689$1247533351$gmane$org@embeddedalley.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>	
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>	
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>	
	<20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907131515h3c9622b5v309cf8f13d272bab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907131515h3c9622b5v309cf8f13d272bab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Jul 7, 2009 at 5:56 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>   
>> I know people likes to wait for file descriptor to get notification in these days.
>> Can't we have "event" file descriptor in cgroup layer and make it reusable for
>> other purposes ?
>>     
>
> I agree - rather than having to add a separate "wait for value to
> cross X threshold" file for each numeric usage value that people might
> be concerned about, it would be better to have a generic way to do it
> for any file. Given that this is a userspace API, it would be better
> to work out at least the generic API first, even if the initial
> implementation isn't generic.
>  "OOM"
>   
We all agree on that. Our original intention was to create the memory
limit notification capability, not a generic mechanism for the cgroup
events. So, we started out with something that fits the current model.

> - independent thresholds for different waiters
>   
The threshold is one of the Memory Controller cgroup attributes, as well
as memory usage limit. It is not a user task attribute and should not be
controlled by user tasks. It's administrator or some control task job to
set memory usage parameters within the cgroup. Once the threshold is
reached, all tasks within the cgroup should be notified and do their
best to free the memory.
