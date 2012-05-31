From: KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Thu, 31 May 2012 03:23:00 -0400
Message-ID: <4FC71C54.3060909@gmail.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
	<alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
	<4FC6B68C.2070703@jp.fujitsu.com>
	<CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
	<4FC6BC3E.5010807@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
	<4FC6C111.2060108@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com>
	<4FC6D881.4090706@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
	<4FC70355.70805@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
	<4FC70E5E.1010003@gmail.com>
	<alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com>
	<4FC711A5.4090003@gmail.com> <4FC718BA.8060608@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC718BA.8060608-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(5/31/12 3:07 AM), Kamezawa Hiroyuki wrote:
> (2012/05/31 15:37), KOSAKI Motohiro wrote:
>> (5/31/12 2:28 AM), David Rientjes wrote:
>>> On Thu, 31 May 2012, KOSAKI Motohiro wrote:
>>>
>>>>> An application should always know the cgroup that its attached to and be
>>>>> able to read its state using the command that I gave earlier.
>>>>
>>>> No. you don't need why userland folks want namespaces. Even though you don't
>>>> need namespaces. It doesn't good reason to refuse another use case.
>>>>
>>>
>>> This is tangent to the discussion, we need to revisit why an application
>>> other than a daemon managing a set of memcgs would ever need to know the
>>> information in /proc/meminfo. No use-case was ever presented in the
>>> changelog and its not clear how this is at all relevant. So before
>>> changing the kernel, please describe how this actually matters in a real-
>>> world scenario.
>>
>> Huh? Don't you know a meanings of a namespace ISOLATION? isolation mean,
>> isolated container shouldn't be able to access global information. If you
>> want to lean container/namespace concept, tasting openvz or solaris container
>> is a good start.
>>
>> But anyway, I dislike current implementaion. So, I NAK this patch too.
>
> Could you give us advice for improving this ? What idea do you have ?

?
I'm ok your idea. I only NAKed current Gao's patch.
