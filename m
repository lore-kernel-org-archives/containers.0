From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/8] Use vmalloc for large cgroups pidlist allocations
Date: Thu, 20 Aug 2009 10:54:25 +0800
Message-ID: <4A8CBAE1.9010408__43567.5251683735$1250737180$gmane$org@cn.fujitsu.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>	
	<20090818235827.22531.60306.stgit@menage.mtv.corp.google.com>	
	<4A8CB6F0.1020308@cn.fujitsu.com>
	<6599ad830908191941g77db4e69ve46bc8623f77d97f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908191941g77db4e69ve46bc8623f77d97f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Aug 19, 2009 at 7:37 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> I come to realize the "procs" file will make it much harder to convert
>> vmalloc/kmalloc with a different solution..
>>
> 
> Why do you think that?
> 

To avoid showing duplicate threadgroup pids, when dealing with a
thread, you have to check backwards to see if it's group pid
has been printed. Maybe it doesn't add much extra cost with your
proposal, we'll see.
