From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
Date: Tue, 19 Aug 2008 16:06:07 +0530
Message-ID: <48AAA217.8040307__41929.2490966201$1219142428$gmane$org@linux.vnet.ibm.com>
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
	<48A49C78.7070100@linux.vnet.ibm.com> <48A9E82E.3060009@gmail.com>
	<48AA4003.5080300@linux.vnet.ibm.com> <48AA970D.5050403@gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AA970D.5050403-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Jiri Slaby wrote:
> On 08/19/2008 05:37 AM, Balbir Singh wrote:
>> Could you please help me with the steps to reproduce the problem.  I don't seem
>> to be hitting the mm->owner changed callback. I did have a test case for it when
>> I developed mm->owner functionality, but it does not trigger an oops for me.
> 
> I have no idea. My config is at:
> http://decibel.fi.muni.cz/~xslaby/config-memrlimit-oops
> I don't play with cgroups or anything, I just work on the system. Do you need a
> test case, it's obvious from the code as far as I can see?

Yes, the problem is obvious, but I usually use small test cases or test
scenarios to verify that the problem is fixed.

-- 
	Balbir
